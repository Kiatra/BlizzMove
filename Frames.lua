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
					},
				},
			},
			["CompanionFrame"] =
			{
				MinVersion = 40000, -- Added when?
				MaxVersion = 70300, -- Removed when?
			},
			["ReputationFrame"] =
			{
				SubFrames =
				{
					["ReputationDetailFrame"] =
					{
						Detachable = true,
					},
				},
			},
			["SkillFrame"] =
			{
				MaxVersion = 70300, -- Removed when?
			},
			["HonorFrame"] =
			{
				MaxVersion = 20000,
			},
			["PVPFrame"] =
			{
				MinVersion = 20000,
				MaxVersion = 30000, -- Moved to PVPParentFrame
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
				},
			},
		},
	},
	["ChatConfigFrame"] =
	{
		MinVersion = 0,
	},
	["ContainerFrameCombinedBags"] =
	{
		MinVersion = 100000,
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
				MinVersion = 40000, -- Added when?
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
				MinVersion = 40000, -- Added when?
				MaxVersion = 100000,
			},
			["FriendsFrameFriendsScrollFrame"] =
			{
				MaxVersion = 40000, -- Removed when?
			},
			["QuickJoinScrollFrame"] =
			{
				MinVersion = 40000, -- Added when?
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
				MaxVersion = 40000, -- Moved to Blizzard_GuildUI when?
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
	},
	["PingSystemTutorial"] =
	{
		MinVersion = 100107,
	},
	["PVEFrame"] =
	{
		MinVersion = 40000, -- Added when?
		SubFrames =
		{
			["LFGListApplicationViewerScrollFrame"] =
			{
				MaxVersion = 100000,
			},
			["LFGListFrame.ApplicationViewer.UnempoweredCover"] = {},
			["LFGListSearchPanelScrollFrame"] =
			{
				MaxVersion = 100000,
				IgnoreMouseWheel = true,
			},
			["ScenarioQueueFrameSpecific"] =
			{
				MaxVersion = 90000,
			},
		},
	},
	["PVPParentFrame"] =
	{
		MinVersion = 30000,
		MaxVersion = 70300, -- Removed when?
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
		MinVersion = 40000, -- Added when?
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
			{ Min = 100000 }, -- Added in DF
		},
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
	["VideoOptionsFrame"] =
	{
		MinVersion = 0,
		MaxVersion = 100000,
	},
	["WorldMapFrame"] =
	{
		MinVersion = 40000, -- No longer fullscreen when?
		SilenceCompatabilityWarnings = true,
		SubFrames =
		{
			["QuestMapFrame"] =
			{
				SubFrames =
				{
					["QuestMapFrame.DetailsFrame.RewardsFrame"] = {},
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
			MinVersion = 40000, -- Added when?
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
			MinVersion = 40000, -- Added when?
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
							MinVersion = 40000, -- Added when?
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
							MinVersion = 40000, -- Added when?
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
			MinVersion = 30403,
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
		-- ["CommunitiesAddDialog"] = {}, -- Frame is protected, similar to the Store frame
		["CommunitiesFrame"] =
		{
			MinVersion = 0, -- Backported into classic from retail (with limited functionality)
			SubFrames =
			{
				["ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ListScrollFrame"] =
				{
					MinVersion = 40000, -- Added when?
					MaxVersion = 100000,
				},
				["CommunitiesFrame.GuildMemberDetailFrame"] =
				{
					Detachable = true,
					MinVersion = 40000, -- Added when?
				},
				["CommunitiesFrame.NotificationSettingsDialog"] = {},
			},
		},
		["CommunitiesFrame.RecruitmentDialog"] =
		{
			MinVersion = 40000, -- Added when?
		},
		["CommunitiesSettingsDialog"] =
		{
			MinVersion = 0, -- Added when?
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
					MaxVersion = 100000,
				},
				["EncounterJournal.instanceSelect.ScrollBox"] =
				{
					MinVersion = 100000,
				},
				["EncounterJournal.encounter.instance.loreScroll"] =
				{
					MaxVersion = 100000,
				},
				["EncounterJournal.encounter.info.overviewScroll"] = {},
				["EncounterJournal.encounter.info.lootScroll"] =
				{
					MaxVersion = 100000,
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
			-- MaxVersion = 100000, -- Not actually removed yet, but presumably will be in the near future
			SubFrames =
			{
				["GlyphFrame"] =
				{
					MinVersion = 11404, -- Backported in a broken state
					MaxVersion = 60200,
				},
			},
		},
	},
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
			MinVersion = 40000, -- Moved from FrameXML when?
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
					MinVersion = 40000, -- Added when?
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
			MinVersion = 40000, -- Added when?
		},
	},
	["Blizzard_LookingForGroupUI"] =
	{
		["LFGParentFrame"] =
		{
			VersionRanges =
			{
				{ Min = 11404, Max = 20000 }, -- Backported in a broken state
				{ Min = 20504, Max = 70000 }, -- Moved from FrameXML; Removed when?
			},
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
	["Blizzard_MajorFactions"] =
	{
		["MajorFactionRenownFrame"] =
		{
			MinVersion = 100000,
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
					MaxVersion = 90105,
				},
			},
		},
	},
	["Blizzard_SubscriptionInterstitialUI"] =
	{
		["SubscriptionInterstitialFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
			-- MaxVersion = 100000, -- Not actually removed yet, but presumably will be in the near future
		},
	},
	["Blizzard_TalkingHeadUI"] =
	{
		["TalkingHeadFrame"] =
		{
			MinVersion = 40000, -- Added when?
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
