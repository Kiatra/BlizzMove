if not BlizzMoveAPI then return end

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
			["PetPaperDollFrame"] =
			{
				MinVersion = 20000, -- Added when?
				MaxVersion = 70300, -- Removed when?
			},
			["CompanionFrame"] =
			{
				MinVersion = 20000, -- Added when?
				MaxVersion = 70300, -- Removed when?
			},
			["ReputationFrame"] =
			{
				MinVersion = 0,
			},
			["SkillFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 70300, -- Removed when?
			},
			["HonorFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 70300, -- Removed when?
			},
			["TokenFrame"] =
			{
				MinVersion = 20000, -- Added when?
				SubFrames =
				{
					["TokenFramePopup"] =
					{
						MinVersion = 20000,
						Detachable = true,
					},
					["TokenFrameContainer"] =
					{
						MinVersion = 20000,
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
	},
	["FriendsFrame"] =
	{
		MinVersion = 0,
		SubFrames =
		{
			["RaidInfoFrame"] =
			{
				MinVersion = 0,
				Detachable = true,
			},
			["FriendsListFrameScrollFrame"] =
			{
				MinVersion = 0,
			},
			["QuickJoinScrollFrame"] =
			{
				MinVersion = 0,
			},
			["WhoListScrollFrame"] =
			{
				MinVersion = 0,
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
		MinVersion = 20000, -- Added when?
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
		MinVersion = 20000, -- Added when?
		SubFrames =
		{
			["LFGListApplicationViewerScrollFrame"] =
			{
				MinVersion = 20000,
			},
			["LFGListSearchPanelScrollFrame"] =
			{
				MinVersion = 20000,
			},
			["ScenarioQueueFrameSpecific"] =
			{
				MinVersion = 20000,
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
		MinVersion = 20000, -- Added when?
	},
	["ReadyCheckFrame"] =
	{
		MinVersion = 0,
	},
	["SpellBookFrame"] =
	{
		MinVersion = 0,
	},
	["SplashFrame"] =
	{
		MinVersion = 20000, -- Added when?
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
		MinVersion = 20000, -- No longer fullscreen when?
		SubFrames =
		{
			["QuestMapFrame"] =
			{
				MinVersion = 20000,
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
			MinVersion = 30000,
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
	},
	["Blizzard_AlliedRacesUI"] =
	{
		["AlliedRacesFrame"] =
		{
			MinVersion = 70300,
		},
	},
	["Blizzard_ArchaeologyUI"] =
	{
		["ArchaeologyFrame"] =
		{
			MinVersion = 40000,
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
			MaxVersion = 80200,
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
			MinVersion = 20000, -- Added when?
			SubFrames =
			{
				["CalendarCreateEventFrame"] =
				{
					MinVersion = 20000,
					Detachable = true,
					SubFrames =
					{
						["CalendarCreateEventInviteListScrollFrame"] =
						{
							MinVersion = 20000,
						},
					},
				},
				["CalendarViewEventFrame"] =
				{
					MinVersion = 20000,
					Detachable = true,
					SubFrames =
					{
						["CalendarViewEventFrame.HeaderFrame"] =
						{
							MinVersion = 20000,
						},
						["CalendarViewEventInviteListScrollFrame"] =
						{
							MinVersion = 20000,
						},
					},
				},
				["CalendarViewHolidayFrame"] =
				{
					MinVersion = 20000,
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
	["Blizzard_Collections"] =
	{
		["CollectionsJournal"] =
		{
			MinVersion = 20000, -- Added when?
		},
		["WardrobeFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_Communities"] =
	{
		["ClubFinderGuildFinderFrame.RequestToJoinFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
		["CommunitiesFrame"] =
		{
			MinVersion = 0,
			SubFrames =
			{
				["ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ListScrollFrame"] =
				{
					MinVersion = 20000, -- Added when?
				},
			},
		},
		["CommunitiesFrame.RecruitmentDialog"] =
		{
			MinVersion = 20000, -- Added when?
		},
		["CommunitiesGuildLogFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
		["CommunitiesGuildNewsFiltersFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
		["CommunitiesGuildTextEditFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_Contribution"] =
	{
		["ContributionCollectionFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_CraftUI"] =
	{
		["CraftFrame"] =
		{
			MaxVersion = 70300, -- When was this renamed to TradeSkillFrame?
		},
	},
	["Blizzard_DeathRecap"] =
	{
		["DeathRecapFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_EncounterJournal"] =
	{
		["EncounterJournal"] =
		{
			MinVersion = 20000, -- Added when?
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
	},
	["Blizzard_GlyphUI"] =
	{
		["GlyphFrame"] =
		{
			MinVersion = 30000,
			MaxVersion = 60200,
		},
	},
	["Blizzard_GMSurveyUI"] =
	{
		["GMSurveyFrame"] =
		{
			MinVersion = 0,
		},
	},
	["Blizzard_GuildBankUI"] =
	{
		["GuildBankFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_GuildControlUI"] =
	{
		["GuildControlUI"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_GuildUI"] =
	{
		["GuildFrame"] =
		{
			MinVersion = 0,
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
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_ItemUpgradeUI"] =
	{
		["ItemUpgradeFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_LookingForGuildUI"] =
	{
		["LookingForGuildFrame"] =
		{
			MinVersion = 20000, -- Added when?
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
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_OrderHallUI"] =
	{
		["OrderHallTalentFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_PVPMatch"] =
	{
		["PVPMatchResults"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_PVPUI"] =
	{
		["PVPMatchScoreboard"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_ReforgingUI"] =
	{
		["ReforgingFrame"] =
		{
			MinVersion = 20000, -- Added when?
			MaxVersion = 70300, -- Removed when?
		},
	},
	["Blizzard_ScrappingMachineUI"] =
	{
		["ScrappingMachineFrame"] =
		{
			MinVersion = 80000,
		},
	},
	["Blizzard_TalentUI"] =
	{
		["TalentFrame"] =
		{
			MinVersion = 0,
			MaxVersion = 40300,
		},
		["PlayerTalentFrame"] =
		{
			MinVersion = 50000,
		},
	},
	["Blizzard_TalkingHeadUI"] =
	{
		["TalkingHeadFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_TradeSkillUI"] =
	{
		["TradeSkillFrame"] =
		{
			MinVersion = 20000, -- Was previously CraftFrame.
			SubFrames =
			{
				["TradeSkillFrame.RecipeList"] =
				{
					MinVersion = 20000,
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
	["Blizzard_VoidStorageUI"] =
	{
		["VoidStorageFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_WarboardUI"] =
	{
		["WarboardQuestChoiceFrame"] =
		{
			MinVersion = 20000, -- Added when?
		},
	},
	["Blizzard_WarfrontsPartyPoseUI"] =
	{
		["WarfrontsPartyPoseFrame"] =
		{
			MinVersion = 80000,
		},
	},
});