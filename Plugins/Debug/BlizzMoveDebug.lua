-- upvalue the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local CreateFrame = _G.CreateFrame;
local UIParent = _G.UIParent;
local pairs = _G.pairs;
local type = _G.type;
local C_Console__GetAllCommands = _G.C_Console.GetAllCommands;
local string__format = _G.string.format;
local GetCVarInfo = _G.GetCVarInfo;
local IsAddOnLoaded = _G.IsAddOnLoaded;
local GetNumAddOns = _G.GetNumAddOns;
local GetAddOnInfo = _G.GetAddOnInfo;
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata;

local BlizzMove = LibStub('AceAddon-3.0'):GetAddon('BlizzMove');
if not BlizzMove then return ; end

--- @class BlizzMove_Debug
local Module = BlizzMove:NewModule('Debug')
--- @type BlizzMoveAPI
local BlizzMoveAPI = BlizzMoveAPI;

local json = LibStub('JsonLua-1.0');

Module.frameConfig = {
    point = 'CENTER',
    relativeFrame = nil,
    relativePoint = 'CENTER',
    ofsx = 0,
    ofsy = 0,
    width = 750,
    height = 400,
}
Module.bannedCharacterPattern = '[^a-zA-Z0-9 !@#$%^&*()_+\-=,.:;?~`{}[<>]';

local function encode_string(val)
    return '"' .. val:gsub(Module.bannedCharacterPattern, function(c) return string__format('"..strchar(%d).."', c:byte()); end) .. '"';
end

local function getFrameName(frame, fallback)
    return frame.GetDebugName and frame:GetDebugName()
            or frame.GetName and frame:GetName()
            or fallback or 'noName';
end

function Module:FindBadAnchorConnections(frame)
    local tree, inverse = self:BuildAnchorTree();
    local children = self:GetAllTreeChildren(tree, frame);

    local badAnchorConnections = {};
    for child, _ in pairs(children) do
        for parent, _ in pairs(inverse[child] or {}) do
            if not children[parent] and parent ~= frame then
                table.insert(badAnchorConnections, {
                    name = getFrameName(child),
                    targetName = getFrameName(parent),
                    source = child.GetSourceLocation and child:GetSourceLocation() or 'Unknown',
                    targetSource = parent.GetSourceLocation and parent:GetSourceLocation() or 'Unknown',
                });
            end
        end
    end

    return badAnchorConnections;
end

function Module:GetAllTreeChildren(tree, frame)
    local children = {};
    if not tree[frame] then return children; end
    for child, _ in pairs(tree[frame]) do
        children[child] = true;
        for grandchild, _ in pairs(self:GetAllTreeChildren(tree, child)) do
            children[grandchild] = true;
        end
    end

    return children;
end

function Module:BuildAnchorTree()
    local tree = {};
    local inverse = {};

    local frame = EnumerateFrames();
    while frame do
        local isForbidden = frame.IsForbidden and frame:IsForbidden();
        local isRestricted = not isForbidden and frame.IsAnchoringRestricted and frame:IsAnchoringRestricted();
        local numPoints = not isRestricted and frame.GetNumPoints and frame:GetNumPoints() or 0;
        for i = 1, numPoints do
            local relativeTo = select(2, frame:GetPoint(i));
            if not relativeTo then
                relativeTo = frame.GetParent and frame:GetParent() or UIParent;
            end
            tree[relativeTo] = tree[relativeTo] or {};
            tree[relativeTo][frame] = true;

            inverse[frame] = inverse[frame] or {};
            inverse[frame][relativeTo] = true;
        end

        frame = EnumerateFrames(frame);
    end

    return tree, inverse;
end

function Module:DumpAllData(changedCVarsOnly)
    local data = {};
    data.cvars = self:ExtractCVars(changedCVarsOnly);
    for _, info in pairs(data.cvars) do
        info.value = info.value:gsub(self.bannedCharacterPattern, function(c) return string__format('\\u%04x', c:byte()); end)
    end
    data.savedVars = self:ExtractSavedVars();
    data.addons = self:ExtractAddonList();

    local frame = self:GetMainFrame(json.encode(data));
    frame:Show();
end

function Module:DumpCVars(options)
    local pastableFormat = not not options.pastableFormat;
    local changedOnly = not not options.changedOnly;

    local data = self:ExtractCVars(changedOnly);
    local text = '';
    if (pastableFormat) then
        for command, info in pairs(data) do
            if not info.readonly then
                text = text .. string__format('/run C_CVar.SetCVar(\"%s\", %s)\n', command, encode_string(info.value));
            end
        end
    else
        for _, info in pairs(data) do
            info.value = info.value:gsub(self.bannedCharacterPattern, function(c) return string__format('\\u%04x', c:byte()); end)
        end
        text = json.encode(data);
    end

    local frame = self:GetMainFrame(text);
    frame:Show();
end

function Module:ExtractCVars(changedOnly)
    local ret = {};

    for _, v in pairs(C_Console__GetAllCommands()) do
        local value, defaultValue, account, character, _, _, readonly = GetCVarInfo(v.command);
        local changed = (value ~= defaultValue);
        if not changedOnly or changed then
            ret[v.command] = {
                value = value,
                defaultValue = defaultValue,
                changed = changed,
                scope = ((account and 'account') or (character and 'character') or 'unknown'),
                readonly = readonly,
            };
        end
    end

    return ret;
end

function Module:ExtractAddonList()
    local ret = {};
    for i = 1, GetNumAddOns() do
        local addonName, _, _, loadable, _ = GetAddOnInfo(i);
        if loadable then
            local version = GetAddOnMetadata(addonName, 'Version') or 'unknown';
            ret[addonName] = {
                version = version,
                loaded = IsAddOnLoaded(i),
            };
        end
    end
    return ret;
end

function Module:ExtractSavedVars()
    return BlizzMove.DB;
end

-- list extracted from the listfile @ https://github.com/wowdev/wow-listfile/blob/master/community-listfile.csv
local blizzardAddons = { "blizzard_achievementui", "blizzard_adventuremap", "blizzard_alliedracesui", "blizzard_animadiversionui", "blizzard_animcreate", "blizzard_apidocumentation", "blizzard_apidocumentationgenerated", "blizzard_archaeologyui", "blizzard_ardenwealdgardening", "blizzard_arenaui", "blizzard_artifactui", "blizzard_auctionhouseshared", "blizzard_auctionhouseui", "blizzard_auctionui", "blizzard_authchallengeui", "blizzard_autoxml", "blizzard_azeriteessenceui", "blizzard_azeriterespecui", "blizzard_azeritetempui", "blizzard_azeriteui", "blizzard_barbershopui", "blizzard_battlefieldmap", "blizzard_battlefieldminimap", "blizzard_behavioralmessaging", "blizzard_bindingui", "blizzard_blackmarketui", "blizzard_boosttutorial", "blizzard_cachedlogin", "blizzard_calendar", "blizzard_challengesui", "blizzard_channels", "blizzard_charactercreate", "blizzard_charactercustomize", "blizzard_charcustomize", "blizzard_chromietimeui", "blizzard_classtalentdebug", "blizzard_classtalentui", "blizzard_classtrial", "blizzard_clickbindingui", "blizzard_clientsavedvariables", "blizzard_collections", "blizzard_combatlog", "blizzard_combattext", "blizzard_commentator", "blizzard_communities", "blizzard_compactraidframes", "blizzard_componenttests", "blizzard_console", "blizzard_consoleextensions", "blizzard_contribution", "blizzard_covenantcallings", "blizzard_covenantpreviewui", "blizzard_covenantrenown", "blizzard_covenantsanctum", "blizzard_covenanttoasts", "blizzard_craftui", "blizzard_cufprofiles", "blizzard_deathrecap", "blizzard_debugloader", "blizzard_debugtools", "blizzard_deprecated", "blizzard_encounterjournal", "blizzard_eventtrace", "blizzard_expansionlandingpage", "blizzard_flightmap", "blizzard_frameeffects", "blizzard_garrisontemplates", "blizzard_garrisonui", "blizzard_generictraitui", "blizzard_glyphui", "blizzard_gmchatui", "blizzard_gmsurveyui", "blizzard_guildbankui", "blizzard_guildcontrolui", "blizzard_guildrecruitmentui", "blizzard_guildui", "blizzard_hybridminimap", "blizzard_inspectui", "blizzard_islandspartyposeui", "blizzard_islandsqueueui", "blizzard_itemalterationui", "blizzard_iteminteractionui", "blizzard_itemsocketingui", "blizzard_itemupgradeui", "blizzard_kiosk", "blizzard_kioskmodeui", "blizzard_landingsoulbinds", "blizzard_loginerrorhelpers", "blizzard_lookingforgroupui", "blizzard_lookingforguildui", "blizzard_macroui", "blizzard_mainlinesettings", "blizzard_majorfactions", "blizzard_mapcanvas", "blizzard_mawbuffs", "blizzard_moneyreceipt", "blizzard_movepad", "blizzard_nameplates", "blizzard_newplayerexperience", "blizzard_newplayerexperienceguide", "blizzard_objectivetracker", "blizzard_obliterumui", "blizzard_olditemupgradeui", "blizzard_oldplayerchoiceui", "blizzard_orderhallui", "blizzard_partyposeui", "blizzard_perksprogram", "blizzard_perksprogramdevtool", "blizzard_petbattleui", "blizzard_petjournal", "blizzard_playerchoice", "blizzard_playerchoiceui", "blizzard_professions", "blizzard_professionscrafterorders", "blizzard_professionscustomerorders", "blizzard_professionsdebug", "blizzard_professionsspecializations", "blizzard_professionstemplates", "blizzard_profspecsimporter", "blizzard_prototypedialog", "blizzard_ptrfeedback", "blizzard_ptrfeedbackglue", "blizzard_pvphonorsystemui", "blizzard_pvpmatch", "blizzard_pvpui", "blizzard_questchoice", "blizzard_questnavigation", "blizzard_questnextquestlog", "blizzard_raidui", "blizzard_reforgingui", "blizzard_runeforgeui", "blizzard_scrappingmachineui", "blizzard_scriptedanimations", "blizzard_scriptedanimationstest", "blizzard_scrollboxdebug", "blizzard_securetransferui", "blizzard_selectorui", "blizzard_settings", "blizzard_settingsdebug", "blizzard_sharedmapdataproviders", "blizzard_sharedtalentui", "blizzard_sharedwidgetframes", "blizzard_socialui", "blizzard_soulbinds", "blizzard_soulbindsdebug", "blizzard_storeui", "blizzard_subscriptioninterstitialui", "blizzard_talenttestapi", "blizzard_talenttestdata", "blizzard_talenttestui", "blizzard_talentui", "blizzard_talkingheadui", "blizzard_testdataset", "blizzard_testdataseteditor", "blizzard_testframe", "blizzard_testingmode", "blizzard_timemanager", "blizzard_tokenui", "blizzard_toolsui", "blizzard_torghastlevelpicker", "blizzard_tradeskillui", "blizzard_trainerui", "blizzard_tutorial", "blizzard_tutorialmanager", "blizzard_tutorials", "blizzard_tutorialtemplates", "blizzard_uiframemanager", "blizzard_uiwidgets", "blizzard_undosystem", "blizzard_utility", "blizzard_voidstorageui", "blizzard_warboardui", "blizzard_warfrontspartyposeui", "blizzard_warfrontui", "blizzard_weeklyrewards", "blizzard_worldmap", "blizzard_wowtokenui" };
-- manual list of Toplevel frames that we don't handle on purpose
local ignoredFrames = {
    AuctionHouseMultisellProgressFrame = true, -- popup frame
    AuctionProgressFrame = true, -- popup frame
    BarbersChoiceConfirmFrame = true, -- popup frame
    BarberShopBannerFrame = true, -- graphic at the top of the screen in classic
    BarberShopFrame = true, -- fullscreen frame
    BattlefieldMapFrame = true, -- movable by default
    ClassTrialThanksForPlayingDialog = true, -- popup frame
    CombatText = true, -- seems to be scrolling combat text - don't move it
    CommentatorEventAlertsFrame = true, -- unsure what it is, might be commentator-mode only
    CommunitiesAvatarPickerDialog = true, -- fullscreen popup frame
    CommunitiesTicketManagerDialog = true, -- popup frame, not sure if we want to move it
    CompactRaidFrameManager = true, -- does not behave like a window
    EventTrace = true, -- movable by default
    ExpansionTrialThanksForPlayingDialog = true, -- popup frame
    GMChatFrame = true, -- movable by default
    GMChatStatusFrame = true, -- popup frame
    GuideFrame = true, -- not sure what it is
    KioskSessionFinishedDialog = true, -- popup frame
    MawBuffsBelowMinimapFrame = true, -- does not behave like a window
    MovePadFrame = true, -- movable by default
    NamePlateDriverFrame = true, -- has no visuals
    OrderHallCommandBar = true, -- the bar at the top of the screen
    PerksProgramFrame = true, -- fullscreen frame
    PlayerChoiceFrame = true, -- causes various issues when opening in combat
    PlayerChoiceTimeRemaining = true, -- presumed to have the same issues as PlayerChoiceFrame
    StopwatchFrame = true, -- movable by default
    TableAttributeDisplay = true, -- movable by default
    UIFrameManager = true, -- has no visuals
    UIWidgetManager = true, -- has no visuals
    UIWidgetTopCenterContainerFrame = true, -- not sure what it is
    VoiceChatChannelActivatedNotification = true, -- popup frame, not sure if we want to move it
    VoiceChatPromptActivateChannel = true, -- popup frame, not sure if we want to move it
};
function Module:DumpTopLevelFrames()
    local registeredFrames = {};

    for _, addon in pairs(blizzardAddons) do
        LoadAddOn(addon);
    end
    for _, addon in pairs(BlizzMoveAPI:GetRegisteredAddOns()) do
        LoadAddOn(addon);
        for _, frameName in pairs(BlizzMoveAPI:GetRegisteredFrames(addon)) do
            local frame = BlizzMove:GetFrameFromName(addon, frameName);
            if frame then
                registeredFrames[frame] = true;
            end
        end
    end

    local data = {};
    local frame = EnumerateFrames();
    while frame do
        local name = getFrameName(frame);
        if (
            name
            and not ignoredFrames[name]
            and not registeredFrames[frame]
            and not BlizzMove.FrameData[frame]
            and frame.IsToplevel and frame:IsToplevel()
            and frame.GetParent and (frame:GetParent() == UIParent or frame:GetParent() == nil)
        ) then
            local source = frame.GetSourceLocation and frame:GetSourceLocation() or 'Unknown';
            -- source starts with Interface/AddOns/Blizzard_
            if source:match('Interface/AddOns/Blizzard_(.*)') then
                table.insert(data, {
                    name = name,
                    source = source
                });
            end
        end
        frame = EnumerateFrames(frame);
    end

    local mainFrame = self:GetMainFrame(json.encode(data));
    mainFrame:Show();
end

function Module:GetMainFrame(text)
    -- Frame code largely adapted from the simulationcraft addon
    if not _G.BlizzMoveCopyFrame then
        -- Main Frame
        local f = CreateFrame('Frame', 'BlizzMoveCopyFrame', UIParent, 'DialogBoxFrame');
        f:ClearAllPoints();
        -- load position from local DB
        f:SetPoint(
                self.frameConfig.point,
                self.frameConfig.relativeFrame,
                self.frameConfig.relativePoint,
                self.frameConfig.ofsx,
                self.frameConfig.ofsy
        );
        f:SetSize(self.frameConfig.width, self.frameConfig.height);
        f:SetBackdrop({
            bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
            edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
            edgeSize = 16,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        });
        f:SetMovable(true);
        f:SetClampedToScreen(true);
        f:SetScript('OnMouseDown', function(frame, button)
            if button == 'LeftButton' then
                frame:StartMoving();
            end
        end);
        f:SetScript('OnMouseUp', function(frame, button)
            frame:StopMovingOrSizing();
            -- save position between sessions
            local point, relativeFrame, relativeTo, ofsx, ofsy = frame:GetPoint();
            self.frameConfig.point = point;
            self.frameConfig.relativeFrame = relativeFrame;
            self.frameConfig.relativePoint = relativeTo;
            self.frameConfig.ofsx = ofsx;
            self.frameConfig.ofsy = ofsy;
        end);

        -- scroll frame
        local sf = CreateFrame('ScrollFrame', 'BlizzMoveCopyFrameScrollFrame', f, 'UIPanelScrollFrameTemplate');
        sf:SetPoint('LEFT', 16, 0);
        sf:SetPoint('RIGHT', -32, 0);
        sf:SetPoint('TOP', 0, -32);
        sf:SetPoint('BOTTOM', _G.BlizzMoveCopyFrameButton, 'TOP', 0, 0);

        -- edit box
        local eb = CreateFrame('EditBox', 'BlizzMoveCopyFrameEditBox', _G.BlizzMoveCopyFrameScrollFrame);
        eb:SetSize(sf:GetSize());
        eb:SetMultiLine(true);
        eb:SetAutoFocus(true);
        eb:SetFontObject('ChatFontNormal');
        eb:SetScript('OnEscapePressed', function() f:Hide() end);
        sf:SetScrollChild(eb);

        _G.BlizzMoveCopyFrame = f;
    end
    _G.BlizzMoveCopyFrameEditBox:SetText(text);
    _G.BlizzMoveCopyFrameEditBox:HighlightText();
    return _G.BlizzMoveCopyFrame;
end