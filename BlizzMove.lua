-- BlizzMove, move the blizzard frames by yess

-- Macro to get the parent of a frame under the mouse cursor:
--/run f = GetMouseFocus(); if f then DEFAULT_CHAT_FRAME:AddMessage(f:GetParent():GetParent():GetName()) end
--/run f = GetMouseFocus(); while f do DEFAULT_CHAT_FRAME:AddMessage(f:GetName()); f = f:GetParent() end
local BlizzMove = _G.BlizzMove

movableFrames = {
	AddonList,
	BankFrame,
	DestinyFrame,
	DressUpFrame,
	ExtraActionBarFrame,
	FriendsFrame,
	GameMenuFrame,
	GossipFrame,
	HelpFrame,
	InterfaceOptionsFrame,
	ItemTextFrame,
	LevelUpDisplay,
	LootFrame,
	MailFrame,
	MerchantFrame,
	PVEFrame,
	QuestFrame,
	QuestLogPopupDetailFrame,
	RaidBrowserFrame,
	SplashFrame,
	SUFWrapperFrame,
	TabardFrame,
	TalkingHeadFrame,
	TradeFrame,
	VideoOptionsFrame,
	WorldMapFrame
}

local tocversion = select(4, GetBuildInfo())
if tocversion < 20000 then
	table.insert(movableFrames, CraftFrame)
end

if tocversion < 80200 then
	table.insert(movableFrames, QuestLogFrame)
end

movableFramesWithHandle = {
	["CharacterFrame"] =  { PaperDollFrame, ReputationFrame, TokenFrame, PetPaperDollFrameCompanionFrame },
	["ColorPickerFrame"] = { BlizzMove:CreateOwnHandleFrame(ColorPickerFrame, 132, 32, 117, 8, "ColorPickerFrame") },
	["MailFrame"] = { SendMailFrame },
	["SpellBookFrame"] = { BlizzMove:CreateOwnHandleFrame(SpellBookFrame, 525, 20, 0, 0, "SpellBookFrame") },
	["WorldMapFrame"] = { WorldMapTitleButton },
--	["ObjectiveTrackerFrame"] = { BlizzMove:CreateQuestTrackerHandle(), ObjectiveTrackerFrame.BlocksFrame.QuestHeader, ObjectiveTrackerFrame.BlocksFrame.AchievementHeader, ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader },
}

movableFramesLoadOnDemand = {
	["Blizzard_AchievementUI"] = function() BlizzMove:SetMoveHandle(AchievementFrame, AchievementFrameHeader) end,
	["Blizzard_AlliedRacesUI"] = function() BlizzMove:SetMoveHandle(AlliedRacesFrame) end,
	["Blizzard_ArchaeologyUI"] = function() BlizzMove:SetMoveHandle(ArchaeologyFrame) end,
	["Blizzard_ArtifactUI"] = function()  BlizzMove:SetMoveHandle(ArtifactFrame); BlizzMove:SetMoveHandle(ArtifactRelicForgeFrame) end,
	["Blizzard_AuctionUI"] = function() BlizzMove:SetMoveHandle(AuctionFrame) end,
	["Blizzard_AzeriteEssenceUI"] = function() BlizzMove:SetMoveHandle(AzeriteEssenceUI) end,
	["Blizzard_AzeriteRespecUI"] = function() BlizzMove:SetMoveHandle(AzeriteRespecFrame) end,
	["Blizzard_AzeriteUI"] = function() BlizzMove:SetMoveHandle(AzeriteEmpoweredItemUI) end,
	["Blizzard_BarbershopUI"] = function() BlizzMove:SetMoveHandle(BarberShopFrame) end,
	["Blizzard_BindingUI"] = function() BlizzMove:SetMoveHandle(KeyBindingFrame) end,
	["Blizzard_BlackMarketUI"] = function() BlizzMove:SetMoveHandle(BlackMarketFrame) end,
	["Blizzard_Calendar"] = function() BlizzMove:SetMoveHandle(CalendarFrame) end,
	["Blizzard_Collections"] = function() BlizzMove:SetMoveHandle(CollectionsJournal); BlizzMove:SetMoveHandle(WardrobeFrame) end,
	["Blizzard_Communities"] = function() BlizzMove:SetMoveHandle(CommunitiesFrame) end,
	["Blizzard_DeathRecap"] = function() BlizzMove:SetMoveHandle(DeathRecapFrame) end,
	["Blizzard_EncounterJournal"] = function() BlizzMove:SetMoveHandle(EncounterJournal, BlizzMove:CreateOwnHandleFrame(EncounterJournal, 775, 20, 0, 0, "EncounterJournal")) end,
	["Blizzard_FlightMap"] = function() BlizzMove:SetMoveHandle(FlightMapFrame) end,
	["Blizzard_GarrisonUI"] = function() BlizzMove:SetMoveHandle(GarrisonLandingPage); BlizzMove:SetMoveHandle(GarrisonMissionFrame); BlizzMove:SetMoveHandle(GarrisonBuildingFrame); BlizzMove:SetMoveHandle(GarrisonShipyardFrame); BlizzMove:SetMoveHandle(GarrisonCapacitiveDisplayFrame); BlizzMove:SetMoveHandle(OrderHallMissionFrame); BlizzMove:SetMoveHandle(BFAMissionFrame); end,
	["Blizzard_GuildBankUI"] = function() BlizzMove:SetMoveHandle(GuildBankFrame) end,
	["Blizzard_GuildUI"] = function() BlizzMove:SetMoveHandle(GuildFrame, GuildFrame.TitleMouseover) end,
	["Blizzard_InspectUI"] = function() BlizzMove:SetMoveHandle(InspectFrame) end,
	["Blizzard_IslandsQueueUI"] = function() BlizzMove:SetMoveHandle(IslandsQueueFrame) end,
	["Blizzard_ItemAlterationUI"] = function() BlizzMove:SetMoveHandle(TransmogrifyFrame) end,
	["Blizzard_ItemSocketingUI"] = function() BlizzMove:SetMoveHandle(ItemSocketingFrame) end,
	["Blizzard_ItemUpgradeUI"] = function() BlizzMove:SetMoveHandle(ItemUpgradeFrame) end,
	["Blizzard_LookingForGuildUI"] = function() BlizzMove:SetMoveHandle(LookingForGuildFrame) end,
	["Blizzard_MacroUI"] = function() BlizzMove:SetMoveHandle(MacroFrame) end,
	["Blizzard_ObliterumUI"] = function() BlizzMove:SetMoveHandle(ObliterumForgeFrame) end,
	["Blizzard_PartyPoseUI"] = function() BlizzMove:SetMoveHandle(PartyPoseFrame) end,
	["Blizzard_ReforgingUI"] = function() BlizzMove:SetMoveHandle(ReforgingFrame, ReforgingFrameInvisibleButton) end,
	["Blizzard_ScrappingMachineUI"] = function() BlizzMove:SetMoveHandle(ScrappingMachineFrame) end,
--	["Blizzard_StoreUI"] = function() BlizzMove:SetMoveHandle(StoreFrame) end, -- Forbidden access.
	["Blizzard_TalentUI"] = function() BlizzMove:SetMoveHandle(PlayerTalentFrame); if tocversion < 20000 then BlizzMove:SetMoveHandle(TalentFrame) end end,
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
		for index, handle in pairs(handles) do
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
