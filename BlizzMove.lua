-- BlizzMmove, move the blizzard frames by yess
--if not _G.BlizzMove then BlizzMove = {} end
local BlizzMove = _G.BlizzMove

movableFrames = { GameMenuFrame, QuestFrame, FriendsFrame, GossipFrame, DressUpFrame, SpellBookFrame,
	MerchantFrame, HelpFrame, MailFrame, BankFrame, VideoOptionsFrame, InterfaceOptionsFrame, PVEFrame,
	LootFrame, RaidBrowserFrame, TradeFrame, TradeFrame, RaidBrowserFrame, QuestLogPopupDetailFrame, SUFWrapperFrame
}

movableFramesWithhandle = { ["CharacterFrame"] =  { PaperDollFrame, fff, ReputationFrame, TokenFrame , PetPaperDollFrameCompanionFrame, ReputationFrame } ,
	["WorldMapFrame"] = { WorldMapTitleButton }, ["MailFrame"] = {SendMailFrame},
	["ColorPickerFrame"] = { BlizzMove:CreateOwnHandleFrame(ColorPickerFrame, 132, 32, 117, 8, "ColorPickerFrame") },
	--["ObjectiveTrackerFrame"] = { createQuestTrackerHandle() , ObjectiveTrackerFrame.BlocksFrame.QuestHeader, ObjectiveTrackerFrame.BlocksFrame.AchievementHeader, ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader},
}

movableFramesLoD = {
	["Blizzard_Collections"] = function() BlizzMove:SetMoveHandle(CollectionsJournal); BlizzMove:SetMoveHandle(WardrobeFrame) end,
	["Blizzard_InspectUI"] = function() BlizzMove:SetMoveHandle(InspectFrame) end,
	["Blizzard_GuildBankUI"] = function() BlizzMove:SetMoveHandle(GuildBankFrame) end,
	["Blizzard_TradeSkillUI"] = function() BlizzMove:SetMoveHandle(TradeSkillFrame) end,
	["Blizzard_ItemSocketingUI"] = function() BlizzMove:SetMoveHandle(ItemSocketingFrame) end,
	["Blizzard_BarbershopUI"] = function() BlizzMove:SetMoveHandle(BarberShopFrame) end,
	["Blizzard_MacroUI"] = function() BlizzMove:SetMoveHandle(MacroFrame) end,
	["Blizzard_VoidStorageUI"] = function() BlizzMove:SetMoveHandle(VoidStorageFrame) end,
	["Blizzard_ItemAlterationUI"] = function() BlizzMove:SetMoveHandle(TransmogrifyFrame) end,
	["Blizzard_TalentUI"] = function() 	BlizzMove:SetMoveHandle(PlayerTalentFrame) end,
	["Blizzard_Calendar"] = function() BlizzMove:SetMoveHandle(CalendarFrame) end,
	["Blizzard_TrainerUI"] = function() BlizzMove:SetMoveHandle(ClassTrainerFrame) end,
	["Blizzard_BindingUI"] = function() BlizzMove:SetMoveHandle(KeyBindingFrame) end,
	["Blizzard_AuctionUI"] = function() BlizzMove:SetMoveHandle(AuctionFrame) end,
	["Blizzard_ArchaeologyUI"] = function() BlizzMove:SetMoveHandle(ArchaeologyFrame) end,
	["Blizzard_LookingForGuildUI"] = function() BlizzMove:SetMoveHandle(LookingForGuildFrame) end,
	["Blizzard_GlyphUI"] = function() BlizzMove:SetMoveHandle(SpellBookFrame, GlyphFrame) end,
	["Blizzard_AchievementUI"] = function() BlizzMove:SetMoveHandle(AchievementFrame, AchievementFrameHeader) end,
	["Blizzard_GuildUI"] = function() BlizzMove:SetMoveHandle(GuildFrame, GuildFrame.TitleMouseover) end,
	["Blizzard_ReforgingUI"] = function() BlizzMove:SetMoveHandle(ReforgingFrame, ReforgingFrameInvisibleButton) end,
	["Blizzard_EncounterJournal"] = function() BlizzMove:SetMoveHandle(EncounterJournal, BlizzMove:CreateOwnHandleFrame(EncounterJournal, 775, 20, 0, 0, "EncounterJournal")) end,
	["Blizzard_GarrisonUI"] = function() BlizzMove:SetMoveHandle(GarrisonMissionFrame); BlizzMove:SetMoveHandle(GarrisonCapacitiveDisplayFrame); BlizzMove:SetMoveHandle(GarrisonLandingPage) end,
}

function movableFramesLoD:BlizzMove()
	for _, frame in pairs(movableFrames) do
			BlizzMove:SetMoveHandle(frame)
	end

	for frame, handles in pairs(movableFramesWithhandle) do
			for index, handle in pairs(handles) do
					BlizzMove:SetMoveHandle(_G[frame],handle)
			end
	end
end

local function ADDON_LOADED(self, event, addonName)
--@debug@
	--print(addonName)
--@end-debug@
	if movableFramesLoD[addonName] then movableFramesLoD[addonName]() end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", ADDON_LOADED)
frame:RegisterEvent("ADDON_LOADED")
