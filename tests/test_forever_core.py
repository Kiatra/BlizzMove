"""Behavioral tests for BlizzMove's WoW Forever core adaptations.

Author: Neil Mitchell
Last Modified By: Neil Mitchell

The tests execute functions extracted from the production Lua file with small
WoW API doubles. They do not read or write a live client or SavedVariables.
"""

from pathlib import Path
import unittest

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "BlizzMove.lua").read_text(encoding="utf-8")


def section(source: str, first: str, last: str) -> str:
    start = source.index(first)
    return source[start : source.index(last, start)]


BUILD_AND_GUARDS = section(
    SOURCE,
    "    local version, buildNumber, _, interfaceVersion = GetBuildInfo();",
    "    local function checkRanges(ranges, needle)",
)
QUEUE = section(
    SOURCE,
    "    function BlizzMove:AddToCombatLockdownQueue(func, ...)",
    "    local setFramePointsQueue = {};",
)
PROCESSING = section(
    SOURCE,
    "    local function hookScript(frame, script, handler)",
    "--- Addon Init and Event Handling Functions",
)
MOUSE_AND_SHOW = section(
    SOURCE,
    "    function OnMouseDown(frame, button)",
    "    function OnSubFrameHide(frame)",
)
INITIALIZE = section(
    SOURCE,
    "    local function Initialize(addon)",
    "    function BlizzMove:OnSlashCommand(message)",
)
DEFAULTS = section(
    SOURCE,
    "    local defaults = {",
    "    function BlizzMove:ADDON_LOADED(_, addOnName)",
)
GROUP_FINDER_REPAIR = section(
    SOURCE,
    "        -- Build 69913 can abort the Group Finder Browse OnLoad",
    "        -- fix anchor family connection issues when opening PlayerChoiceFrame",
)


BUILD_MOCKS = r'''
BlizzMove = {Versions={
    Forever='Forever', Standard='Standard', Midnight='Midnight', TWW='TWW',
    DF='DF', SL='SL', BFA='BFA', Legion='Legion', WOD='WOD', MOP='MOP',
    Cata='Cata', Wrath='Wrath', TBC='TBC', Vanilla='Vanilla',
    Mainline='Mainline', Classic='Classic', Fallback='Fallback'}}
is4E, isForever69913 = false, false
buildVersion, buildNumber, interfaceVersion = '1.60.1', '69913', 16001
function GetBuildInfo() return buildVersion, buildNumber, 'date', interfaceVersion end
function canaccessvalue() return true end
function InCombatLockdown() return combat == true end
function IsAddOnLoaded(name)
    assert(name == 'Blizzard_GroupFinder_VanillaStyle')
    return true, false
end
createdFrames = {}
local Listener = {}
function Listener:RegisterEvent(event) self.registered = self.registered or {}; self.registered[event]=true end
function Listener:UnregisterEvent(event) self.registered[event]=nil end
function Listener:SetScript(script, callback) self[script]=callback end
function CreateFrame()
    local frame=setmetatable({}, {__index=Listener})
    table.insert(createdFrames, frame)
    return frame
end
function makeDisplayFrame()
    return {originalCalls=0, DisplayMessageInternal=function(self, ...)
        self.originalCalls=self.originalCalls+1; self.last={...}; return 'forwarded'
    end}
end
'''


class ExactBuildGuards(unittest.TestCase):
    def make_lua(self, version="1.60.1", build="69913", interface=16001):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(BUILD_MOCKS)
        lua.globals().buildVersion = version
        lua.globals().buildNumber = build
        lua.globals().interfaceVersion = interface
        return lua

    def test_exact_build_filters_only_known_lfg_display_error(self):
        lua = self.make_lua()
        lua.execute(r'''
            ScriptErrorsFrame=makeDisplayFrame()
            CharCustomizeFrame={parentFrame=nil, originalCalls=0,
                UpdateSmallButtons=function(self, value)
                    self.originalCalls=self.originalCalls+1; return value
                end}
            BarberShopFrame={}
            CharCustomizeFrame.parentFrame=BarberShopFrame
        ''')
        lua.execute("do\n" + BUILD_AND_GUARDS + "\nend")
        lua.execute(r'''
            assert(is4E and isForever69913)
            local message="prefix Blizzard_LFGVanilla_ParentFrame.lua:29: attempt to index global 'LFGWhoListFrame' (a nil value)"
            local stack="[Interface/AddOns/Blizzard_GroupFinder_VanillaStyle/Blizzard_LFGVanilla_ParentFrame.lua]:29:\n"
                .."[Interface/AddOns/Blizzard_GroupFinder_VanillaStyle/Blizzard_LFGVanilla_Browse.lua]:125:\n"
                .."in function 'LFGParentFrame_SearchActiveEntry'\nin function 'LoadAddOn'"
            ScriptErrorsFrame:DisplayMessageInternal(message, 0, stack)
            assert(ScriptErrorsFrame.originalCalls == 0)
            assert(BlizzMove.foreverLFGSuppressedErrors == 1)
            assert(ScriptErrorsFrame:DisplayMessageInternal('other', 0, stack) == 'forwarded')
            assert(ScriptErrorsFrame.originalCalls == 1)
            assert(BlizzMove.foreverBarberShopGuardInstalled)
            assert(CharCustomizeFrame:UpdateSmallButtons('barber') == nil)
            assert(CharCustomizeFrame.originalCalls == 0)
            CharCustomizeFrame.parentFrame={}
            assert(CharCustomizeFrame:UpdateSmallButtons('creation') == 'creation')
            assert(CharCustomizeFrame.originalCalls == 1)
        ''')

    def test_non_forever_and_other_forever_builds_do_not_install_guards(self):
        for version, build, interface in (
            ("1.15.8", "70000", 11508),
            ("1.60.1", "69914", 16001),
            ("1.60.2", "69913", 16001),
        ):
            with self.subTest(version=version, build=build, interface=interface):
                lua = self.make_lua(version, build, interface)
                lua.execute("ScriptErrorsFrame=makeDisplayFrame()")
                lua.execute("do\n" + BUILD_AND_GUARDS + "\nend")
                self.assertFalse(lua.globals().isForever69913)
                lua.execute("assert(ScriptErrorsFrame:DisplayMessageInternal('x', 0, 'y') == 'forwarded')")


QUEUE_MOCKS = r'''
combat=false
tinsert=table.insert
function wipe(value) for key in pairs(value) do value[key]=nil end end
function InCombatLockdown() return combat end
BlizzMove={CombatLockdownQueue={}, registrations=0, unregisters=0}
function BlizzMove:RegisterEvent(event) assert(event=='PLAYER_REGEN_ENABLED'); self.registrations=self.registrations+1 end
function BlizzMove:UnregisterEvent(event) assert(event=='PLAYER_REGEN_ENABLED'); self.unregisters=self.unregisters+1 end
function BlizzMove:DebugPrint() end
'''


class CombatQueue(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(QUEUE_MOCKS)
        self.lua.execute(QUEUE)

    def test_out_of_combat_executes_once_without_queueing(self):
        self.lua.execute(r'''
            calls=0
            BlizzMove:AddToCombatLockdownQueue(function(value) calls=calls+value end, 1)
            assert(calls == 1 and #BlizzMove.CombatLockdownQueue == 0)
            assert(BlizzMove.registrations == 0)
            BlizzMove:PLAYER_REGEN_ENABLED()
            assert(calls == 1)
        ''')

    def test_combat_call_queues_then_executes_once(self):
        self.lua.execute(r'''
            calls=0; combat=true
            BlizzMove:AddToCombatLockdownQueue(function() calls=calls+1 end)
            assert(calls == 0 and #BlizzMove.CombatLockdownQueue == 1)
            combat=false; BlizzMove:PLAYER_REGEN_ENABLED()
            assert(calls == 1 and #BlizzMove.CombatLockdownQueue == 0)
        ''')


PROCESSING_MOCKS = r'''
is4E=true
combat=false
tinsert=table.insert
function wipe(value) for key in pairs(value) do value[key]=nil end end
CallErrorHandler=function(error) return error end
L=setmetatable({}, {__index=function(_, key) return key end})
local nativeXpcall=xpcall
function xpcall(callback, handler, ...)
    local args={...}; return nativeXpcall(function() return callback(unpack(args)) end, handler)
end
function InCombatLockdown() return combat end
function RunNextFrame(callback) end
local Frame={}; Frame.__index=Frame
function newFrame(name)
    return setmetatable({name=name, level=10, protected=false, mutations=0, hooks={}, scripts={}}, Frame)
end
function Frame:IsProtected() return self.protected end
function Frame:SetMovable(value) self.mutations=self.mutations+1; self.movable=value end
function Frame:SetClampedToScreen(value) self.mutations=self.mutations+1 end
function Frame:EnableMouse(value) self.mutations=self.mutations+1; self.mouse=value end
function Frame:EnableMouseWheel(value) self.mutations=self.mutations+1 end
function Frame:SetParent(value) self.mutations=self.mutations+1; self.parent=value end
function Frame:GetParent() return self.parent end
function Frame:SetPoint(...) self.mutations=self.mutations+1 end
function Frame:SetPointBase(...) self.mutations=self.mutations+1 end
function Frame:SetHeight(value) self.mutations=self.mutations+1 end
function Frame:SetAllPoints(value) self.mutations=self.mutations+1; self.allPoints=true end
function Frame:GetFrameLevel() return self.level end
function Frame:SetFrameLevel(value) self.mutations=self.mutations+1; self.level=value end
function Frame:SetPropagateMouseMotion() end
function Frame:SetPropagateMouseClicks() end
function Frame:SetScript(script, callback) self.scripts[script]=callback end
function Frame:HookScript(script, callback) self.hooks[script]=(self.hooks[script] or 0)+1 end
function Frame:Hide() self.hidden=true end
function Frame:HasScript() return true end
function Frame:IsMouseOver() return false end
handles={}
function CreateFrame(_, _, parent, template)
    assert(template=='PanelDragBarTemplate')
    local handle=newFrame('handle'); handle.parent=parent; table.insert(handles, handle); return handle
end
function hooksecurefunc(frame, method) frame.hooks[method]=(frame.hooks[method] or 0)+1 end
OnMouseDown=function() end; OnMouseUp=function() end; OnMouseWheel=function() end
OnShow=function() end; OnEnter=function() end; OnLeave=function() end
OnSubFrameHide=function() end; OnSetPoint=function() end; OnSizeUpdate=function() end
BlizzMove={FrameData={}, FrameRegistry={}, MoveHandles={}, CombatLockdownQueue={}, hookCount=0}
function BlizzMove:DebugPrint() end
function BlizzMove:Print(...) error('unexpected diagnostic') end
function BlizzMove:IsFrameDisabled() return false end
function BlizzMove:MatchesCurrentBuild() return true end
function BlizzMove:GetFrameFromName(_, name) return _G[name] end
function BlizzMove:GetFrameName(frame)
    local data=self.FrameData[frame]; return data and data.storage and data.storage.frameName
end
function BlizzMove:SecureHook(frame, method)
    self.hookCount=self.hookCount+1; frame.hooks[method]=(frame.hooks[method] or 0)+1
end
function BlizzMove:SecureHookScript(frame, method)
    self.hookCount=self.hookCount+1; frame.hooks[method]=(frame.hooks[method] or 0)+1
end
function BlizzMove:Unhook() end
function BlizzMove:RegisterEvent() end
function BlizzMove:AddToCombatLockdownQueue(func, ...)
    table.insert(self.CombatLockdownQueue, {func=func, args={...}})
end
'''


class ForeverFrameLifecycle(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(PROCESSING_MOCKS)
        self.lua.execute("do\n" + PROCESSING)

    def test_lfg_uses_highest_native_title_and_setpointbase_hook(self):
        self.lua.execute(r'''
            LFGParentFrame=newFrame('LFGParentFrame')
            LFGListingFrame={TitleContainer=newFrame('listing')}; LFGListingFrame.TitleContainer.level=100
            LFGBrowseFrame={TitleContainer=newFrame('browse')}; LFGBrowseFrame.TitleContainer.level=500
            LFGWhoListFrame={TitleContainer=newFrame('who')}; LFGWhoListFrame.TitleContainer.level=200
            BlizzMove:ProcessFrame('Blizzard_GroupFinder_VanillaStyle', 'LFGParentFrame', {})
            assert(#handles == 1 and handles[1].level == 501)
            assert(not handles[1].allPoints, 'Forever LFG handle covered the whole page')
            assert(LFGParentFrame.hooks.SetPoint == 1 and LFGParentFrame.hooks.SetPointBase == 1)
        ''')

    def test_forced_forever_lfg_processing_defers_in_combat(self):
        self.lua.execute(r'''
            LFGParentFrame=newFrame('LFGParentFrame'); combat=true
            BlizzMove:ProcessFrame('Blizzard_GroupFinder_VanillaStyle', 'LFGParentFrame', {})
            assert(#handles == 0 and LFGParentFrame.mutations == 0)
            assert(#BlizzMove.CombatLockdownQueue == 1)
        ''')

    def test_non_forever_lfg_keeps_ordinary_mouse_path(self):
        self.lua.execute(r'''
            is4E=false; LFGParentFrame=newFrame('LFGParentFrame')
            BlizzMove:ProcessFrame('Blizzard_GroupFinder_VanillaStyle', 'LFGParentFrame', {})
            assert(#handles == 0 and LFGParentFrame.mouse == true)
            assert(LFGParentFrame.hooks.SetPointBase == nil)
        ''')


MOUSE_MOCKS = r'''
is4E=true
function InCombatLockdown() return false end
function IsAltKeyDown() return false end
function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function PlaySound() end
function UpdateUIPanelPositions() end
function StartMoving(frame) frame.started=(frame.started or 0)+1 end
function StopMoving(frame) frame.stopped=(frame.stopped or 0)+1 end
function GetAbsoluteFramePosition() return {{offX=123, offY=-45}} end
function SetFramePoints(frame, points) frame.applied=points; return true end
function SetFrameScale() return true end
function GetFrameScale() return 1 end
function SetFrameParent() end
function RunNextFrame() end
MIN_SCALE=.3; MAX_SCALE=2.5
local Frame={}; Frame.__index=Frame
function newFrame() return setmetatable({userPlaced=false}, Frame) end
function Frame:IsUserPlaced() return self.userPlaced end
function Frame:SetUserPlaced(value) self.userPlaced=value end
function Frame:SetMovable(value) self.movable=value end
function Frame:IsProtected() return false end
BlizzMove={FrameData={}, MoveHandles={}, DB={savePosStrategy='permanent', saveScaleStrategy='session'},
    SessionScales={}, waits=0, pointQueues=0}
function BlizzMove:SetupPointStorage() return true end
function BlizzMove:DebugPrint() end
function BlizzMove:GetFrameName() return 'TestFrame' end
function BlizzMove:WaitForGlobalMouseUp(frame) self.waits=self.waits+1; self.waited=frame end
function BlizzMove:AddToSetFramePointsQueue(frame, points)
    self.pointQueues=self.pointQueues+1; self.queuedFrame=frame; self.queuedPoints=points
end
function BlizzMove:AddToCombatLockdownQueue() error('unexpected combat queue') end
'''


class DragAndPositionRestore(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(MOUSE_MOCKS)
        self.lua.execute("do\n" + MOUSE_AND_SHOW + "\nend")

    def test_forever_drag_arms_global_mouse_release(self):
        self.lua.execute(r'''
            local frame=newFrame()
            BlizzMove.FrameData[frame]={storage={frameName='TestFrame', detached=true, points={}}}
            assert(OnMouseDown(frame, 'LeftButton'))
            assert(BlizzMove.waits == 1 and BlizzMove.waited == frame)
            OnMouseUp(frame, 'LeftButton')
            assert(BlizzMove.FrameData[frame].storage.points.dragged)
            assert(BlizzMove.FrameData[frame].storage.points.dragPoints[1].offX == 123)
        ''')

    def test_non_forever_drag_does_not_arm_global_release(self):
        self.lua.execute(r'''
            is4E=false
            local frame=newFrame()
            BlizzMove.FrameData[frame]={storage={frameName='TestFrame', detached=true, points={}}}
            OnMouseDown(frame, 'LeftButton')
            assert(BlizzMove.waits == 0)
        ''')

    def test_onshow_requeues_only_forever_permanent_root_position(self):
        self.lua.execute(r'''
            local frame=newFrame()
            local points={dragged=true, dragPoints={{offX=77, offY=-88}}}
            BlizzMove.FrameData[frame]={storage={frameName='TestFrame', points=points}}
            OnShow(frame, true)
            assert(BlizzMove.pointQueues == 1 and BlizzMove.queuedPoints == points.dragPoints)
            is4E=false
            OnShow(frame, true)
            assert(BlizzMove.pointQueues == 1)
        ''')


INIT_MOCKS = r'''
scheduled={}
function RunNextFrame(callback) table.insert(scheduled, callback) end
function flush() local pending=scheduled; scheduled={}; for _, callback in ipairs(pending) do callback() end end
function IsAddOnLoaded() return false end
function GetServerTime() return 1700000000 end
C_CVar={SetCVar=function() end}
C_AddOns={GetNumAddOns=function() return 0 end, GetAddOnInfo=function() end}
EventRegistry={RegisterCallback=function() end}
commands={}
BlizzMove={name='BlizzMove', Frames={}, FrameData={}, Config={Initialize=function() end}}
function BlizzMove:InitMouseWheelCaptureFrame() end
function BlizzMove:RegisterChatCommand() end
function BlizzMove:SavePositionStrategyChanged() end
function BlizzMove:ProcessFrames() end
function BlizzMove:ApplyAddOnSpecificFixes() end
function BlizzMove:RegisterEvent() end
'''


class Initialization(unittest.TestCase):
    def make_lua(self, forever):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(INIT_MOCKS)
        lua.globals().is4E = forever
        lua.execute("do\n" + DEFAULTS + "\n" + INITIALIZE + "\nend")
        return lua

    def test_forever_defers_and_defaults_missing_preferences_to_permanent(self):
        lua = self.make_lua(True)
        lua.execute(r'''
            BlizzMoveDB=nil; BlizzMove:OnInitialize()
            assert(not BlizzMove.initialized and #scheduled == 1)
            flush()
            assert(BlizzMove.initialized and BlizzMove.DB == BlizzMoveDB)
            assert(BlizzMoveDB.savePosStrategy == 'permanent')
            assert(BlizzMoveDB.saveScaleStrategy == 'permanent')
        ''')

    def test_non_forever_initializes_immediately_with_session_defaults(self):
        lua = self.make_lua(False)
        lua.execute(r'''
            BlizzMoveDB=nil; BlizzMove:OnInitialize()
            assert(BlizzMove.initialized and #scheduled == 0)
            assert(BlizzMoveDB.savePosStrategy == 'session')
            assert(BlizzMoveDB.saveScaleStrategy == 'session')
        ''')


REPAIR_MOCKS = r'''
isForever69913=true
combat=false
scheduled={}
function RunNextFrame(callback) table.insert(scheduled, callback) end
function flush() local pending=scheduled; scheduled={}; for _, callback in ipairs(pending) do callback() end end
function InCombatLockdown() return combat end
BlizzMove={queued={}, processed=0}
function BlizzMove:AddToCombatLockdownQueue(func) table.insert(self.queued, func) end
function BlizzMove:ProcessFrames() self.processed=self.processed+1 end
function runQueued() local pending=BlizzMove.queued; BlizzMove.queued={}; for _, callback in ipairs(pending) do callback() end end
LFGVANILLA_SETTING_MODERN_STYLE=true; LFG_TITLE='Group Finder'; active=true
C_LFGList={HasActiveEntryInfo=function() return active end}
LFGParentFrame={tabs=0, eyes=0}
function LFGParentFrame:UpdateTabs() self.tabs=self.tabs+1 end
function LFGParentFrame:UpdateEyePortrait() self.eyes=self.eyes+1 end
local title={value=''}
function title:GetText() return self.value end
function title:SetText(value) self.value=value end
local bg={shown=true}
function bg:Hide() self.shown=false end
LFGBrowseFrame={TitleContainer={TitleText=title}, Inset={Bg=bg}, portraits=0}
function LFGBrowseFrame:SetPortraitAtlasRaw(atlas) self.portraits=self.portraits+1; self.atlas=atlas end
LFGWhoListFrame={native=true}
'''


class GroupFinderRecovery(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(REPAIR_MOCKS)
        self.lua.execute(
            "function Apply(addOnName)\n" + GROUP_FINDER_REPAIR + "\nend"
        )

    def test_repairs_visual_tail_without_replaying_search_or_faking_who(self):
        self.lua.execute(r'''
            local who=LFGWhoListFrame
            Apply('Blizzard_GroupFinder_VanillaStyle'); flush()
            assert(LFGBrowseFrame.atlas == 'groupfinder-eye-frame')
            assert(LFGBrowseFrame.TitleContainer.TitleText:GetText() == LFG_TITLE)
            assert(not LFGBrowseFrame.Inset.Bg.shown)
            assert(LFGWhoListFrame == who and who.native)
            assert(BlizzMove.processed == 1 and LFGParentFrame.tabs == 1 and LFGParentFrame.eyes == 1)
        ''')

    def test_combat_defers_entire_refresh(self):
        self.lua.execute(r'''
            combat=true; Apply('Blizzard_GroupFinder_VanillaStyle'); flush()
            assert(#BlizzMove.queued == 1 and BlizzMove.processed == 0)
            assert(LFGBrowseFrame.portraits == 0)
            combat=false; runQueued()
            assert(BlizzMove.processed == 1 and LFGBrowseFrame.portraits == 1)
        ''')

    def test_non_matching_gate_is_inert(self):
        self.lua.execute(r'''
            isForever69913=false
            Apply('Blizzard_GroupFinder_VanillaStyle'); flush()
            assert(BlizzMove.processed == 0 and LFGBrowseFrame.portraits == 0)
        ''')


if __name__ == "__main__":
    unittest.main(verbosity=2)
