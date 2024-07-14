-- upvalue the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local CreateFrame = _G.CreateFrame;
local UIParent = _G.UIParent;
local pairs = _G.pairs;
local C_Console__GetAllCommands = _G.ConsoleGetAllCommands or _G.C_Console.GetAllCommands;
local string__format = _G.string.format;
local string__gmatch = _G.string.gmatch;
local GetCVarInfo = _G.GetCVarInfo;
local IsAddOnLoaded = _G.IsAddOnLoaded or _G.C_AddOns.IsAddOnLoaded;
local GetNumAddOns = _G.GetNumAddOns or _G.C_AddOns.GetNumAddOns;
local GetAddOnInfo = _G.GetAddOnInfo or _G.C_AddOns.GetAddOnInfo;
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata;
local GetFrameMetatable = _G.GetFrameMetatable or function() return getmetatable(CreateFrame('FRAME')) end
local LoadAddOn = _G.LoadAddOn or _G.C_AddOns.LoadAddOn;

--- @type BlizzMove
local BlizzMove = LibStub('AceAddon-3.0'):GetAddon('BlizzMove');
if not BlizzMove then return ; end

--- @class BlizzMove_Debug: AceModule
local Module = BlizzMove:NewModule('Debug')
--- @type BlizzMoveAPI
local BlizzMoveAPI = BlizzMoveAPI;

--- @type JsonLua-1.0
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
Module.bannedCharacterPattern = '[^a-zA-Z0-9 !@#$%^&*()_+\\-=,.:;?~`{}[<>]';

local function encode_string(val)
    return '"' .. val:gsub(Module.bannedCharacterPattern, function(c) return string__format('"..strchar(%d).."', c:byte()); end) .. '"';
end

local function callFrameMethod(frame, method)
    local functionRef = frame[method] or GetFrameMetatable().__index[method] or nop;
    local ok, result = pcall(functionRef, frame);

    return ok and result or false
end

local function getFrameName(frame, fallback)
    return callFrameMethod(frame, 'GetDebugName')
            or callFrameMethod(frame, 'GetName')
            or fallback or 'noName';
end

local function getFrameByName(frameName)
    local frameTable = _G;

    for keyName in string__gmatch(frameName, "([^.]+)") do
        if not frameTable[keyName] then return nil; end

        frameTable = frameTable[keyName];
    end

    return frameTable;
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
                    source = callFrameMethod(child, 'GetSourceLocation') or 'Unknown',
                    targetSource = callFrameMethod(parent, 'GetSourceLocation') or 'Unknown',
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
        local isForbidden = callFrameMethod(frame, 'IsForbidden');
        local isRestricted = not isForbidden and callFrameMethod(frame, 'IsAnchoringRestricted');
        local numPoints = not isRestricted and callFrameMethod(frame, 'GetNumPoints') or 0;
        for i = 1, numPoints do
            local relativeTo = select(2, frame:GetPoint(i));
            if not relativeTo then
                relativeTo = callFrameMethod(frame, 'GetParent') or UIParent;
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

local strataLevels = {
    WORLD = 1,
    BACKGROUND = 2,
    LOW = 3,
    MEDIUM = 4,
    HIGH = 5,
    DIALOG = 6,
    FULLSCREEN = 7,
    FULLSCREEN_DIALOG = 8,
    TOOLTIP = 9,
};
-- list extracted from the listfile @ https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile-withcapitals.csv
local blizzardAddons = { "Blizzard_APIDocumentation", "Blizzard_APIDocumentationGenerated", "Blizzard_APIDocumentationObject", "Blizzard_APIExplorer", "Blizzard_AccountSaveDebug", "Blizzard_AccountSaveUI", "Blizzard_AchievementUI", "Blizzard_ActionBar", "Blizzard_ActionBarController", "Blizzard_ActionStatus", "Blizzard_AddOnList", "Blizzard_AdventureMap", "Blizzard_AlliedRacesUI", "Blizzard_AnimCreate", "Blizzard_AnimaDiversionUI", "Blizzard_ArchaeologyUI", "Blizzard_ArdenwealdGardening", "Blizzard_ArenaUI", "Blizzard_ArrowCalloutFrame", "Blizzard_ArtifactUI", "Blizzard_AuctionHouseShared", "Blizzard_AuctionHouseUI", "Blizzard_AuctionUI", "Blizzard_AuthChallengeUI", "Blizzard_AutoComplete", "Blizzard_AutoXML", "Blizzard_AzeriteEssenceUI", "Blizzard_AzeriteRespecUI", "Blizzard_AzeriteUI", "Blizzard_BNet", "Blizzard_BarbershopUI", "Blizzard_BattlefieldMap", "Blizzard_BehavioralMessaging", "Blizzard_BindingUI", "Blizzard_BlackMarketUI", "Blizzard_BoostTutorial", "Blizzard_BuffFrame", "Blizzard_CUFProfiles", "Blizzard_CachedLogin", "Blizzard_Calendar", "Blizzard_CastingBar", "Blizzard_ChallengesUI", "Blizzard_Channels", "Blizzard_CharacterCreate", "Blizzard_CharacterCustomize", "Blizzard_CharacterFrame", "Blizzard_ChatFrame", "Blizzard_ChatFrameBase", "Blizzard_ChatFrameUtil", "Blizzard_ChromieTimeUI", "Blizzard_ClassMenu", "Blizzard_ClassTalentDebug", "Blizzard_ClassTalentUI", "Blizzard_ClassTrial", "Blizzard_ClassTrialSecure", "Blizzard_ClickBindingUI", "Blizzard_ClientSavedVariables", "Blizzard_Collections", "Blizzard_CombatLog", "Blizzard_CombatText", "Blizzard_Commentator", "Blizzard_Communities", "Blizzard_CommunitiesSecure", "Blizzard_CompactRaidFrames", "Blizzard_Console", "Blizzard_ConsoleExtensions", "Blizzard_ConsoleScriptCollection", "Blizzard_ContentTracking", "Blizzard_Contribution", "Blizzard_CovenantCallings", "Blizzard_CovenantPreviewUI", "Blizzard_CovenantRenown", "Blizzard_CovenantSanctum", "Blizzard_CovenantToasts", "Blizzard_CraftUI", "Blizzard_CursorBrowser", "Blizzard_DeathRecap", "Blizzard_DebugInspectionTool", "Blizzard_DebugLoader", "Blizzard_DebugTools", "Blizzard_DeclensionFrame", "Blizzard_DeclensionFrameGlue", "Blizzard_DelvesCompanionConfiguration", "Blizzard_DelvesDashboardUI", "Blizzard_DelvesDifficultyPicker", "Blizzard_Deprecated", "Blizzard_DeprecatedCurrencyScript", "Blizzard_DeprecatedGuildScript", "Blizzard_DeprecatedItemScript", "Blizzard_DeprecatedPvpScript", "Blizzard_DeprecatedSoundScript", "Blizzard_DeprecatedSpellScript", "Blizzard_Deprecated_ArenaUI", "Blizzard_Dispatcher", "Blizzard_DurabilityFrame", "Blizzard_EditMode", "Blizzard_EncounterJournal", "Blizzard_EngravingUI", "Blizzard_EnvironmentCleanup", "Blizzard_EventTrace", "Blizzard_ExpansionLandingPage", "Blizzard_ExpansionTrial", "Blizzard_FlightMap", "Blizzard_FontStyles_Frame", "Blizzard_FontStyles_Glue", "Blizzard_FontStyles_Shared", "Blizzard_Fonts_Frame", "Blizzard_Fonts_Glue", "Blizzard_Fonts_Shared", "Blizzard_FrameEffects", "Blizzard_FrameStack", "Blizzard_FrameXML", "Blizzard_FrameXMLBase", "Blizzard_FrameXMLUtil", "Blizzard_FramerateFrame", "Blizzard_FriendsFrame", "Blizzard_GMChatUI", "Blizzard_GameMenu", "Blizzard_GameTooltip", "Blizzard_GarrisonBase", "Blizzard_GarrisonTemplates", "Blizzard_GarrisonUI", "Blizzard_GenericTraitUI", "Blizzard_GlobalFXModelScenes", "Blizzard_GlueDialogs", "Blizzard_GlueParent", "Blizzard_GlueSavedVariables", "Blizzard_GlueStubs", "Blizzard_GlueXML", "Blizzard_GlueXMLBase", "Blizzard_GlyphUI", "Blizzard_GroupFinder", "Blizzard_GuildBankUI", "Blizzard_GuildControlUI", "Blizzard_HelpFrame", "Blizzard_HunterStableDebug", "Blizzard_HybridMinimap", "Blizzard_IME", "Blizzard_ImageEditor", "Blizzard_ImmersiveInteractionUI", "Blizzard_InspectUI", "Blizzard_IslandsPartyPoseUI", "Blizzard_IslandsQueueUI", "Blizzard_ItemAlterationUI", "Blizzard_ItemBeltFrame", "Blizzard_ItemButton", "Blizzard_ItemInteractionUI", "Blizzard_ItemSocketingUI", "Blizzard_ItemUpgradeDebug", "Blizzard_ItemUpgradeUI", "Blizzard_Kiosk", "Blizzard_LandingSoulbinds", "Blizzard_LevelUpDisplay", "Blizzard_LoadLocale", "Blizzard_LoginErrorHelpers", "Blizzard_LookingForGroupUI", "Blizzard_LuaDebugWindow", "Blizzard_MacroUI", "Blizzard_MailFrame", "Blizzard_MainMenuBarBagButtons", "Blizzard_MainlineSettings", "Blizzard_MajorFactions", "Blizzard_MapCanvas", "Blizzard_MatchCelebrationPartyPoseUI", "Blizzard_MawBuffs", "Blizzard_Menu", "Blizzard_MenuDebug", "Blizzard_Minimap", "Blizzard_MirrorTimer", "Blizzard_MoneyFrame", "Blizzard_MoneyReceipt", "Blizzard_MovePad", "Blizzard_NamePlates", "Blizzard_NewPlayerExperience", "Blizzard_NewPlayerExperienceGuide", "Blizzard_ObjectAPI", "Blizzard_ObjectiveTracker", "Blizzard_ObliterumUI", "Blizzard_Options_Frame", "Blizzard_Options_Frame_Legacy", "Blizzard_Options_Glue", "Blizzard_Options_GlueAudio", "Blizzard_OrderHallUI", "Blizzard_OverrideActionBar", "Blizzard_POIButton", "Blizzard_PTRFeedback", "Blizzard_PTRFeedbackGlue", "Blizzard_PVPMatch", "Blizzard_PVPUI", "Blizzard_PagedContent", "Blizzard_PagedContentDebug", "Blizzard_PartyPoseUI", "Blizzard_PerksActivitiesDebug", "Blizzard_PerksProgram", "Blizzard_PerksProgramDebug", "Blizzard_PerksProgramDevTool", "Blizzard_PetBattleUI", "Blizzard_PetJournal", "Blizzard_PingUI", "Blizzard_PlayerChoice", "Blizzard_PlayerSpells", "Blizzard_PlunderstormBasics", "Blizzard_PrintHandler", "Blizzard_PrivateAurasUI", "Blizzard_ProfSpecsImporter", "Blizzard_Professions", "Blizzard_ProfessionsBook", "Blizzard_ProfessionsCustomerOrders", "Blizzard_ProfessionsDebug", "Blizzard_ProfessionsTemplates", "Blizzard_PrototypeDialog", "Blizzard_QuestNavigation", "Blizzard_QuestNextQuestLog", "Blizzard_QueueStatusFrame", "Blizzard_QuickJoin", "Blizzard_QuickKeybind", "Blizzard_RPCLogging", "Blizzard_RadialWheel", "Blizzard_RaidFrame", "Blizzard_RaidUI", "Blizzard_ReadyCheck", "Blizzard_RecruitAFriend", "Blizzard_ReforgingUI", "Blizzard_RenownDebug", "Blizzard_ReportFrame", "Blizzard_ReportFrameGlue", "Blizzard_ReportFrameShared", "Blizzard_RuneforgeUI", "Blizzard_ScrappingMachineUI", "Blizzard_ScriptedAnimationsTest", "Blizzard_ScrollBoxDebug", "Blizzard_SecureCapsule", "Blizzard_SecureTransferUI", "Blizzard_SelectorUI", "Blizzard_Settings", "Blizzard_SettingsDebug", "Blizzard_SettingsDefinitions_Frame", "Blizzard_SettingsDefinitions_Shared", "Blizzard_Settings_Shared", "Blizzard_SharedMapDataProviders", "Blizzard_SharedTalentUI", "Blizzard_SharedWidgetFrames", "Blizzard_SharedXML", "Blizzard_SharedXMLBase", "Blizzard_SharedXMLGame", "Blizzard_SocialToast", "Blizzard_Soulbinds", "Blizzard_SoulbindsDebug", "Blizzard_SpectateFrame", "Blizzard_SpellSearch", "Blizzard_StableUI", "Blizzard_StaticPopup", "Blizzard_StaticPopup_Frame", "Blizzard_StoreUI", "Blizzard_SubscriptionInterstitialUI", "Blizzard_Subtitles", "Blizzard_TalentTestAPI", "Blizzard_TalentTestData", "Blizzard_TalentTestUI", "Blizzard_TalentUI", "Blizzard_TestBNSendGameData", "Blizzard_TestDataset", "Blizzard_TestDatasetEditor", "Blizzard_TestFrame", "Blizzard_TestWithPublicAddons", "Blizzard_TestingMode", "Blizzard_TextStatusBar", "Blizzard_TimeEvents", "Blizzard_TimeManager", "Blizzard_TimerunningCharacterCreate", "Blizzard_TimerunningUtil", "Blizzard_TokenUI", "Blizzard_ToolsUI", "Blizzard_TorghastLevelPicker", "Blizzard_TradeSkillUI", "Blizzard_TrainerUI", "Blizzard_TransformTree", "Blizzard_TutorialManager", "Blizzard_Tutorials", "Blizzard_UIErrorsFrame", "Blizzard_UIFrameManager", "Blizzard_UIMenu", "Blizzard_UIModelSceneEditor", "Blizzard_UIPanelTemplates", "Blizzard_UIPanels_Game", "Blizzard_UIParent", "Blizzard_UIParentDebug", "Blizzard_UIParentPanelManager", "Blizzard_UIWidgets", "Blizzard_UndoSystem", "Blizzard_UnitFrame", "Blizzard_UnitFrameUtil", "Blizzard_UnitPopup", "Blizzard_UnitPopupShared", "Blizzard_Utility", "Blizzard_VexData", "Blizzard_VexToolUI", "Blizzard_VexViewerUI", "Blizzard_VideoOptions_Shared", "Blizzard_VoiceToggleButton", "Blizzard_VoidStorageUI", "Blizzard_WarboardUI", "Blizzard_WarfrontsPartyPoseUI", "Blizzard_WeeklyRewards", "Blizzard_WeeklyRewardsUtil", "Blizzard_WorldMap", "Blizzard_WowTokenUI", "Blizzard_ZoneAbility" };
-- manual list of Toplevel frames that we don't handle on purpose
local ignoredFrames = {
    AuctionHouseMultisellProgressFrame = true, -- popup frame
    AuctionProgressFrame = true, -- popup frame
    AudioOptionsFrame = true, -- broken frame
    BarbersChoiceConfirmFrame = true, -- popup frame
    BarberShopBannerFrame = true, -- graphic at the top of the screen in classic
    BarberShopFrame = true, -- fullscreen frame
    BattlefieldMapFrame = true, -- movable by default
    BonusRollFrame = true, -- not a window
    ChatMenu = true, -- popup menu
    ClassTrialThanksForPlayingDialog = true, -- popup frame
    CoinPickupFrame = true, -- popup frame
    ColorPickerFrame = true, -- movable by default
    CombatText = true, -- seems to be scrolling combat text - don't move it
    ComboFrame = true, -- not sure what it is
    CommentatorEventAlertsFrame = true, -- unsure what it is, might be commentator-mode only
    CommunitiesAvatarPickerDialog = true, -- fullscreen popup frame
    CommunitiesTicketManagerDialog = true, -- popup frame, not sure if we want to move it
    CompactRaidFrameManager = true, -- does not behave like a window
    ContainerFrame1 = true, -- bags
    ContainerFrame2 = true, -- bags
    ContainerFrame3 = true, -- bags
    ContainerFrame4 = true, -- bags
    ContainerFrame5 = true, -- bags
    ContainerFrame6 = true, -- bags
    ContainerFrame7 = true, -- bags
    ContainerFrame8 = true, -- bags
    ContainerFrame9 = true, -- bags
    ContainerFrame10 = true, -- bags
    ContainerFrame11 = true, -- bags
    ContainerFrame12 = true, -- bags
    ContainerFrame13 = true, -- bags
    ContainerFrameContainer = true, -- not a window
    DeadlyDebuffFrame = true, -- not a window
    EventToastManagerFrame = true, -- not a window
    EventTrace = true, -- movable by default
    ExpansionTrialCheckPointDialog = true, -- popup frame
    ExpansionTrialThanksForPlayingDialog = true, -- popup frame
    FolderPicker = true, -- some mac only thing, not sure what it's for
    GMChatFrame = true, -- movable by default
    GMChatStatusFrame = true, -- popup frame
    GroupLootFrame1 = true, -- popup frame
    GroupLootFrame2 = true, -- popup frame
    GroupLootFrame3 = true, -- popup frame
    GroupLootFrame4 = true, -- popup frame
    GroupLootHistoryFrame = true, -- movable by default
    GuideFrame = true, -- not sure what it is
    IconIntroTracker = true, -- has no visuals
    KioskSessionFinishedDialog = true, -- popup frame
    KioskSessionStartedDialog = true, -- popup frame
    LevelUpDisplay = true, -- not a window
    LossOfControlFrame = true, -- not a window
    MawBuffsBelowMinimapFrame = true, -- does not behave like a window
    MirrorTimer1 = true, -- not a window
    MirrorTimer2 = true, -- not a window
    MirrorTimer3 = true, -- not a window
    MovePadFrame = true, -- movable by default
    MultiBarLeft = true, -- not a window
    NamePlateDriverFrame = true, -- has no visuals
    OpacityFrame = true, -- not sure if it's still used?
    OrderHallCommandBar = true, -- the bar at the top of the screen
    OverrideActionBar = true, -- the vehicle UI
    PerksProgramFrame = true, -- fullscreen frame
    PlayerChoiceFrame = true, -- causes various issues when opening in combat
    PlayerChoiceTimeRemaining = true, -- presumed to have the same issues as PlayerChoiceFrame
    PlayerInteractionFrameManager = true, -- has no visuals
    PrivateRaidBossEmoteFrameAnchor = true, -- has no visuals
    PVPReadyDialog = true, -- popup frame
    RaidBossEmoteFrame = true, -- not a window
    RaidParentFrame = true, -- unused weird window
    RaidWarningFrame = true, -- not a window
    RatingMenuFrame = true, -- popup, and korean only, and maybe only a placeholder?
    ReportFrame = true, -- popup frame
    SideDressUpFrame = true, -- has no header or anything else to move, draging rotates the model
    StackSplitFrame = true, -- popup frame
    StaticPopup1 = true, -- popup frame
    StaticPopup2 = true, -- popup frame
    StaticPopup3 = true, -- popup frame
    StaticPopup4 = true, -- popup frame
    StopwatchFrame = true, -- movable by default
    StreamingIcon = true, -- not a window
    TableAttributeDisplay = true, -- movable by default
    TicketStatusFrame = true, -- not a window
    TutorialFrameParent = true, -- not a window
    TutorialKeyboardMouseFrame_Frame = true, -- popup frame
    UIFrameManager = true, -- has no visuals
    UIWidgetManager = true, -- has no visuals
    UIWidgetTopCenterContainerFrame = true, -- not sure what it is
    VoiceChatChannelActivatedNotification = true, -- popup frame, not sure if we want to move it
    VoiceChatPromptActivateChannel = true, -- popup frame, not sure if we want to move it
    WorldMapFrame = true, -- fullscreen on classic
};
function Module:DumpTopLevelFrames()
    local registeredFrames = {};

    for _, addon in pairs(blizzardAddons) do
        pcall(LoadAddOn, addon);
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
        local name = getFrameName(frame, 'NoName');
        if (
            name and name ~= 'NoName'
            and getFrameByName(name) == frame
            and name:sub(-7) ~= 'Tooltip'
            and not ignoredFrames[name]
            and not registeredFrames[frame]
            and not BlizzMove.FrameData[frame]
            and callFrameMethod(frame, 'IsToplevel')
            and callFrameMethod(frame, 'GetObjectType') == 'Frame'
            and (callFrameMethod(frame, 'GetParent') == UIParent or callFrameMethod(frame, 'GetParent') == nil)
            and (strataLevels[callFrameMethod(frame, 'GetFrameStrata')] or 1) >= strataLevels.MEDIUM
        ) then
            local source = callFrameMethod(frame, 'GetSourceLocation') or 'Unknown';
            -- source starts with Interface/AddOns/Blizzard_, or is outside Interface/AddOns/
            if source:match('Interface/AddOns/Blizzard_(.*)') or (source:match('Interface/.*') and not source:match('Interface/AddOns/.*')) then
                table.insert(data, {
                    name = name,
                    source = source,
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