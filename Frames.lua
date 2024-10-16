--- @type BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI
if not BlizzMoveAPI then return; end

BlizzMoveAPI:RegisterFrames(
{
    ["AddonList"] =
    {
        MinVersion = 0,
    },
    ["BankFrame"] =
    {
        MinVersion = 0,
    },
    ["BattlefieldFrame"] =
    {
        MinVersion = 0,
        MaxVersion = 30400, -- Moved to PVPParentFrame
        SilenceCompatabilityWarnings = true,
    },
    ["CharacterFrame"] =
    {
        MinVersion = 0,
        SubFrames =
        {
            ["PaperDollFrame"] = {},
            ["PetPaperDollFrame"] =
            {
                MaxVersion = 70300, -- Removed when?
                SubFrames =
                {
                    ["PetPaperDollFrameCompanionFrame"] =
                    {
                        MinVersion = 30000,
                        MaxVersion = 40400,
                    },
                },
            },
            ["CompanionFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 70300, -- Removed when?
            },
            ["ReputationFrame"] =
            {
                SubFrames =
                {
                    ["ReputationDetailFrame"] =
                    {
                        Detachable = true,
                        MaxVersion = 110000,
                    },
                    ["ReputationFrame.ReputationDetailFrame"] =
                    {
                        Detachable = true,
                        MinVersion = 110000,
                    },
                },
            },
            ["SkillFrame"] =
            {
                MaxVersion = 70300, -- Removed when?
            },
            ["HonorFrame"] =
            {
                MaxVersion = 20000, -- Added back in cata, and moved to PVPFrame
                SilenceCompatabilityWarnings = true,
            },
            ["PVPFrame"] =
            {
                MinVersion = 20000,
                MaxVersion = 30000, -- Moved to PVPParentFrame in wrath, then extracted to its own frame in cata
                SilenceCompatabilityWarnings = true,
                SubFrames =
                {
                    ["PVPFrameHonor"] = {},
                    ["PVPFrameArena"] = {},
                    ["PVPTeam1"] = {},
                    ["PVPTeam2"] = {},
                    ["PVPTeam3"] = {},
                },
            },
            ["TokenFrame"] =
            {
                VersionRanges =
                {
                    { Min = 11404, Max = 20000 }, -- exists, but does nothing
                    { Min = 30000 },
                },
                SubFrames =
                {
                    ["TokenFramePopup"] =
                    {
                        Detachable = true,
                    },
                    ["TokenFrameContainer"] =
                    {
                        MaxVersion = 100000,
                    },
                    ["CurrencyTransferLog"] =
                    {
                        MinVersion = 110000,
                        Detachable = true,
                    },
                },
            },
        },
    },
    ["ChatConfigFrame"] =
    {
        MinVersion = 0,
    },
    ["ContainerFrame1"] =
    {
        MinVersion = 100000,
         -- while it does indeed exist in classic, blizzard does not make other bags follow its position automatically like in retail
        SilenceCompatabilityWarnings = true,
        SubFrames =
        {
            ["ContainerFrame1.TitleContainer"] =
            {
                MinVersion = 110000,
            },
        },
    },
    ["ContainerFrameCombinedBags"] =
    {
        MinVersion = 100000,
        SubFrames =
        {
            ["ContainerFrameCombinedBags.TitleContainer"] =
            {
                MinVersion = 110000,
            },
        },
    },
    ["DestinyFrame"] =
    {
        MinVersion = 50000,
    },
    ["DressUpFrame"] =
    {
        MinVersion = 0,
        SubFrames =
        {
            ["DressUpFrame.OutfitDetailsPanel"] =
            {
                MinVersion = 90105,
                Detachable = true,
            },
        },
    },
    ["FriendsFrame"] =
    {
        MinVersion = 0,
        SubFrames =
        {
            ["IgnoreListFrameScrollFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 100000,
            },
            ["RaidInfoFrame"] =
            {
                Detachable = true,
                SubFrames =
                {
                    ["RaidInfoScrollFrame"] =
                    {
                        MaxVersion = 100000,
                    },
                },
            },
            ["RecruitAFriendFrame.RecruitList.ScrollFrame"] =
            {
                MinVersion = 90000, -- Added when?
                MaxVersion = 100000,
            },
            ["FriendsFrameBattlenetFrame.BroadcastFrame"] =
            {
                Detachable = true,
            },
            ["FriendsListFrameScrollFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 100000,
            },
            ["FriendsFrameFriendsScrollFrame"] =
            {
                MaxVersion = 50000, -- Removed when?
            },
            ["QuickJoinScrollFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 100000,
            },
            ["WhoListScrollFrame"] =
            {
                MinVersion = 40000, -- check comment below
                MaxVersion = 100000,
                SilenceCompatabilityWarnings = true,
                -- Classic: Not required, but does not break anything.
                -- TBC: Not required, but breaks clicking on results other then the first.
                -- Wrath: Not required, but breaks clicking on results other then the first.
                -- Shadowlands: Required.
                -- Dragonflight: Not required, and renamed
            },
            ["GuildFrame"] =
            {
                MaxVersion = 50000, -- Moved to Blizzard_GuildUI when?
                SubFrames =
                {
                    ["GuildInfoFrame"] =
                    {
                        Detachable = true,
                        SubFrames =
                        {
                            ["GuildInfoFrameScrollFrame"] = {},
                        },
                    },
                    ["GuildEventLogFrame"] =
                    {
                        MinVersion = 30000,
                        Detachable = true,
                    },
                },
            },
        },
    },
    ["GameMenuFrame"] =
    {
        MinVersion = 0,
        SubFrames =
        {
            ["GameMenuFrame.Header"] =
            {
                MinVersion = 110000,
            },
        },
    },
    ["GossipFrame"] =
    {
        MinVersion = 0,
    },
    ["GuildInviteFrame"] =
    {
        MinVersion = 50000, -- Added when?
    },
    ["GuildRegistrarFrame"] =
    {
        MinVersion = 0,
    },
    ["HelpFrame"] =
    {
        MinVersion = 0,
    },
    ["InterfaceOptionsFrame"] =
    {
        VersionRanges = {
            { Min = 0, Max = 11503 },
            { Min = 40000, Max = 40400 },
        },
        MaxVersion = 100000,
    },
    ["ItemTextFrame"] =
    {
        MinVersion = 0,
    },
    ["LFGParentFrame"] =
    {
        MinVersion = 20502,
        MaxVersion = 20503, -- Moved to Blizzard_LookingForGroupUI
    },
    ["LootFrame"] =
    {
        MinVersion = 0,
    },
    ["MailFrame"] =
    {
        MinVersion = 0,
        SubFrames =
        {
            ["SendMailFrame"] = {},
            ["MailFrameInset"] =
            {
                ForceParentage = true,
            },
            ["OpenMailFrame"] =
            {
                Detachable = true,
                ManuallyScaleWithParent = true,
                SubFrames =
                {
                    ["OpenMailSender"] = {},
                    ["OpenMailFrameInset"] =
                    {
                        ForceParentage = true,
                    },
                },
            },
        },
    },
    ["MerchantFrame"] =
    {
        MinVersion = 0,
    },
    ["ModelPreviewFrame"] =
    {
        MinVersion = 0,
    },
    ["PetitionFrame"] =
    {
        MinVersion = 0,
    },
    ["PetStableFrame"] =
    {
        MinVersion = 0,
        MaxVersion = 100207,
    },
    ["PingSystemTutorial"] =
    {
        MinVersion = 100107,
    },
    ["PVEFrame"] =
    {
        MinVersion = 30403,
        SilenceCompatabilityWarnings = true, -- frame exists in classic, but is not functional
        SubFrames =
        {
            ["LFGListApplicationViewerScrollFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 100000,
            },
            ["LFGListFrame.ApplicationViewer.UnempoweredCover"] = {},
            ["LFGListSearchPanelScrollFrame"] =
            {
                MinVersion = 50000, -- Added when?
                MaxVersion = 100000,
                IgnoreMouseWheel = true,
            },
            ["ScenarioQueueFrameSpecific"] =
            {
                VersionRanges =
                {
                    { Min = 50000, Max = 90000 }, -- Added when?
                    { Min = 100207 },
                },
            },
        },
    },
    ["PVPFrame"] =
    {
        MinVersion = 40400, -- Moved out of PVPParentFrame
        MaxVersion = 70300, -- Removed when?
        SilenceCompatabilityWarnings = true,
        SubFrames =
        {
            ["PVPHonorFrame"] = {},
            ["PVPConquestFrame"] = {},
            ["WarGamesFrame"] = {},
        },
    },
    ["PVPParentFrame"] =
    {
        MinVersion = 30000,
        MaxVersion = 40400,
        SubFrames =
        {
            ["BattlefieldFrame"] =
            {
                MinVersion = 30400, -- Moved from FrameXML
                MaxVersion = 70300, -- Removed when?
                SilenceCompatabilityWarnings = true,
            },
            ["PVPFrame"] =
            {
                MinVersion = 30000, -- Moved from CharacterFrame
                MaxVersion = 70300, -- Removed when?
                SilenceCompatabilityWarnings = true,
                SubFrames =
                {
                    ["PVPFrameHonor"] = {},
                    ["PVPFrameArena"] = {},
                    ["PVPTeam1"] = {},
                    ["PVPTeam2"] = {},
                    ["PVPTeam3"] = {},
                },
            },
        },
    },
    ["QuestFrame"] =
    {
        MinVersion = 0,
    },
    ["QuestLogFrame"] =
    {
        MinVersion = 0,
        MaxVersion = 70300, -- Removed when?
    },
    ["QuestLogDetailFrame"] =
    {
        MinVersion = 30000,
        MaxVersion = 70300, -- Removed when?
    },
    ["QuestLogPopupDetailFrame"] =
    {
        MinVersion = 50000, -- Added when?
    },
    ["QuickKeybindFrame"] =
    {
        MinVersion = 100000, -- Moved from Blizzard_BindingUI
        SilenceCompatabilityWarnings = true,
    },
    ["ReadyCheckFrame"] =
    {
        MinVersion = 0,
    },
    ["RecruitAFriendRecruitmentFrame"] =
    {
        MinVersion = 50000, -- Added when?
    },
    ["RecruitAFriendRewardsFrame"] =
    {
        MinVersion = 82000, -- Added when?
    },
    ["SettingsPanel"] =
    {
        VersionRanges =
        {
            { Min = 11404, Max = 20000 }, -- Backported in Classic 1.14.4
            { Min = 30402, Max = 40000 }, -- Backported in Wrath 3.4.2
            { Min = 40400, Max = 50000 },
            { Min = 100000 }, -- Added in DF
        },
    },
    ["SpellBookFrame"] =
    {
        MinVersion = 0,
        MaxVersion = 110000, -- Moved into Blizzard_PlayerSpells - PlayerSpellsFrame
    },
    ["SplashFrame"] =
    {
        MinVersion = 50000, -- Added when?
    },
    ["TabardFrame"] =
    {
        MinVersion = 0,
    },
    ["TalkingHeadFrame"] =
    {
        MinVersion = 100000, -- Moved from Blizzard_TalkingHeadUI
        SilenceCompatabilityWarnings = true,
    },
    ["TaxiFrame"] =
    {
        MinVersion = 0,
    },
    ["TradeFrame"] =
    {
        MinVersion = 0,
    },
    ["TutorialFrame"] =
    {
        MinVersion = 0,
    },
    ["VideoOptionsFrame"] =
    {
        VersionRanges = {
            { Min = 0, Max = 11503 },
            { Min = 40000, Max = 40400 },
        },
        MaxVersion = 100000,
    },
    ["WorldMapFrame"] =
    {
        MinVersion = 40000, -- No longer fullscreen when?
        SilenceCompatabilityWarnings = true,
        IgnoreSavedPositionWhenMaximized = true,
        SubFrames =
        {
            ["QuestMapFrame"] =
            {
                SubFrames =
                {
                    ["QuestMapFrame.DetailsFrame.RewardsFrame"] = {
                        MaxVersion = 110000,
                    },
                    ["QuestMapFrame.DetailsFrame.ScrollFrame"] = {},
                },
            },
        },
    },
    ["WorldStateScoreFrame"] =
    {
        MinVersion = 0,
        MaxVersion = 70300, -- Removed when?
    },
});

BlizzMoveAPI:RegisterAddOnFrames(
{
    ["Blizzard_AchievementUI"] =
    {
        ["AchievementFrame"] =
        {
            VersionRanges =
            {
                { Min = 11404, Max = 20000 }, -- Backported in a broken state in Classic 1.14.4
                { Min = 30000 },
            },
            SubFrames =
            {
                ["AchievementFrameHeader"] =
                {
                    MaxVersion = 100000,
                },
                ["AchievementFrame.Header"] =
                {
                    MinVersion = 100000,
                },
                ["AchievementFrameCategoriesContainer"] =
                {
                    MaxVersion = 100000,
                },
                ["AchievementFrameAchievementsContainer"] =
                {
                    MaxVersion = 100000,
                },
            },
        },
        ["AchievementFrame.searchResults"] =
        {
            MinVersion = 50000, -- Added when?
            MaxVersion = 100000,
        },
        ["AchievementFrame.SearchResults"] =
        {
            MinVersion = 100000,
        },
    },
    ["Blizzard_AlliedRacesUI"] =
    {
        ["AlliedRacesFrame"] =
        {
            MinVersion = 70300,
        },
    },
    ["Blizzard_AnimaDiversionUI"] =
    {
        ["AnimaDiversionFrame"] =
        {
            MinVersion = 90000,
            SubFrames =
            {
                ["AnimaDiversionFrame.ScrollContainer"] = {},
                ["AnimaDiversionFrame.ReinforceProgressFrame"] = {},
            },
        },
    },
    ["Blizzard_ArchaeologyUI"] =
    {
        ["ArchaeologyFrame"] =
        {
            MinVersion = 40000,
        },
        ["ArcheologyDigsiteProgressBar"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_ArtifactUI"] =
    {
        ["ArtifactFrame"] =
        {
            MinVersion = 70000,
        },
        ["ArtifactRelicForgeFrame"] =
        {
            MinVersion = 70300,
            MaxVersion = 70300,
        },
    },
    ["Blizzard_AuctionHouseUI"] =
    {
        ["AuctionHouseFrame"] =
        {
            MinVersion = 80300,
        },
    },
    ["Blizzard_AuctionUI"] =
    {
        ["AuctionFrame"] =
        {
            MinVersion = 0,
            MaxVersion = 80300,
        },
    },
    ["Blizzard_AzeriteEssenceUI"] =
    {
        ["AzeriteEssenceUI"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_AzeriteRespecUI"] =
    {
        ["AzeriteRespecFrame"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_AzeriteUI"] =
    {
        ["AzeriteEmpoweredItemUI"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_BarbershopUI"] =
    {
        ["BarberShopFrame"] =
        {
            MinVersion = 30000,
            MaxVersion = 90000, -- still exists, but shouldn't be movable (fullscreen)
            SilenceCompatabilityWarnings = true
        },
    },
    ["Blizzard_BehavioralMessaging"] =
    {
        ["BehavioralMessagingDetails"] =
        {
            MinVersion = 0, -- Added when?
        },
    },
    ["Blizzard_BindingUI"] =
    {
        ["KeyBindingFrame"] =
        {
            MinVersion = 0,
            MaxVersion = 100000,
        },
        ["QuickKeybindFrame"] =
        {
            MinVersion = 50000, -- Added when?
            MaxVersion = 100000, -- Moved to FrameXML
            SilenceCompatabilityWarnings = true,
        },
    },
    ["Blizzard_BlackMarketUI"] =
    {
        ["BlackMarketFrame"] =
        {
            MinVersion = 50000,
        },
    },
    ["Blizzard_Calendar"] =
    {
        ["CalendarFrame"] =
        {
            VersionRanges =
            {
                { Min = 11404, Max = 20000 }, -- exists, in a partially broken state
                { Min = 30000 },
            },
            SubFrames =
            {
                ["CalendarCreateEventFrame"] =
                {
                    Detachable = true,
                    SubFrames =
                    {
                        ["CalendarCreateEventInviteListScrollFrame"] =
                        {
                            MinVersion = 50000, -- Added when?
                            MaxVersion = 100000,
                        },
                    },
                },
                ["CalendarViewEventFrame"] =
                {
                    Detachable = true,
                    SubFrames =
                    {
                        ["CalendarViewEventFrame.HeaderFrame"] = {},
                        ["CalendarViewEventInviteListScrollFrame"] =
                        {
                            MinVersion = 50000, -- Added when?
                            MaxVersion = 100000,
                        },
                    },
                },
                ["CalendarViewHolidayFrame"] =
                {
                    Detachable = true,
                },
            },
        },
    },
    ["Blizzard_ChallengesUI"] =
    {
        ["ChallengesKeystoneFrame"] =
        {
            MinVersion = 70000,
        },
    },
    ["Blizzard_Channels"] =
    {
        ["ChannelFrame"] =
        {
            MinVersion = 0,
        },
    },
    ["Blizzard_ChromieTimeUI"] =
    {
        ["ChromieTimeFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_ClassTalentUI"] =
    {
        ["ClassTalentFrame"] =
        {
            MinVersion = 100000,
            MaxVersion = 110000,
            SubFrames =
            {
                ["ClassTalentFrame.TalentsTab.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_ClickBindingUI"] =
    {
        ["ClickBindingFrame"] =
        {
            MinVersion = 90200,
            SubFrames =
            {
                ["ClickBindingFrame.ScrollBox"] = {},
            },
        },
        ["ClickBindingFrame.TutorialFrame"] =
        {
            MinVersion = 90200,
        },
    },
    ["Blizzard_Collections"] =
    {
        ["CollectionsJournal"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 }, -- Backported in a broken state
                { Min = 30403 },
            },
            SubFrames =
            {
                ["CollectionsJournal.TitleContainer"] =
                {
                    MinVersion = 100000,
                },
            },
        },
        ["WardrobeFrame"] =
        {
            MinVersion = 40000,
        },
    },
    ["Blizzard_Communities"] =
    {
        ["ClubFinderGuildFinderFrame.RequestToJoinFrame"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 },
                { Min = 40000 },
            },
        },
        -- ["CommunitiesAddDialog"] = {}, -- Frame is protected, similar to the Store frame
        ["CommunitiesFrame"] =
        {
            MinVersion = 0, -- Backported into classic from retail (with limited functionality)
            SubFrames =
            {
                ["ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ListScrollFrame"] =
                {
                    MinVersion = 50000, -- Added when?
                    MaxVersion = 100000,
                },
                ["CommunitiesFrame.GuildMemberDetailFrame"] =
                {
                    Detachable = true,
                    VersionRanges =
                    {
                        { Min = 11503, Max = 20000 },
                        { Min = 40000 },
                    },
                },
                ["CommunitiesFrame.NotificationSettingsDialog"] = {},
            },
        },
        ["CommunitiesFrame.RecruitmentDialog"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 },
                { Min = 40000 },
            },
        },
        ["CommunitiesSettingsDialog"] =
        {
            MinVersion = 0, -- Added when?
        },
        ["CommunitiesGuildLogFrame"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 },
                { Min = 40000 },
            },
        },
        ["CommunitiesGuildNewsFiltersFrame"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 },
                { Min = 40000 },
            },
        },
        ["CommunitiesGuildTextEditFrame"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 },
                { Min = 40000 },
            },
        },
    },
    ["Blizzard_Contribution"] =
    {
        ["ContributionCollectionFrame"] =
        {
            MinVersion = 40000,
        },
    },
    ["Blizzard_CovenantPreviewUI"] =
    {
        ["CovenantPreviewFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_CovenantRenown"] =
    {
        ["CovenantRenownFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_CovenantSanctum"] =
    {
        ["CovenantSanctumFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_CraftUI"] =
    {
        ["CraftFrame"] =
        {
            MaxVersion = 70300, -- When was this fully replaced with TradeSkillFrame? Most frames where changed in 11306, but seems this is still used in TBC.
        },
    },
    ["Blizzard_DeathRecap"] =
    {
        ["DeathRecapFrame"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_DelvesCompanionConfiguration"] =
    {
        ["DelvesCompanionAbilityListFrame"] =
        {
            MinVersion = 110000,
        },
        ["DelvesCompanionConfigurationFrame"] =
        {
            MinVersion = 110000,
        },
    },
    ["Blizzard_DelvesDifficultyPicker"] =
    {
        ["DelvesDifficultyPickerFrame"] =
        {
            MinVersion = 110000,
        },
    },
    ["Blizzard_EncounterJournal"] =
    {
        ["EncounterJournal"] =
        {
            MinVersion = 40000,
            SubFrames =
            {
                ["EncounterJournal.instanceSelect.scroll"] =
                {
                    VersionRanges =
                    {
                        { Max = 40400 },
                        { Min = 50000, Max = 100000 },
                    },
                },
                ["EncounterJournal.instanceSelect.ScrollBox"] =
                {
                    VersionRanges =
                    {
                        { Min = 40400, Max = 50000 },
                        { Min = 100000 },
                    },
                },
                ["EncounterJournal.encounter.instance.loreScroll"] =
                {
                    VersionRanges =
                    {
                        { Max = 40400 },
                        { Min = 50000, Max = 100000 },
                    },
                },
                ["EncounterJournal.encounter.info.overviewScroll"] = {},
                ["EncounterJournal.encounter.info.lootScroll"] =
                {
                    VersionRanges =
                    {
                        { Max = 40400 },
                        { Min = 50000, Max = 100000 },
                    },
                },
                ["EncounterJournal.encounter.info.detailsScroll"] = {},
                ["EncounterJournal.encounter.info.model"] =
                {
                    NonDraggable = true,
                },
            },
        },
    },
    ["Blizzard_ExpansionLandingPage"] =
    {
        ["ExpansionLandingPage"] =
        {
            MinVersion = 100000,
        },
    },
    ["Blizzard_FlightMap"] =
    {
        ["FlightMapFrame"] =
        {
            MinVersion = 0,
        },
    },
    ["Blizzard_GarrisonUI"] =
    {
        ["GarrisonBuildingFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonCapacitiveDisplayFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonLandingPage"] =
        {
            MinVersion = 60000,
            SubFrames =
            {
                ["GarrisonLandingPageReportListListScrollFrame"] =
                {
                    MaxVersion = 100000,
                },
                ["GarrisonLandingPageFollowerListListScrollFrame"] =
                {
                    MaxVersion = 100000,
                },
            },
        },
        ["GarrisonMissionFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonMonumentFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonRecruiterFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonRecruitSelectFrame"] =
        {
            MinVersion = 60000,
        },
        ["GarrisonShipyardFrame"] =
        {
            MinVersion = 60000,
        },
        ["OrderHallMissionFrame"] =
        {
            MinVersion = 70000,
        },
        ["BFAMissionFrame"] =
        {
            MinVersion = 80000,
        },
        ["CovenantMissionFrame"] =
        {
            MinVersion = 90000,
            SubFrames =
            {
                ["CovenantMissionFrame.MissionTab"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage.CostFrame"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage.StartMissionFrame"] = {},
                ["CovenantMissionFrame.MissionTab.MissionList.MaterialFrame"] = {},
                ["CovenantMissionFrame.FollowerList.listScroll"] =
                {
                    MaxVersion = 100000,
                },
                ["CovenantMissionFrame.FollowerList.MaterialFrame"] = {},
            },
        },
    },
    ["Blizzard_GenericTraitUI"] =
    {
        ["GenericTraitFrame"] =
        {
            MinVersion = 100000,
            SubFrames =
            {
                ["GenericTraitFrame.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_GlyphUI"] =
    {
        ["PlayerTalentFrame"] =
        {
            MinVersion = 11401,
            MaxVersion = 110000, -- Unused in DF, but only removed in TWW
            SubFrames =
            {
                ["GlyphFrame"] =
                {
                    MinVersion = 30000,
                    MaxVersion = 60200,
                    SubFrames =
                    {
                        ["GlyphFrameScrollFrame"] =
                        {
                            IgnoreMouseWheel = true,
                        },
                    },
                },
            },
        },
    },
    ["Blizzard_GMSurveyUI"] =
    {
        ["GMSurveyFrame"] =
        {
            MinVersion = 0,
            MaxVersion = 11503,
        },
    },
    ["Blizzard_GuildBankUI"] =
    {
        ["GuildBankFrame"] =
        {
            MinVersion = 20502,
        },
    },
    ["Blizzard_GuildControlUI"] =
    {
        ["GuildControlUI"] =
        {
            VersionRanges =
            {
                { Min = 11404, Max = 20000 },
                { Min = 40000 },
            },
        },
    },
    ["Blizzard_GuildUI"] =
    {
        ["GuildFrame"] =
        {
            MinVersion = 40000, -- Moved from FrameXML when?
            MaxVersion = 110000, -- Removed when?
        },
    },
    ["Blizzard_InspectUI"] =
    {
        ["InspectFrame"] =
        {
            MinVersion = 0,
            SubFrames =
            {
                ["InspectPaperDollFrame"] = {},
                ["InspectHonorFrame"] =
                {
                    MaxVersion = 20000,
                },
                ["InspectPVPFrame"] =
                {
                    MinVersion = 20000,
                    SubFrames =
                    {
                        ["InspectPVPFrameHonor"] =
                        {
                            MaxVersion = 70300, -- Removed when?
                        },
                        ["InspectPVPFrameArena"] =
                        {
                            MaxVersion = 70300, -- Removed when?
                        },
                        ["InspectPVPTeam1"] =
                        {
                            MaxVersion = 70300, -- Removed when?
                        },
                        ["InspectPVPTeam2"] =
                        {
                            MaxVersion = 70300, -- Removed when?
                        },
                        ["InspectPVPTeam3"] =
                        {
                            MaxVersion = 70300, -- Removed when?
                        },
                    },
                },
                ["InspectTalentFrame"] =
                {
                    MinVersion = 20000, -- Added when?
                    MaxVersion = 100000,
                    SilenceCompatabilityWarnings = true, -- hasn't been removed from the code, but is no longer visible or functional
                },
                ["InspectGuildFrame"] =
                {
                    MinVersion = 50000, -- Added when?
                },
            },
        },
    },
    ["Blizzard_IslandsPartyPoseUI"] =
    {
        ["IslandsPartyPoseFrame"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_IslandsQueueUI"] =
    {
        ["IslandsQueueFrame"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_ItemAlterationUI"] =
    {
        ["TransmogrifyFrame"] =
        {
            MinVersion = 40300,
            MaxVersion = 70300, -- Removed when?
        },
    },
    ["Blizzard_ItemInteractionUI"] =
    {
        ["ItemInteractionFrame"] =
        {
            MinVersion = 80300,
        },
    },
    ["Blizzard_ItemSocketingUI"] =
    {
        ["ItemSocketingFrame"] =
        {
            MinVersion = 0,
        },
    },
    ["Blizzard_ItemUpgradeUI"] =
    {
        ["ItemUpgradeFrame"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_LookingForGroupUI"] =
    {
        ["LFGParentFrame"] =
        {
            VersionRanges =
            {
                { Min = 11404, Max = 11503 }, -- Backported in a broken state
                { Min = 20504, Max = 70000 }, -- Moved from FrameXML; Removed when?
            },
        },
    },
    ["Blizzard_LookingForGuildUI"] =
    {
        ["LookingForGuildFrame"] =
        {
            MinVersion = 50000, -- Added when?
            MaxVersion = 90000, -- Removed when?
        },
    },
    ["Blizzard_MacroUI"] =
    {
        ["MacroFrame"] =
        {
            MinVersion = 0,
        },
    },
    ["Blizzard_MajorFactions"] =
    {
        ["MajorFactionRenownFrame"] =
        {
            MinVersion = 100000,
        },
    },
    ["Blizzard_MatchCelebrationPartyPoseUI"] =
    {
        ["MatchCelebrationPartyPoseFrame"] =
        {
            MinVersion = 100206,
        },
    },
    ["Blizzard_ObliterumUI"] =
    {
        ["ObliterumForgeFrame"] =
        {
            MinVersion = 70000, -- Added when?
        },
    },
    ["Blizzard_OrderHallUI"] =
    {
        ["OrderHallTalentFrame"] =
        {
            MinVersion = 70000, -- Added when?
        },
    },
    ["Blizzard_PlayerChoiceUI"] =
    {
        ["PlayerChoiceFrame"] =
        {
            MinVersion = 90000,
            MaxVersion = 100000,
        },
    },
    ["Blizzard_PlayerSpells"] =
    {
        ["HeroTalentsSelectionDialog"] = {
            MinVersion = 110000,
        },
        ["PlayerSpellsFrame"] = {
            MinVersion = 110000,
            SubFrames =
            {
                ["PlayerSpellsFrame.TalentsFrame.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_Professions"] =
    {
        ["InspectRecipeFrame"] =
        {
            MinVersion = 100100,
        },
        ["ProfessionsFrame"] =
        {
            MinVersion = 100000,
        },
        ["ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog"] =
        {
            MinVersion = 100000,
        },
        ["ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.QualityDialog"] =
        {
            MinVersion = 100000,
        },
    },
    ["Blizzard_ProfessionsBook"] =
    {
        ["ProfessionsBookFrame"] =
        {
            MinVersion = 110000,
        },
    },
    ["Blizzard_ProfessionsCustomerOrders"] =
    {
        ["ProfessionsCustomerOrdersFrame"] =
        {
            MinVersion = 100002,
            SubFrames =
            {
                ["ProfessionsCustomerOrdersFrame.Form"] = {},
                ["ProfessionsCustomerOrdersFrame.Form.CurrentListings"] =
                {
                    Detachable = true,
                }
            },
        },
    },
    ["Blizzard_PVPMatch"] =
    {
        ["PVPMatchResults"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_PVPUI"] =
    {
        ["PVPMatchScoreboard"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_ReforgingUI"] =
    {
        ["ReforgingFrame"] =
        {
            VersionRanges =
            {
                { Min = 11503, Max = 20000 }, -- Backported in a broken state
                { Min = 40000, Max = 70300 }, -- Removed when?
            },
            SubFrames =
            {
                ["ReforgingFrame.invisButton"] = {},
            },
        },
    },
    ["Blizzard_RuneforgeUI"] =
    {
        ["RuneforgeFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_ScrappingMachineUI"] =
    {
        ["ScrappingMachineFrame"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_Soulbinds"] =
    {
        ["SoulbindViewer"] =
        {
            MinVersion = 90000,
            SubFrames =
            {
                ["SoulbindViewer.ConduitList.Charges"] =
                {
                    MaxVersion = 90105,
                },
            },
        },
    },
    ["Blizzard_StableUI"] =
    {
        ["StableFrame"] =
        {
            MinVersion = 100207,
        },
    },
    ["Blizzard_SubscriptionInterstitialUI"] =
    {
        ["SubscriptionInterstitialFrame"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_TalentUI"] =
    {
        ["TalentFrame"] =
        {
            MinVersion = 0,
            MaxVersion = 11401,
        },
        ["PlayerTalentFrame"] =
        {
            MinVersion = 11401,
            MaxVersion = 110000, -- Unused in DF, but only removed in TWW
        },
    },
    ["Blizzard_TalkingHeadUI"] =
    {
        ["TalkingHeadFrame"] =
        {
            MinVersion = 50000, -- Added when?
            MaxVersion = 100000, -- Moved to FrameXML
            SilenceCompatabilityWarnings = true,
        },
    },
    ["Blizzard_TimeManager"] =
    {
        ["TimeManagerFrame"] =
        {
            MinVersion = 0, -- Added when?
        },
    },
    ["Blizzard_TokenUI"] =
    {
        ["CurrencyTransferMenu"] =
        {
            MinVersion = 110000,
        },
    },
    ["Blizzard_TorghastLevelPicker"] =
    {
        ["TorghastLevelPickerFrame"] =
        {
            MinVersion = 90000,
        },
    },
    ["Blizzard_TradeSkillUI"] =
    {
        ["TradeSkillFrame"] =
        {
            MinVersion = 11306,
            MaxVersion = 100000,
            SubFrames =
            {
                ["TradeSkillFrame.RecipeList"] =
                {
                    MinVersion = 50000, -- Added when?
                },
            },
        },
    },
    ["Blizzard_TrainerUI"] =
    {
        ["ClassTrainerFrame"] =
        {
            MinVersion = 0,
        },
    },
    ["Blizzard_UIWidgets"] =
    {
        ["UIWidgetBelowMinimapContainerFrame"] =
        {
            MinVersion = 11306, -- Added when?
            DefaultDisabled = true,
        },
        ["UIWidgetPowerBarContainerFrame"] =
        {
            MinVersion = 80300, -- Added when?
            DefaultDisabled = true,
        },
        ["UIWidgetTopCenterContainerFrame"] =
        {
            MinVersion = 11306, -- Added when?
            DefaultDisabled = true,
        },
    },
    ["Blizzard_VoidStorageUI"] =
    {
        ["VoidStorageFrame"] =
        {
            MinVersion = 50000, -- Added when?
        },
    },
    ["Blizzard_WarboardUI"] =
    {
        ["WarboardQuestChoiceFrame"] =
        {
            MinVersion = 50000, -- Added when?
            MaxVersion = 90000, -- Removed when?
        },
    },
    ["Blizzard_WarfrontsPartyPoseUI"] =
    {
        ["WarfrontsPartyPoseFrame"] =
        {
            MinVersion = 80000,
        },
    },
    ["Blizzard_WeeklyRewards"] =
    {
        ["WeeklyRewardsFrame"] =
        {
            MinVersion = 90000,
        },
    },
});
