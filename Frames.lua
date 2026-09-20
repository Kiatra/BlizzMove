--- @type BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI ---@diagnostic disable-line: undefined-field
if not BlizzMoveAPI then return; end

local v = BlizzMoveAPI.Versions;
local ALL_VERSIONS = { [v.Fallback] = true };

BlizzMoveAPI:RegisterFrames({
    ["AddonList"] = {
        Versions = ALL_VERSIONS,
    },
    ["ArenaFrame"] = {
        Versions = {
            [v.TBC] = { Min = 20505 },
        },
    },
    ["ArenaRegistrarFrame"] = {
        Versions = {
            [v.TBC] = { Min = 20505 }, -- exists, but does it do anything?
            [v.Cata] = true, -- Added when? Removed when?
            [v.MOP] = true,
        },
    },
    ["BankFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["BattlefieldFrame"] = {
        Versions = {
            [v.Vanilla] = true,
            [v.TBC] = true,
            [v.Wrath] = { Max = 30400 },
        },
        SilenceCompatabilityWarnings = true,
    },
    ["CharacterFrame"] = {
        Versions = ALL_VERSIONS,
        SubFrames = {
            ["CompanionFrame"] = {
                Versions = {
                    [v.WOD] = true, -- Added when?
                    [v.Legion] = { Max = 70300 }, -- Removed when?
                },
            },
            ["HonorFrame"] = {
                Versions = {
                    [v.Vanilla] = true, -- Returned in cata, and moved to PVPFrame
                },
                SilenceCompatabilityWarnings = true,
            },
            ["PaperDollFrame"] = {},
            ["PetPaperDollFrame"] = {
                Versions = {
                    [v.WOD] = true,
                    [v.Legion] = { Max = 70300 }, -- Removed when?
                    [v.Classic] = true,
                },
                SubFrames = {
                    ["PetPaperDollFrameCompanionFrame"] = {
                        Versions = {
                            [v.Wrath] = true,
                            [v.Cata] = { Max = 40400 },
                        },
                    },
                },
            },
            ["PVPFrame"] = {
                Versions = {
                    [v.TBC] = true, -- Moved to PVPParentFrame in wrath, then extracted to its own frame in cata
                },
                SilenceCompatabilityWarnings = true,
                SubFrames = {
                    ["PVPFrameArena"] = {},
                    ["PVPFrameHonor"] = {},
                    ["PVPTeam1"] = {},
                    ["PVPTeam2"] = {},
                    ["PVPTeam3"] = {},
                },
            },
            ["ReputationFrame"] = {
                SubFrames = {
                    ["ReputationDetailFrame"] = {
                        Versions = {
                            [v.Classic] = true,
                            [v.WOD] = true,
                            [v.Legion] = true,
                            [v.BFA] = true,
                            [v.SL] = true,
                            [v.DF] = true,
                        },
                        Detachable = true,
                    },
                    ["ReputationFrame.ReputationDetailFrame"] = {
                        Versions = {
                            [v.Mainline] = true,
                        },
                        Detachable = true,
                    },
                },
            },
            ["SkillFrame"] = {
                Versions = {
                    [v.WOD] = true,
                    [v.Legion] = { Max = 70300 }, -- Removed when?
                    [v.Classic] = true,
                },
            },
            ["TokenFrame"] = {
                Versions = {
                    [v.Vanilla] = { Min = 11404 }, -- exists, but does nothing
                    [v.TBC] = { Min = 20505 }, -- exists, but does nothing
                    [v.Fallback] = true,
                },
                SubFrames = {
                    ["CurrencyTransferLog"] = {
                        Versions = {
                            [v.Mainline] = true,
                        },
                        Detachable = true,
                    },
                    ["TokenFrameContainer"] = {
                        Versions = {
                            [v.Classic] = true,
                        },
                    },
                    ["TokenFramePopup"] = {
                        Versions = {
                            [v.Vanilla] = { Min = 11404 }, -- exists, but does nothing
                            [v.TBC] = { Min = 20505 }, -- exists, but does nothing
                            [v.Standard] = true,
                        },
                        Detachable = true,
                    },
                },
            },
        },
    },
    ["ChatConfigFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["ContainerFrame1"] = {
        Versions = {
            [v.Mainline] = true, -- since DF
        },
        -- while it does indeed exist in classic, blizzard does not make other bags follow its position automatically like in retail
        SilenceCompatabilityWarnings = true,
        SubFrames = {
            ["ContainerFrame1.TitleContainer"] = {
                Versions = {
                    [v.Mainline] = true, -- since TWW
                },
            },
        },
    },
    ["ContainerFrameCombinedBags"] = {
        Versions = {
            [v.Mainline] = true, -- since DF
        },
        SubFrames = {
            ["ContainerFrameCombinedBags.TitleContainer"] = {
                Versions = {
                    [v.Mainline] = true, -- since TWW
                },
            },
        },
    },
    ["DestinyFrame"] = {
        Versions = {
            [v.Classic] = { Min = 50000 },
            [v.Mainline] = true,
        },
    },
    ["DressUpFrame"] = {
        Versions = ALL_VERSIONS,
        SubFrames = {
            ["DressUpFrame.CustomSetDetailsPanel"] = {
                Versions = {
                    [v.Mainline] = true,
                },
                Detachable = true,
            },
        },
    },
    ["FriendsFrame"] = {
        Versions = ALL_VERSIONS,
        SubFrames = {
            ["FriendsFrameBattlenetFrame.BroadcastFrame"] = {
                Detachable = true,
            },
            ["FriendsFrameFriendsScrollFrame"] = {
                Versions = {
                    [v.Classic] = true, -- Removed when?
                },
            },
            ["GuildFrame"] = {
                Versions = {
                    [v.Classic] = true, -- Moved to Blizzard_GuildUI when?
                },
                SubFrames = {
                    ["GuildControlPopupFrame"] = {
                        Versions = {
                            [v.Classic] = { Min = 11405 }, -- Removed when?
                        },
                        Detachable = true,
                    },
                    ["GuildEventLogFrame"] = {
                        Versions = {
                            [v.Vanilla] = { Min = 11405 },
                            [v.Fallback] = { Min = 20505 },
                        },
                        Detachable = true,
                    },
                    ["GuildInfoFrame"] = {
                        Detachable = true,
                        SubFrames = {
                            ["GuildInfoFrameScrollFrame"] = {},
                        },
                    },
                },
            },
            ["RaidInfoFrame"] = {
                Detachable = true,
                SubFrames = {
                    ["RaidInfoScrollFrame"] = {
                        Versions = {
                            [v.Vanilla] = { Max = 11506 },
                            [v.TBC] = { Max = 20505 },
                            [v.Wrath] = true,
                            [v.Cata] = { Max = 40402 },
                        },
                    },
                },
            },
        },
    },
    ["GameMenuFrame"] = {
        Versions = ALL_VERSIONS,
        SubFrames = {
            ["GameMenuFrame.Header"] = {
                Versions = {
                    [v.Vanilla] = { Min = 11509 },
                    [v.TBC] = { Min = 20505 },
                    [v.MOP] = { Min = 50504 },
                    [v.Mainline] = true,
                },
            },
        },
    },
    ["GossipFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["GroupLootContainer"] = {
        Versions = ALL_VERSIONS,
        DefaultDisabled = true,
        SubFrames = {
            ["GroupLootFrame1"] = {
                ManuallyScaleWithParent = true,
            },
            ["GroupLootFrame2"] = {
                ManuallyScaleWithParent = true,
            },
            ["GroupLootFrame3"] = {
                ManuallyScaleWithParent = true,
            },
            ["GroupLootFrame4"] = {
                ManuallyScaleWithParent = true,
            },
        },
    },
    ["GuildInviteFrame"] = {
        Versions = {
            [v.Classic] = { Min = 50000 },
            [v.Mainline] = true,
        },
    },
    ["GuildRegistrarFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["HelpFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["ItemTextFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["LootFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["MailFrame"] = {
        Versions = ALL_VERSIONS,
        SubFrames = {
            ["MailFrameInset"] = {
                ForceParentage = true,
            },
            ["OpenMailFrame"] = {
                Detachable = true,
                ManuallyScaleWithParent = true,
                SubFrames = {
                    ["OpenMailFrameInset"] = {
                        ForceParentage = true,
                    },
                    ["OpenMailSender"] = {},
                },
            },
            ["SendMailFrame"] = {},
        },
    },
    ["MerchantFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["ModelPreviewFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["PetitionFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["PetStableFrame"] = {
        Versions = {
            [v.Classic] = true,
            [v.Forever] = true,
        },
    },
    ["PingSystemTutorial"] = {
        Versions = {
            [v.Mainline] = true,
        },
    },
    ["PVEFrame"] = {
        Versions = {
            [v.Classic] = { Min = 30403 },
            [v.Standard] = true,
        },
        SilenceCompatabilityWarnings = true, -- frame exists in classic, but is not functional
        SubFrames = {
            ["LFGListFrame.ApplicationViewer.UnempoweredCover"] = {},
        },
    },
    ["PVPBannerFrame"] = {
        Versions = {
            [v.TBC] = { Min = 20505 }, -- exists, but does it do anything?
            [v.Classic] = { Min = 40000 }, -- Added when? Removed when?
        },
    },
    ["PVPFrame"] = {
        Versions = {
            [v.Classic] = { Min = 40400 }, -- Moved out of PVPParentFrame - Removed when?
        },
        SilenceCompatabilityWarnings = true,
        SubFrames = {
            ["PVPConquestFrame"] = {},
            ["PVPHonorFrame"] = {},
            ["WarGamesFrame"] = {},
        },
    },
    ["PVPParentFrame"] = {
        Versions = {
            [v.Wrath] = true,
            [v.Cata] = { Max = 40400 },
        },
        SubFrames = {
            ["BattlefieldFrame"] = {
                Versions = {
                    [v.Classic] = { Min = 30400 }, -- Moved from FrameXML - Removed when?
                },
                SilenceCompatabilityWarnings = true,
            },
            ["PVPFrame"] = {
                Versions = {
                    [v.Classic] = { Min = 30000 }, -- Moved from CharacterFrame - Removed when?
                },
                SilenceCompatabilityWarnings = true,
                SubFrames = {
                    ["PVPFrameArena"] = {},
                    ["PVPFrameHonor"] = {},
                    ["PVPTeam1"] = {},
                    ["PVPTeam2"] = {},
                    ["PVPTeam3"] = {},
                },
            },
        },
    },
    ["QuestFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["QuestLogDetailFrame"] = {
        Versions = {
            [v.Classic] = { Min = 30000 }, -- Removed when?
        },
    },
    ["QuestLogFrame"] = {
        Versions = {
            [v.Classic] = true, -- Removed when?
        },
    },
    ["QuestLogPopupDetailFrame"] = {
        Versions = {
            [v.Mainline] = true,
        },
    },
    ["QuickKeybindFrame"] = {
        Versions = {
            [v.Mainline] = true, -- Moved from Blizzard_BindingUI
        },
        SilenceCompatabilityWarnings = true,
    },
    ["ReadyCheckFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["RecruitAFriendRecruitmentFrame"] = {
        Versions = {
            [v.Mainline] = true,
        },
    },
    ["RecruitAFriendRewardsFrame"] = {
        Versions = {
            [v.Mainline] = true,
        },
    },
    ["SettingsPanel"] = {
        Versions = ALL_VERSIONS,
    },
    ["SpellBookFrame"] = {
        Versions = {
            [v.Classic] = true, -- Moved into Blizzard_PlayerSpells - PlayerSpellsFrame
        },
    },
    ["SplashFrame"] = {
        Versions = {
            [v.Mainline] = true, -- Added when?
        },
    },
    ["TabardFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["TalkingHeadFrame"] = {
        Versions = {
            [v.Mainline] = true, -- Moved from Blizzard_TalkingHeadUI
        },
        SilenceCompatabilityWarnings = true,
    },
    ["TaxiFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["TradeFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["TutorialFrame"] = {
        Versions = ALL_VERSIONS,
    },
    ["WorldMapFrame"] = {
        Versions = {
            [v.Fallback] = { Min = 11505 },
        },
        IgnoreSavedPositionWhenMaximized = true,
        SubFrames = {
            ["QuestMapFrame"] = {
                Versions = {
                    [v.Classic] = { Min = 40000 },
                    [v.Mainline] = true,
                },
                SubFrames = {
                    ["QuestMapFrame.DetailsFrame.RewardsFrame"] = {
                        Versions = {
                            [v.Classic] = true,
                        },
                    },
                    ["QuestMapFrame.DetailsFrame.ScrollFrame"] = {},
                },
            },
            ["WorldMapTitleButton"] = {
                Versions = {
                    [v.Classic] = { Min = 11505 },
                },
            },
        },
    },
    ["WorldStateScoreFrame"] = {
        Versions = {
            [v.Classic] = true,
        },
    },
});

BlizzMoveAPI:RegisterAddOnFrames({
    ["Blizzard_AccountStore"] = {
        ["AccountStoreFrame"] = {
            Versions = {
                [v.Mainline] = { Min = 110205 },
            },
        },
    },
    ["Blizzard_AchievementUI"] = {
        ["AchievementFrame"] = {
            Versions = {
                [v.Vanilla] = { Min = 11404 }, -- Backported in a broken state in Classic 1.14.4
                [v.TBC] = { Min = 20505 }, -- Backported in a broken state in TBC 2.5.5
                [v.Classic] = true,
                [v.Mainline] = true,
            },
            SubFrames = {
                ["AchievementFrame.Header"] = {
                    Versions = {
                        [v.Mainline] = true,
                    },
                },
                ["AchievementFrameAchievementsContainer"] = {
                    Versions = {
                        [v.Classic] = true,
                    },
                },
                ["AchievementFrameCategoriesContainer"] = {
                    Versions = {
                        [v.Classic] = true,
                    },
                },
                ["AchievementFrameHeader"] = {
                    Versions = {
                        [v.Classic] = true,
                    },
                },
            },
        },
        ["AchievementFrame.SearchResults"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AlliedRacesUI"] = {
        ["AlliedRacesFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AnimaDiversionUI"] = {
        ["AnimaDiversionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["AnimaDiversionFrame.ReinforceProgressFrame"] = {},
                ["AnimaDiversionFrame.ScrollContainer"] = {},
            },
        },
    },
    ["Blizzard_ArchaeologyUI"] = {
        ["ArchaeologyFrame"] = {
            Versions = {
                [v.Classic] = { Min = 40000 },
                [v.Mainline] = true,
            },
        },
        ["ArcheologyDigsiteProgressBar"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ArtifactUI"] = {
        ["ArtifactFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AuctionHouseUI"] = {
        ["AuctionHouseFrame"] = {
            Versions = {
                [v.TBC] = { Min = 20505 }, -- Backported in a broken state
                [v.Cata] = { Min = 40402 },
                [v.Classic] = { Min = 50500 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AuctionUI"] = {
        ["AuctionFrame"] = {
            Versions = {
                [v.Classic] = true,
            },
        },
    },
    ["Blizzard_AzeriteEssenceUI"] = {
        ["AzeriteEssenceUI"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AzeriteRespecUI"] = {
        ["AzeriteRespecFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_AzeriteUI"] = {
        ["AzeriteEmpoweredItemUI"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_BarbershopUI"] = {
        ["BarberShopFrame"] = {
            Versions = {
                [v.Classic] = { Min = 30000 },
            },
            -- still exists, but shouldn't be movable (fullscreen)
            SilenceCompatabilityWarnings = true,
        },
    },
    ["Blizzard_BehavioralMessaging"] = {
        ["BehavioralMessagingDetails"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_BindingUI"] = {
        ["KeyBindingFrame"] = {
            Versions = {
                [v.Classic] = true,
            },
        },
    },
    ["Blizzard_BlackMarketUI"] = {
        ["BlackMarketFrame"] = {
            Versions = {
                [v.Vanilla] = { Min = 11509 }, -- Backported in a broken state
                [v.TBC] = { Min = 20505 }, -- Backported in a broken state
                [v.Classic] = { Min = 50000 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_Calendar"] = {
        ["CalendarFrame"] = {
            Versions = {
                [v.Vanilla] = { Min = 11404 }, -- exists, in a partially broken state
                [v.TBC] = { Min = 20505 }, -- exists, in a partially broken state
                [v.Classic] = { Min = 30000 },
                [v.Mainline] = true,
            },
            SubFrames = {
                ["CalendarCreateEventFrame"] = {
                    Detachable = true,
                },
                ["CalendarViewEventFrame"] = {
                    Detachable = true,
                    SubFrames = {
                        ["CalendarViewEventFrame.HeaderFrame"] = {},
                    },
                },
                ["CalendarViewHolidayFrame"] = {
                    Detachable = true,
                },
            },
        },
    },
    ["Blizzard_ChallengesUI"] = {
        ["ChallengesKeystoneFrame"] = {
            Versions = {
                [v.Mainline] = { Min = 70000 },
            },
        },
    },
    ["Blizzard_Channels"] = {
        ["ChannelFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_ChromieTimeUI"] = {
        ["ChromieTimeFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ClickBindingUI"] = {
        ["ClickBindingFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["ClickBindingFrame.ScrollBox"] = {},
            },
        },
        ["ClickBindingFrame.TutorialFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_Collections"] = {
        ["CollectionsJournal"] = {
            Versions = {
                [v.Vanilla] = { Min = 11503 }, -- Backported in a broken state
                [v.Classic] = { Min = 30403 },
                [v.Mainline] = true,
            },
            SubFrames = {
                ["CollectionsJournal.TitleContainer"] = {
                    Versions = {
                        [v.Vanilla] = { Min = 11506 }, -- Backported in a broken state
                        [v.Cata] = { Min = 40402 },
                        [v.Classic] = { Min = 50500 },
                        [v.Mainline] = true,
                    },
                },
            },
        },
        ["WardrobeFrame"] = {
            Versions = { -- Renamed to WardrobeCollectionFrame, but no longer acts as standalone frame
                [v.Cata] = true,
            },
        },
    },
    ["Blizzard_Communities"] = {
        ["ClubFinderGuildFinderFrame.RequestToJoinFrame"] = {
            Versions = ALL_VERSIONS,
        },
        ["CommunitiesFrame"] = {
            Versions = ALL_VERSIONS, -- Backported into classic from retail (with limited functionality)
            SubFrames = {
                ["CommunitiesFrame.GuildMemberDetailFrame"] = {
                    Detachable = true,
                },
                ["CommunitiesFrame.NotificationSettingsDialog"] = {},
            },
        },
        ["CommunitiesFrame.RecruitmentDialog"] = {
            Versions = ALL_VERSIONS,
        },
        ["CommunitiesGuildLogFrame"] = {
            Versions = ALL_VERSIONS,
        },
        ["CommunitiesGuildNewsFiltersFrame"] = {
            Versions = ALL_VERSIONS,
        },
        ["CommunitiesGuildTextEditFrame"] = {
            Versions = ALL_VERSIONS,
        },
        ["CommunitiesSettingsDialog"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_Contribution"] = {
        ["ContributionCollectionFrame"] = {
            Versions = {
                [v.Classic] = { Min = 40000 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_CooldownViewer"] = {
        ["CooldownViewerSettings"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_CovenantPreviewUI"] = {
        ["CovenantPreviewFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_CovenantRenown"] = {
        ["CovenantRenownFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_CovenantSanctum"] = {
        ["CovenantSanctumFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_CraftUI"] = {
        ["CraftFrame"] = {
            Versions = {
                [v.Classic] = true,
            },
        },
    },
    ["Blizzard_DeathRecap"] = {
        ["DeathRecapFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_DelvesCompanionConfiguration"] = {
        ["DelvesCompanionAbilityListFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["DelvesCompanionConfigurationFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_DelvesDifficultyPicker"] = {
        ["DelvesDifficultyPickerFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_EncounterJournal"] = {
        ["EncounterJournal"] = {
            Versions = {
                [v.Classic] = { Min = 40000 },
                [v.Standard] = true,
            },
            SubFrames = {
                ["EncounterJournal.encounter.info.detailsScroll"] = {},
                ["EncounterJournal.encounter.info.model"] = {
                    NonDraggable = true,
                },
                ["EncounterJournal.encounter.info.overviewScroll"] = {},
                ["EncounterJournal.encounter.instance.LoreScrollingFont.ScrollBox"] = {},
                ["EncounterJournal.instanceSelect.scroll"] = {
                    Versions = {
                        [v.Classic] = { Max = 40400 },
                    },
                },
                ["EncounterJournal.instanceSelect.ScrollBox"] = {
                    Versions = {
                        [v.Cata] = { Min = 40400 },
                        [v.Classic] = { Min = 50500 },
                        [v.Mainline] = true,
                    },
                },
            },
        },
    },
    ["Blizzard_EngravingUI"] = {
        ["CharacterFrame"] = {
            Versions = ALL_VERSIONS,
            SubFrames = {
                ["EngravingFrame"] = {
                    Versions = {
                        [v.Vanilla] = true,
                    },
                    SilenceCompatabilityWarnings = true, -- exists in all classic flavors, but only usable in SoD
                    Detachable = true,
                    ManuallyScaleWithParent = true,
                    SubFrames = {
                        ["EngravingFrame.Border"] = {},
                        ["EngravingFrameScrollFrame"] = {},
                    },
                },
            },
        },
    },
    ["Blizzard_ExpansionLandingPage"] = {
        ["ExpansionLandingPage"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_FlightMap"] = {
        ["FlightMapFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_GarrisonUI"] = {
        ["BFAMissionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["CovenantMissionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["CovenantMissionFrame.FollowerList.MaterialFrame"] = {},
                ["CovenantMissionFrame.MissionTab"] = {},
                ["CovenantMissionFrame.MissionTab.MissionList.MaterialFrame"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage.CostFrame"] = {},
                ["CovenantMissionFrame.MissionTab.MissionPage.StartMissionFrame"] = {},
            },
        },
        ["GarrisonBuildingFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonCapacitiveDisplayFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonLandingPage"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonMissionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonMonumentFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonRecruiterFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonRecruitSelectFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["GarrisonShipyardFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["OrderHallMissionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_GenericTraitUI"] = {
        ["GenericTraitFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["GenericTraitFrame.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_GlyphUI"] = {
        ["PlayerTalentFrame"] = {
            Versions = {
                [v.Classic] = { Min = 11401 },
            },
            SubFrames = {
                ["GlyphFrame"] = {
                    Versions = {
                        [v.Classic] = { Min = 30000, Max = 60200 },
                    },
                    SubFrames = {
                        ["GlyphFrameScrollFrame"] = {
                            IgnoreMouseWheel = true,
                        },
                    },
                },
            },
        },
    },
    ["Blizzard_GroupFinder_VanillaStyle"] = {
        ["LFGParentFrame"] = { -- classic era version of LFG, which only exists on specific realms
            Versions = {
                [v.Vanilla] = { Min = 11405 },
                [v.TBC] = { Min = 20505 },
                [v.Cata] = { Min = 40402 }, -- exists, but is unused
                [v.Classic] = { Min = 50500 }, -- exists, but is unused
                [v.Forever] = true,
            },
            SubFrames = {
                ["LFGListingFrame"] = {
                    Versions = {
                        [v.Forever] = true,
                    },
                    SilenceCompatabilityWarnings = true, -- exists on other flavors, but blocks clicks
                },
            },
        },
    },
    ["Blizzard_GuildBankUI"] = {
        ["GuildBankFrame"] = {
            Versions = {
                [v.Classic] = { Min = 20502 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_GuildControlUI"] = {
        ["GuildControlUI"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_GuildRename"] = {
        ["GuildRenameFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_HouseEditor"] = {
        ["HouseEditorFrame.StoragePanel"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HouseList"] = {
        ["HouseListFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingBlueprint"] = {
        ["HousingBlueprintContentListFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingBlueprintExportFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingBlueprintImportFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingBlueprintRenameFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingBulletinBoard"] = {
        ["HousingBulletinBoardFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingInviteResidentFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["NeighborhoodChangeNameDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingCharter"] = {
        ["HousingCharterRequestSignatureDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingCornerstone"] = {
        ["HousingCornerstoneFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingCornerstoneHouseInfoFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingCornerstonePurchaseFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingCornerstoneVisitorFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["ImportHouseConfirmationDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["MoveHouseConfirmationDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingCreateNeighborhood"] = {
        ["HousingCreateCharterNeighborhoodConfirmationFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingCreateNeighborhoodCharterFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingDashboard"] = {
        ["HousingDashboardFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
            SubFrames = {
                ["HousingDashboardFrame.HouseInfoContent.DashboardNoHousesFrame"] = {},
            },
        },
    },
    ["Blizzard_HousingHouseFinder"] = {
        ["HouseFinderFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingHouseSettings"] = {
        ["AbandonHouseConfirmationDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
        ["HousingHouseSettingsFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_HousingModelPreview"] = {
        ["HousingModelPreviewFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_InspectUI"] = {
        ["InspectFrame"] = {
            Versions = ALL_VERSIONS,
            SubFrames = {
                ["InspectGuildFrame"] = {
                    Versions = {
                        [v.Classic] = { Min = 50000 },
                        [v.Mainline] = true,
                    },
                },
                ["InspectHonorFrame"] = {
                    Versions = {
                        [v.Vanilla] = true,
                    },
                },
                ["InspectPaperDollFrame"] = {},
                ["InspectPVPFrame"] = {
                    Versions = {
                        [v.Classic] = { Min = 20000 },
                        [v.Mainline] = true,
                    },
                    SubFrames = {
                        ["InspectPVPFrameArena"] = {
                            Versions = {
                                [v.Classic] = { Max = 50000 },
                            },
                        },
                        ["InspectPVPFrameHonor"] = {
                            Versions = {
                                [v.Classic] = { Max = 50000 },
                            },
                        },
                        ["InspectPVPTeam1"] = {
                            Versions = {
                                [v.Classic] = { Max = 50000 },
                            },
                        },
                        ["InspectPVPTeam2"] = {
                            Versions = {
                                [v.Classic] = { Max = 50000 },
                            },
                        },
                        ["InspectPVPTeam3"] = {
                            Versions = {
                                [v.Classic] = { Max = 50000 },
                            },
                        },
                    },
                },
                ["InspectTalentFrame"] = {
                    Versions = {
                        [v.Classic] = { Min = 20000 },
                    },
                    SilenceCompatabilityWarnings = true, -- hasn't been removed from the code, but is no longer visible or functional
                },
            },
        },
    },
    ["Blizzard_IslandsPartyPoseUI"] = {
        ["IslandsPartyPoseFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_IslandsQueueUI"] = {
        ["IslandsQueueFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ItemAlterationUI"] = {
        ["TransmogrifyFrame"] = {
            Versions = {
                [v.Classic] = { Min = 40300 },
            },
        },
    },
    ["Blizzard_ItemInteractionUI"] = {
        ["ItemInteractionFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ItemSocketingUI"] = {
        ["ItemSocketingFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_ItemUpgradeUI"] = {
        ["ItemUpgradeFrame"] = {
            Versions = {
                [v.Classic] = { Min = 50000 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_LegacySystem"] = {
        ["LegacySystemFrame"] = {
            Versions = {
                [v.Forever] = true,
            },
            SubFrames = {
                ["LegacySystemFrame.TreePage.LegacyTreeTraitPanel.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_MacroUI"] = {
        ["MacroFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_MatchCelebrationPartyPoseUI"] = {
        ["MatchCelebrationPartyPoseFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ObliterumUI"] = {
        ["ObliterumForgeFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_OrderHallUI"] = {
        ["OrderHallTalentFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_PlayerChoice"] = {
        ["PlayerChoiceFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            ForceUseSecureMoveHandle = true,
        },
    },
    ["Blizzard_PlayerSpells"] = {
        ["HeroTalentsSelectionDialog"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["PlayerSpellsFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["PlayerSpellsFrame.TalentsFrame.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_Professions"] = {
        ["InspectRecipeFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["ProfessionsFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["ProfessionsFrame.CraftingPage.SchematicForm.QualityDialog"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
        ["ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm.QualityDialog"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_ProfessionsBook"] = {
        ["ProfessionsBookFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_ProfessionsCustomerOrders"] = {
        ["ProfessionsCustomerOrdersFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["ProfessionsCustomerOrdersFrame.Form"] = {},
                ["ProfessionsCustomerOrdersFrame.Form.CurrentListings"] = {
                    Detachable = true,
                },
            },
        },
    },
    ["Blizzard_PVPMatch"] = {
        ["PVPMatchResults"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_PVPUI"] = {
        ["PVPMatchScoreboard"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ReforgingUI"] = {
        ["ReforgingFrame"] = {
            Versions = {
                [v.Vanilla] = { Min = 11503 }, -- Backported in a broken state
                [v.TBC] = { Min = 20505 }, -- Backported in a broken state
                [v.Cata] = true,
                [v.Classic] = { Min = 40000 }, -- Removed when?
            },
            SubFrames = {
                ["ReforgingFrame.invisButton"] = {},
            },
        },
    },
    ["Blizzard_RemixArtifactUI"] = {
        ["RemixArtifactFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            SubFrames = {
                ["RemixArtifactFrame.ButtonsParent"] = {},
            },
        },
    },
    ["Blizzard_RuneforgeUI"] = {
        ["RuneforgeFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_ScrappingMachineUI"] = {
        ["ScrappingMachineFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_SettingsDefinitions_Frame"] = {
        ["NamePlatesTutorial"] = {
            Versions = {
                [v.Vanilla] = { Min = 11509 },
                [v.TBC] = { Min = 20506 },
                [v.Classic] = { Min = 50504 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_Soulbinds"] = {
        ["SoulbindViewer"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_StableUI"] = {
        ["StableFrame"] = {
            Versions = {
                [v.Standard] = true,
            },
        },
    },
    ["Blizzard_SubscriptionInterstitialUI"] = {
        ["SubscriptionInterstitialFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_TalentUI"] = {
        ["PlayerTalentFrame"] = {
            Versions = {
                [v.Classic] = true,
            },
        },
    },
    ["Blizzard_TimeManager"] = {
        ["TimeManagerFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_TokenUI"] = {
        ["CurrencyTransferMenu"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_TorghastLevelPicker"] = {
        ["TorghastLevelPickerFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_TradeSkillUI"] = {
        ["TradeSkillFrame"] = {
            Versions = {
                [v.Classic] = true,
            },
        },
    },
    ["Blizzard_TrainerUI"] = {
        ["ClassTrainerFrame"] = {
            Versions = ALL_VERSIONS,
        },
    },
    ["Blizzard_Transmog"] = {
        ["TransmogFrame"] = {
            Versions = {
                [v.Vanilla] = { Min = 11509 }, -- backported in a broken state
                [v.TBC] = true, -- backported in a broken state
                [v.Classic] = { Min = 50504 },
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_UIWidgets"] = {
        ["UIWidgetBelowMinimapContainerFrame"] = {
            Versions = ALL_VERSIONS,
            DefaultDisabled = true,
        },
        ["UIWidgetPowerBarContainerFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
            DefaultDisabled = true,
        },
        ["UIWidgetTopCenterContainerFrame"] = {
            Versions = ALL_VERSIONS,
            DefaultDisabled = true,
        },
    },
    ["Blizzard_VoidStorageUI"] = {
        ["VoidStorageFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_WarfrontsPartyPoseUI"] = {
        ["WarfrontsPartyPoseFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
    ["Blizzard_WeeklyRewards"] = {
        ["WeeklyRewardsFrame"] = {
            Versions = {
                [v.Mainline] = true,
            },
        },
    },
});
