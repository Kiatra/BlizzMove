-- BlizzMove, move the blizzard frames. Originally created by the-rebel-Mermaid.
-- Maintained on github: github.com/the-rebel-Mermaid/BlizzMove/

-- Macro to get the parent of a frame under the mouse cursor:
--/run f = GetMouseFocus(); if f then DEFAULT_CHAT_FRAME:AddMessage(f:GetParent():GetParent():GetName()) end
--/run f = GetMouseFocus(); while f do DEFAULT_CHAT_FRAME:AddMessage(f:GetName()); f = f:GetParent() end
_G.BlizzMove = _G.BlizzMove or {}

local movableFrames = {
	AddonList,
	AudioOptionsFrame,
	BankFrame,
	BattlefieldFrame,
	ChatConfigFrame,
	CinematicFrame,
	DestinyFrame,
	DressUpFrame,
	ExtraActionBarFrame,
	FriendsFrame,
	GameMenuFrame,
	GossipFrame,
	GuildRegistrarFrame, -- Yes, its spelled this way.
	HelpFrame,
	InterfaceOptionsFrame,
	ItemTextFrame,
	--LevelUpDisplay,
	LootFrame,
	MailFrame,
	MerchantFrame,
	PetitionFrame,
	PetStableFrame,
	PVEFrame,
	QuestFrame,
	QuestLogFrame,
	QuestLogPopupDetailFrame,
	RaidBrowserFrame,
	RaidParentFrame,
	SpellBookFrame,
	SplashFrame,
	TabardFrame,
	TaxiFrame,
	TradeFrame,
	VideoOptionsFrame,
	WorldStateScoreFrame,
}

local tocversion = select(4, GetBuildInfo())
if tocversion >= 20000 then
	table.insert(movableFrames, CraftFrame)
	table.insert(movableFrames, WorldMapFrame)
else
	table.insert(movableFrames, BattlefieldFrame)
	table.insert(movableFrames, WorldStateScoreFrame)
end

local movableFramesWithHandle = {
	["CharacterFrame"] =  { PaperDollFrame, PetPaperDollFrame, CompanionFrame, ReputationFrame, SkillFrame, HonorFrame, TokenFrame },
	["ColorPickerFrame"] = { BlizzMove:CreateMoveHandleAtPoint(ColorPickerFrame, "CENTER", "TOPRIGHT", -8, -8) },
	["MailFrame"] = { SendMailFrame },
	--["ObjectiveTrackerFrame"] = { BlizzMove:CreateMoveHandleAtPoint(ObjectiveTrackerFrame, "CENTER", "TOPRIGHT", 8, -12) },
	--["QuestWatchFrame"] = { BlizzMove:CreateMoveHandleAtPoint(QuestWatchFrame, "CENTER", "TOPRIGHT", -12, -20) },
}

local movableFramesLoadOnDemand = {
	["Blizzard_AchievementUI"] = function() BlizzMove:SetMoveHandle(AchievementFrame, AchievementFrameHeader) end,
	["Blizzard_AlliedRacesUI"] = function() BlizzMove:SetMoveHandle(AlliedRacesFrame) end,
	["Blizzard_ArchaeologyUI"] = function() BlizzMove:SetMoveHandle(ArchaeologyFrame) end,
	["Blizzard_ArtifactUI"] = function() BlizzMove:SetMoveHandle(ArtifactFrame); BlizzMove:SetMoveHandle(ArtifactRelicForgeFrame) end,
	["Blizzard_AuctionHouseUI"] = function() BlizzMove:SetMoveHandle(AuctionHouseFrame) end,
	["Blizzard_AuctionUI"] = function() BlizzMove:SetMoveHandle(AuctionFrame) end,
	["Blizzard_AzeriteEssenceUI"] = function() BlizzMove:SetMoveHandle(AzeriteEssenceUI) end,
	["Blizzard_AzeriteRespecUI"] = function() BlizzMove:SetMoveHandle(AzeriteRespecFrame) end,
	["Blizzard_AzeriteUI"] = function() BlizzMove:SetMoveHandle(AzeriteEmpoweredItemUI) end,
	["Blizzard_BarbershopUI"] = function() BlizzMove:SetMoveHandle(BarberShopFrame) end,
	["Blizzard_BindingUI"] = function() BlizzMove:SetMoveHandle(KeyBindingFrame) end,
	["Blizzard_BlackMarketUI"] = function() BlizzMove:SetMoveHandle(BlackMarketFrame) end,
	["Blizzard_Calendar"] = function() BlizzMove:SetMoveHandle(CalendarFrame) end,
	["Blizzard_ChallengesUI"] = function() BlizzMove:SetMoveHandle(ChallengesKeystoneFrame) end,
	["Blizzard_Channels"] = function() BlizzMove:SetMoveHandle(ChannelFrame) end,
	["Blizzard_Collections"] = function() BlizzMove:SetMoveHandle(CollectionsJournal); BlizzMove:SetMoveHandle(WardrobeFrame) end,
	["Blizzard_Communities"] = function() BlizzMove:SetMoveHandle(CommunitiesFrame); if tocversion >= 20000 then BlizzMove:SetMoveHandle(ClubFinderGuildFinderFrame.RequestToJoinFrame); BlizzMove:SetMoveHandle(CommunitiesFrame.RecruitmentDialog); BlizzMove:SetMoveHandle(CommunitiesGuildLogFrame); BlizzMove:SetMoveHandle(CommunitiesGuildNewsFiltersFrame); BlizzMove:SetMoveHandle(CommunitiesGuildTextEditFrame) end end,
	["Blizzard_Contribution"] = function() BlizzMove:SetMoveHandle(ContributionCollectionFrame) end,
	["Blizzard_CraftUI"] = function() if tocversion < 20000 then BlizzMove:SetMoveHandle(CraftFrame) end end,
	["Blizzard_DeathRecap"] = function() BlizzMove:SetMoveHandle(DeathRecapFrame) end,
	["Blizzard_EncounterJournal"] = function() BlizzMove:SetMoveHandle(EncounterJournal) end,
	["Blizzard_FlightMap"] = function() BlizzMove:SetMoveHandle(FlightMapFrame) end,
	["Blizzard_GarrisonUI"] = function() BlizzMove:SetMoveHandle(GarrisonBuildingFrame); BlizzMove:SetMoveHandle(GarrisonCapacitiveDisplayFrame); BlizzMove:SetMoveHandle(GarrisonLandingPage); BlizzMove:SetMoveHandle(GarrisonMissionFrame); BlizzMove:SetMoveHandle(GarrisonMonumentFrame); BlizzMove:SetMoveHandle(GarrisonRecruiterFrame); BlizzMove:SetMoveHandle(GarrisonRecruitSelectFrame); BlizzMove:SetMoveHandle(GarrisonShipyardFrame); BlizzMove:SetMoveHandle(OrderHallMissionFrame); BlizzMove:SetMoveHandle(BFAMissionFrame); end,
	["Blizzard_GlyphUI"] = function() BlizzMove:SetMoveHandle(GlyphFrame) end,
	["Blizzard_GMSurveyUI"] = function() BlizzMove:SetMoveHandle(GMSurveyFrame) end,
	["Blizzard_GuildBankUI"] = function() BlizzMove:SetMoveHandle(GuildBankFrame) end,
	["Blizzard_GuildControlUI"] = function() BlizzMove:SetMoveHandle(GuildControlUI) end,
	["Blizzard_GuildUI"] = function() BlizzMove:SetMoveHandle(GuildFrame) end,
	["Blizzard_InspectUI"] = function() BlizzMove:SetMoveHandle(InspectFrame) end,
	["Blizzard_IslandsPartyPoseUI"] = function() BlizzMove:SetMoveHandle(IslandsPartyPoseFrame) end,
	["Blizzard_IslandsQueueUI"] = function() BlizzMove:SetMoveHandle(IslandsQueueFrame) end,
	["Blizzard_ItemAlterationUI"] = function() BlizzMove:SetMoveHandle(TransmogrifyFrame) end,
	["Blizzard_ItemInteractionUI"] = function() BlizzMove:SetMoveHandle(ItemInteractionFrame) end,
	["Blizzard_ItemSocketingUI"] = function() BlizzMove:SetMoveHandle(ItemSocketingFrame) end,
	["Blizzard_ItemUpgradeUI"] = function() BlizzMove:SetMoveHandle(ItemUpgradeFrame) end,
	["Blizzard_LookingForGuildUI"] = function() BlizzMove:SetMoveHandle(LookingForGuildFrame) end,
	["Blizzard_MacroUI"] = function() BlizzMove:SetMoveHandle(MacroFrame) end,
	["Blizzard_ObliterumUI"] = function() BlizzMove:SetMoveHandle(ObliterumForgeFrame) end,
	["Blizzard_OrderHallUI"] = function() BlizzMove:SetMoveHandle(OrderHallTalentFrame) end,
--	["Blizzard_PartyPoseUI"] = function() BlizzMove:SetMoveHandle(PartyPoseFrame) end, -- Template?
	["Blizzard_PVPMatch"] = function() BlizzMove:SetMoveHandle(PVPMatchResults) end,
	["Blizzard_PVPUI"] = function() BlizzMove:SetMoveHandle(PVPMatchScoreboard) end,
	["Blizzard_ReforgingUI"] = function() BlizzMove:SetMoveHandle(ReforgingFrame) end,
	["Blizzard_ScrappingMachineUI"] = function() BlizzMove:SetMoveHandle(ScrappingMachineFrame) end,
--	["Blizzard_StoreUI"] = function() BlizzMove:SetMoveHandle(StoreFrame) end, -- Forbidden access.
	["Blizzard_TalentUI"] = function() if tocversion >= 50001 then BlizzMove:SetMoveHandle(PlayerTalentFrame) else BlizzMove:SetMoveHandle(TalentFrame) end end,
	["Blizzard_TalkingHeadUI"] = function() BlizzMove:SetMoveHandle(TalkingHeadFrame) end,
	["Blizzard_TradeSkillUI"] = function() BlizzMove:SetMoveHandle(TradeSkillFrame) end,
	["Blizzard_TrainerUI"] = function() BlizzMove:SetMoveHandle(ClassTrainerFrame) end,
	["Blizzard_VoidStorageUI"] = function() BlizzMove:SetMoveHandle(VoidStorageFrame) end,
	["Blizzard_WarboardUI"] = function() BlizzMove:SetMoveHandle(WarboardQuestChoiceFrame) end,
	["Blizzard_WarfrontsPartyPoseUI"] = function() BlizzMove:SetMoveHandle(WarfrontsPartyPoseFrame) end,
}

function movableFramesLoadOnDemand:BlizzMove()
	for _, frame in pairs(movableFrames) do
		BlizzMove:SetMoveHandle(frame)
	end

	for frame, handles in pairs(movableFramesWithHandle) do
		for _, handle in pairs(handles) do
			BlizzMove:SetMoveHandle(_G[frame], handle)
		end
	end
end

local function ADDON_LOADED(self, event, addonName)
	if movableFramesLoadOnDemand[addonName] then
		movableFramesLoadOnDemand[addonName]()
	end
end

local frame = CreateFrame("Frame")
frame:HookScript("OnEvent", ADDON_LOADED)
frame:RegisterEvent("ADDON_LOADED")
