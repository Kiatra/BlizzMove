_G.BlizzMove = _G.BlizzMove or {};

BlizzMove.Frames =
{
	["AddonList"] =
	{
		MinVersion = 0,
	},
--	["AudioOptionsFrame"] = -- Empty frame, Legacy Frame?
--	{
--		MinVersion = 0,
--	},
	["BankFrame"] =
	{
		MinVersion = 0,
	},
	["BattlefieldFrame"] = -- Doublecheck what this is.
	{
		MinVersion = 0,
		MaxVersion = 70300,
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
--			["PetPaperDollFrame"] =
--			{
--				MinVersion = 0,
--			},
--			["CompanionFrame"] =
--			{
--				MinVersion = 0,
--			},
			["ReputationFrame"] =
			{
				MinVersion = 0,
			},
			["SkillFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 70300,
			},
			["HonorFrame"] =
			{
				MinVersion = 0,
				MaxVersion = 70300,
			},
			["TokenFrame"] =
			{
				MinVersion = 20000,
			},
		},
	},
	["ChatConfigFrame"] =
	{
		MinVersion = 0,
	},
--	["CinematicFrame"] = -- Has black borders, moving looks bad.
--	{
--		MinVersion = 0,
--	},
--	["ColorPickerFrame"] = -- Find a solution for this.
--	{
--		MinVersion = 0,
--		Handles = { BlizzMove:CreateMoveHandleAtPoint("ColorPickerFrame", "CENTER", "TOPRIGHT", -8, -8) },
--	},
	["CraftFrame"] = -- Unused in classic/retail, when was this used?
	{
		MinVersion = 20000,
		MaxVersion = 70300,
	},
	["DestinyFrame"] =
	{
		MinVersion = 50000,
	},
	["DressUpFrame"] =
	{
		MinVersion = 0,
	},
--	["ExtraActionBarFrame"] = -- Should this be movable?
--	{
--		MinVersion = 0,
--	},
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
		},
	},
	["GameMenuFrame"] =
	{
		MinVersion = 0,
	},
	["GuildInviteFrame"] =
	{
		MinVersion = 20000,
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
	["ItemTextFrame"] = -- Doublecheck what this is.
	{
		MinVersion = 0,
	},
--	["LevelUpDisplay"] = -- Should this be movable, Probably not.
--	{
--		MinVersion = 0,
--	},
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
		},
	},
	["MerchantFrame"] =
	{
		MinVersion = 0,
	},
--	["ObjectiveTrackerFrame"] = -- Find a solution for this.
--	{
--		MinVersion = 0,
--		Handles = { BlizzMove:CreateMoveHandleAtPoint("ObjectiveTrackerFrame", "CENTER", "TOPRIGHT", 8, -12) },
--	},
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
		MinVersion = 20000,
	},
	["QuestFrame"] =
	{
		MinVersion = 0,
	},
	["QuestLogFrame"] =
	{
		MinVersion = 0,
		MaxVersion = 70300,
	},
	["QuestLogPopupDetailFrame"] =
	{
		MinVersion = 20000,
	},
--	["QuestWatchFrame"] = -- Find a solution for this.
--	{
--		MinVersion = 0,
--		Handles = { BlizzMove:CreateMoveHandleAtPoint("QuestWatchFrame", "CENTER", "TOPRIGHT", -12, -20) },
--	},
--	["RaidBrowserFrame"] = -- This even still used?
--	{
--		MinVersion = 20000,
--	},
--	["RaidParentFrame"] = -- This even still used?
--	{
--		MinVersion = 0,
--	},
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
		MinVersion = 20000,
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
		MinVersion = 20000,
	},
	["WorldStateScoreFrame"] =
	{
		MinVersion = 0,
		MaxVersion = 70300,
	},
};

BlizzMove.AddOnFrames =
{
	["Blizzard_AchievementUI"] =
	{
		["AchievementFrame"] =
		{
			MinVersion = 20000,
			SubFrames =
			{
				["AchievementFrameHeader"] =
				{
					MinVersion = 20000,
				},
			},
		},
	},
	["Blizzard_AlliedRacesUI"] =
	{
		["AlliedRacesFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_ArchaeologyUI"] =
	{
		["ArchaeologyFrame"] =
		{
			MinVersion = 20000,
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
			MinVersion = 20000,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_Calendar"] =
	{
		["CalendarFrame"] =
		{
			MinVersion = 20000,
			SubFrames =
			{
				["CalendarCreateEventFrame"] =
				{
					MinVersion = 20000,
					Detachable = true,
				},
				["CalendarViewEventFrame"] =
				{
					MinVersion = 20000,
					Detachable = true,
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
			MinVersion = 20000,
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
			MinVersion = 20000,
		},
		["WardrobeFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_Communities"] =
	{
		["ClubFinderGuildFinderFrame.RequestToJoinFrame"] =
		{
			MinVersion = 20000,
		},
		["CommunitiesFrame"] =
		{
			MinVersion = 0,
		},
		["CommunitiesFrame.RecruitmentDialog"] =
		{
			MinVersion = 20000,
		},
		["CommunitiesGuildLogFrame"] =
		{
			MinVersion = 20000,
		},
		["CommunitiesGuildNewsFiltersFrame"] =
		{
			MinVersion = 20000,
		},
		["CommunitiesGuildTextEditFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_Contribution"] =
	{
		["ContributionCollectionFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_DeathRecap"] =
	{
		["DeathRecapFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_EncounterJournal"] =
	{
		["EncounterJournal"] =
		{
			MinVersion = 20000,
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
		["GlyphFrame"] = -- Unused in classic/retail, when was this used?
		{
			MinVersion = 20000,
			MaxVersion = 70300,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_GuildControlUI"] =
	{
		["GuildControlUI"] =
		{
			MinVersion = 20000,
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
		["TransmogrifyFrame"] = -- Unused in classic/retail, when was this used?
		{
			MinVersion = 20000,
			MaxVersion = 70300,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_ItemUpgradeUI"] =
	{
		["ItemUpgradeFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_LookingForGuildUI"] =
	{
		["LookingForGuildFrame"] =
		{
			MinVersion = 20000,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_OrderHallUI"] =
	{
		["OrderHallTalentFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_PVPMatch"] =
	{
		["PVPMatchResults"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_PVPUI"] =
	{
		["PVPMatchScoreboard"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_ReforgingUI"] =
	{
		["ReforgingFrame"] = -- Unused in classic/retail, when was this used?
		{
			MinVersion = 20000,
			MaxVersion = 70300,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_TradeSkillUI"] =
	{
		["TradeSkillFrame"] =
		{
			MinVersion = 0,
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
			MinVersion = 20000,
		},
	},
	["Blizzard_WarboardUI"] =
	{
		["WarboardQuestChoiceFrame"] =
		{
			MinVersion = 20000,
		},
	},
	["Blizzard_WarfrontsPartyPoseUI"] =
	{
		["WarfrontsPartyPoseFrame"] =
		{
			MinVersion = 80000,
		},
	},
};