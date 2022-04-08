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
		MaxVersion = 70300, -- Removed when?
	},
	["CharacterFrame"] =
	{
		MinVersion = 0,
		SubFrames =
		{
			["PaperDollFrame"] =
			{
				MinVersion = 0,
			},
			["CompanionFrame"] =
			{
				MinVersion = 40000, -- Added when?
				MaxVersion = 70300, -- Removed when?
			},
			["ReputationFrame"] =
			{
				MinVersion = 0,
				SubFrames =
				{
					["ReputationDetailFrame"] =
					{
						MinVersion = 0,
						Detachable = true,
					},
				},
			},
			["SkillFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 70300, -- Removed when?
			},
			["HonorFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 20000,
			},
			["PVPFrame"] =
			{
				MinVersion = 20000,
				MaxVersion = 70300, -- Removed when?
				SubFrames =
				{
					["PVPFrameHonor"] =
					{
						MinVersion = 20000,
						MaxVersion = 70300, -- Removed when?
					},
					["PVPFrameArena"] =
					{
						MinVersion = 20000,
						MaxVersion = 70300, -- Removed when?
					},
					["PVPTeam1"] =
					{
						MinVersion = 20000,
						MaxVersion = 70300, -- Removed when?
					},
					["PVPTeam2"] =
					{
						MinVersion = 20000,
						MaxVersion = 70300, -- Removed when?
					},
					["PVPTeam3"] =
					{
						MinVersion = 20000,
						MaxVersion = 70300, -- Removed when?
					},
				},
			},
			["TokenFrame"] =
			{
				MinVersion = 30000, -- Added pre 30300
				SubFrames =
				{
					["TokenFramePopup"] =
					{
						MinVersion = 30000,
						Detachable = true,
					},
					["TokenFrameContainer"] =
					{
						MinVersion = 30000,
					},
				},
			},
		},
	},
	["ChatConfigFrame"] =
	{
		MinVersion = 0,
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
			}
		},
	},
	["FriendsFrame"] =
	{
		MinVersion = 0,
		SubFrames =
		{
			["IgnoreListFrameScrollFrame"] =
			{
				MinVersion = 40000, -- Added when?
			},
			["RaidInfoFrame"] =
			{
				MinVersion = 0,
				Detachable = true,
				SubFrames =
				{
					["RaidInfoScrollFrame"] =
					{
						MinVersion = 0,
					}
				}
			},
			["RecruitAFriendFrame.RecruitList.ScrollFrame"] =
			{
				MinVersion = 90000, -- Added when?
			},
			["FriendsFrameBattlenetFrame.BroadcastFrame"] =
			{
				Detachable = true,
			},
			["FriendsListFrameScrollFrame"] =
			{
				MinVersion = 40000, -- Added when?
			},
			["QuickJoinScrollFrame"] =
			{
				MinVersion = 40000, -- Added when?
			},
			["WhoListScrollFrame"] =
			{
				SilenceCompatabilityWarnings = true,
				MinVersion = 30000,
				-- Somehow breaks things in TBC, but also isn't needed there
				-- For classic it's not needed, but oddly also doesn't break things
				-- For retail it is needed
			},
		},
	},
	["GameMenuFrame"] =
	{
		MinVersion = 0,
	},
	["GossipFrame"] =
	{
		MinVersion = 0,
	},
	["GuildInviteFrame"] =
	{
		MinVersion = 40000, -- Added when?
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
		MinVersion = 0,
	},
	["ItemTextFrame"] =
	{
		MinVersion = 0,
	},
	["LFGParentFrame"] =
	{
		MinVersion = 20502,
		MaxVersion = 20503, -- Moved to LOD Blizzard_LookingForGroupUI
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
			["SendMailFrame"] =
			{
				MinVersion = 0,
			},
			["OpenMailFrame"] =
			{
				MinVersion = 0,
				Detachable = true,
				ManuallyScaleWithParent = true,
				SubFrames =
				{
					["OpenMailSender"] =
					{
						MinVersion = 0,
					},
					["OpenMailFrameInset"] =
					{
						MinVersion = 0,
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
	["PetitionFrame"] =
	{
		MinVersion = 0,
	},
	["PetStableFrame"] =
	{
		MinVersion = 0,
	},
	["PVEFrame"] =
	{
		MinVersion = 40000, -- Added when?
		SubFrames =
		{
			["LFGListApplicationViewerScrollFrame"] =
			{
				MinVersion = 40000,
			},
			["LFGListFrame.ApplicationViewer.UnempoweredCover"] =
			{
				MinVersion = 40000,
			},
			["LFGListSearchPanelScrollFrame"] =
			{
				MinVersion = 40000,
				IgnoreMouseWheel = true,
			},
			["ScenarioQueueFrameSpecific"] =
			{
				MinVersion = 40000,
				MaxVersion = 90000,
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
	["QuestLogPopupDetailFrame"] =
	{
		MinVersion = 40000, -- Added when?
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
	["SpellBookFrame"] =
	{
		MinVersion = 0,
	},
	["SplashFrame"] =
	{
		MinVersion = 40000, -- Added when?
	},
	["TabardFrame"] =
	{
		MinVersion = 0,
	},
	["TaxiFrame"] =
	{
		MinVersion = 0,
	},
	["TradeFrame"] =
	{
		MinVersion = 0,
	},
	["VideoOptionsFrame"] =
	{
		MinVersion = 0,
	},
	["WorldMapFrame"] =
	{
		MinVersion = 40000, -- No longer fullscreen when?
		SilenceCompatabilityWarnings = true,
		SubFrames =
		{
			["QuestMapFrame"] =
			{
				MinVersion = 40000, -- Added when?
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
			MinVersion = 30000, -- Added pre 30300
			SubFrames =
			{
				["AchievementFrameHeader"] =
				{
					MinVersion = 30000,
				},
				["AchievementFrameCategoriesContainer"] =
				{
					MinVersion = 30000,
				},
				["AchievementFrameAchievementsContainer"] =
				{
					MinVersion = 30000,
				},
			},
		},
		["AchievementFrame.searchResults"] =
		{
			MinVersion = 30000, -- Added when?
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
				["AnimaDiversionFrame.ScrollContainer"] =
				{
					MinVersion = 90000,
				},
				["AnimaDiversionFrame.ReinforceProgressFrame"] =
				{
					MinVersion = 90000,
				},
			}
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
			MinVersion = 40000, -- Added when?
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
			MinVersion = 30000, -- Added pre 30300
			MaxVersion = 90000, -- still exists, but shouldn't be movable (fullscreen)
			SilenceCompatabilityWarnings = true
		},
	},
	["Blizzard_BindingUI"] =
	{
		["KeyBindingFrame"] =
		{
			MinVersion = 0,
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
			MinVersion = 30000, -- Added pre 30300
			SubFrames =
			{
				["CalendarCreateEventFrame"] =
				{
					MinVersion = 30000,
					Detachable = true,
					SubFrames =
					{
						["CalendarCreateEventInviteListScrollFrame"] =
						{
							MinVersion = 30000,
						},
					},
				},
				["CalendarViewEventFrame"] =
				{
					MinVersion = 30000,
					Detachable = true,
					SubFrames =
					{
						["CalendarViewEventFrame.HeaderFrame"] =
						{
							MinVersion = 40000, -- Added when?
						},
						["CalendarViewEventInviteListScrollFrame"] =
						{
							MinVersion = 30000,
						},
					},
				},
				["CalendarViewHolidayFrame"] =
				{
					MinVersion = 30000,
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
	["Blizzard_ClickBindingUI"] =
	{
		["ClickBindingFrame"] =
		{
			MinVersion = 90200,
			SubFrames =
			{
				["ClickBindingFrame.ScrollBox"] =
				{
					MinVersion = 90200,
				}
			},
		},
	},
	["Blizzard_Collections"] =
	{
		["CollectionsJournal"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["WardrobeFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_Communities"] =
	{
		["ClubFinderGuildFinderFrame.RequestToJoinFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["CommunitiesFrame"] =
		{
			MinVersion = 0,
			SubFrames =
			{
				["ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ListScrollFrame"] =
				{
					MinVersion = 40000, -- Added when?
				},
				["CommunitiesFrame.GuildMemberDetailFrame"] =
				{
					Detachable = true,
					MinVersion = 40000, -- Added when?
				},
			},
		},
		["CommunitiesFrame.RecruitmentDialog"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["CommunitiesGuildLogFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["CommunitiesGuildNewsFiltersFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["CommunitiesGuildTextEditFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_Contribution"] =
	{
		["ContributionCollectionFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_EncounterJournal"] =
	{
		["EncounterJournal"] =
		{
			MinVersion = 40000, -- Added when?
			SubFrames =
			{
				["EncounterJournal.instanceSelect.scroll"] =
				{
					MinVersion = 40000,
				},
				["EncounterJournal.encounter.instance.loreScroll"] =
				{
					MinVersion = 40000,
				},
				["EncounterJournal.encounter.info.overviewScroll"] =
				{
					MinVersion = 40000,
				},
				["EncounterJournal.encounter.info.lootScroll"] =
				{
					MinVersion = 40000,
				},
				["EncounterJournal.encounter.info.detailsScroll"] =
				{
					MinVersion = 40000,
				},
				["EncounterJournal.encounter.info.model"] =
				{
					MinVersion = 40000,
					NonDraggable = true,
				},
			}
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
					MinVersion = 60000,
				},
				["GarrisonLandingPageFollowerListListScrollFrame"] =
				{
					MinVersion = 60000,
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
				["CovenantMissionFrame.MissionTab"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.MissionTab.MissionPage"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.MissionTab.MissionPage.CostFrame"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.MissionTab.MissionPage.StartMissionFrame"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.MissionTab.MissionList.MaterialFrame"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.FollowerList.listScroll"] =
				{
					MinVersion = 90000,
				},
				["CovenantMissionFrame.FollowerList.MaterialFrame"] =
				{
					MinVersion = 90000,
				},
			},
		},
	},
--	["Blizzard_GlyphUI"] =
--	{
--		["GlyphFrame"] =
--		{
--			MinVersion = 30000, -- Added pre 30300, but overlaps talentframe
--			MaxVersion = 60200,
--		},
--	},
	["Blizzard_GMSurveyUI"] =
	{
		["GMSurveyFrame"] =
		{
			MinVersion = 0,
			MaxVersion = 20000,
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
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_GuildUI"] =
	{
		["GuildFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_InspectUI"] =
	{
		["InspectFrame"] =
		{
			MinVersion = 0,
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
			MinVersion = 20000, -- Added pre 20400
		},
	},
	["Blizzard_ItemUpgradeUI"] =
	{
		["ItemUpgradeFrame"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_LookingForGroupUI"] =
	{
		["LFGParentFrame"] =
		{
			MinVersion = 20504, -- Moved from framexml
			MaxVersion = 70000, -- Removed when?
		},
	},
	["Blizzard_LookingForGuildUI"] =
	{
		["LookingForGuildFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
	["Blizzard_ObliterumUI"] =
	{
		["ObliterumForgeFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
		},
	},
	["Blizzard_PVPMatch"] =
	{
		["PVPMatchResults"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_PVPUI"] =
	{
		["PVPMatchScoreboard"] =
		{
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_ReforgingUI"] =
	{
		["ReforgingFrame"] =
		{
			MinVersion = 40000, -- Added when?
			MaxVersion = 70300, -- Removed when?
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
					MinVersion = 90000,
					MaxVersion = 90105,
				},
			},
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
		},
	},
	["Blizzard_TalkingHeadUI"] =
	{
		["TalkingHeadFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
			SubFrames =
			{
				["TradeSkillFrame.RecipeList"] =
				{
					MinVersion = 40000, -- Added when?
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
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_WarboardUI"] =
	{
		["WarboardQuestChoiceFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
