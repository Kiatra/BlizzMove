"""Negative-path coverage for the exact-build WoW Forever guards.

Author: Neil Mitchell
Last Modified By: Neil Mitchell
"""

from pathlib import Path
import sys
import unittest

from lupa.lua51 import LuaRuntime

TESTS = Path(__file__).resolve().parent
if str(TESTS) not in sys.path:
    sys.path.insert(0, str(TESTS))

import test_forever_core as core


BUILD_AND_GUARDS = core.BUILD_AND_GUARDS
BUILD_MOCKS = core.BUILD_MOCKS


KNOWN_MESSAGE = "prefix Blizzard_LFGVanilla_ParentFrame.lua:29: attempt to index global 'LFGWhoListFrame' (a nil value)"
KNOWN_STACK = (
    "[Interface/AddOns/Blizzard_GroupFinder_VanillaStyle/Blizzard_LFGVanilla_ParentFrame.lua]:29:\n"
    "[Interface/AddOns/Blizzard_GroupFinder_VanillaStyle/Blizzard_LFGVanilla_Browse.lua]:125:\n"
    "in function 'LFGParentFrame_SearchActiveEntry'\nin function 'LoadAddOn'"
)


class GuardEdges(unittest.TestCase):
    def make_lua(self, script_errors=True, barber=True, combat=False):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.execute(BUILD_MOCKS)
        lua.execute(
            """
            accessibility = {}
            function canaccessvalue(value)
                if accessibility[value] == 'raise' then error('inaccessible matcher') end
                return accessibility[value] ~= false
            end
            loadedOrLoading, loaded = true, false
            function IsAddOnLoaded() return loadedOrLoading, loaded end
            combat = %s
            %s
            %s
            """
            % (
                "true" if combat else "false",
                "ScriptErrorsFrame=makeDisplayFrame()" if script_errors else "ScriptErrorsFrame=nil",
                """BarberShopFrame={}; CharCustomizeFrame={parentFrame=BarberShopFrame, originalCalls=0,
                    UpdateSmallButtons=function(self, ...) self.originalCalls=self.originalCalls+1; return ... end}"""
                if barber
                else "BarberShopFrame=nil; CharCustomizeFrame=nil",
            )
        )
        lua.execute("do\n" + BUILD_AND_GUARDS + "\nend")
        return lua

    def test_filter_fails_open_for_every_non_exact_or_inaccessible_case(self):
        lua = self.make_lua()
        lua.execute("stack=...", KNOWN_STACK)
        lua.execute("message=...", KNOWN_MESSAGE)
        cases = (
            "accessibility[message]=false",
            "accessibility[stack]=false",
            "accessibility[message]='raise'",
            "message=17",
            "stack=17",
            "LFGWhoListFrame={}",
            "loadedOrLoading=false",
            "loaded=true",
        )
        for change in cases:
            with self.subTest(change=change):
                lua.execute("accessibility={}; LFGWhoListFrame=nil; loadedOrLoading=true; loaded=false; message=...; stack=...", KNOWN_MESSAGE, KNOWN_STACK)
                lua.execute(change)
                lua.execute("assert(ScriptErrorsFrame:DisplayMessageInternal(message, 0, stack, 'tail') == 'forwarded')")
        lua.execute("assert(ScriptErrorsFrame.originalCalls == 8 and BlizzMove.foreverLFGSuppressedErrors == 0)")

    def test_filter_forwards_varargs_and_return_value(self):
        lua = self.make_lua()
        lua.execute("assert(ScriptErrorsFrame:DisplayMessageInternal('other', 9, 'stack', 'tail') == 'forwarded')")
        lua.execute("assert(ScriptErrorsFrame.originalCalls == 1 and ScriptErrorsFrame.last[4] == 'tail')")

    def test_filter_installs_when_script_errors_addon_loads_late(self):
        lua = self.make_lua(script_errors=False)
        lua.execute("assert(#createdFrames == 1 and createdFrames[1].registered.ADDON_LOADED)")
        lua.execute("ScriptErrorsFrame=makeDisplayFrame(); createdFrames[1].OnEvent(createdFrames[1], 'ADDON_LOADED', 'Blizzard_ScriptErrorsFrame')")
        lua.globals().message = KNOWN_MESSAGE
        lua.globals().stack = KNOWN_STACK
        lua.execute("assert(ScriptErrorsFrame:DisplayMessageInternal(message, 0, stack) == nil)")
        lua.execute("assert(BlizzMove.foreverLFGSuppressedErrors == 1 and not createdFrames[1].registered.ADDON_LOADED)")

    def test_barber_guard_defers_for_combat_and_forwards_other_parent(self):
        lua = self.make_lua(combat=True)
        lua.execute("assert(not BlizzMove.foreverBarberShopGuardInstalled and #createdFrames == 1)")
        lua.execute("combat=false; createdFrames[1].OnEvent(createdFrames[1], 'PLAYER_REGEN_ENABLED')")
        lua.execute("assert(BlizzMove.foreverBarberShopGuardInstalled and CharCustomizeFrame:UpdateSmallButtons('barber') == nil)")
        lua.execute("CharCustomizeFrame.parentFrame={}; assert(CharCustomizeFrame:UpdateSmallButtons('creation') == 'creation')")
        lua.execute("assert(CharCustomizeFrame.originalCalls == 1)")


class DelayedInitializationEdges(unittest.TestCase):
    def test_existing_and_late_arriving_preferences_survive_forever_delay(self):
        lua = core.Initialization().make_lua(True)
        lua.execute("BlizzMoveDB={savePosStrategy='off', saveScaleStrategy='session'}; BlizzMove:OnInitialize(); flush()")
        lua.execute("assert(BlizzMoveDB.savePosStrategy == 'off' and BlizzMoveDB.saveScaleStrategy == 'session')")

        lua = core.Initialization().make_lua(True)
        lua.execute("BlizzMoveDB=nil; BlizzMove:OnInitialize(); BlizzMoveDB={savePosStrategy='session', saveScaleStrategy='off'}; flush()")
        lua.execute("assert(BlizzMove.DB == BlizzMoveDB and BlizzMoveDB.savePosStrategy == 'session' and BlizzMoveDB.saveScaleStrategy == 'off')")


if __name__ == "__main__":
    unittest.main(verbosity=2)
