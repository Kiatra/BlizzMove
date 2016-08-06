-- BlizzMmove, move the blizzard frames by yess
if not _G.BlizzMove then BlizzMove = {} end
local BlizzMove = BlizzMove
local SetMoveHandle, createOwnHandleFrame, createQuestTrackerHandle = BlizzMove.SetMoveHandle, BlizzMove.createOwnHandleFrame, BlizzMove.createQuestTrackerHandle

movableFrames = { GameMenuFrame, QuestFrame, FriendsFrame, GossipFrame, DressUpFrame, SpellBookFrame,
	MerchantFrame, HelpFrame, MailFrame, BankFrame, VideoOptionsFrame, InterfaceOptionsFrame, PVEFrame,
	LootFrame, RaidBrowserFrame, TradeFrame, TradeFrame, RaidBrowserFrame, QuestLogPopupDetailFrame
}

movableFramesWithHandler = { ["CharacterFrame"] =  { PaperDollFrame, fff, ReputationFrame, TokenFrame , PetPaperDollFrameCompanionFrame, ReputationFrame } ,
	["WorldMapFrame"] = { WorldMapTitleButton }, ["MailFrame"] = {SendMailFrame},
	["ColorPickerFrame"] = { createOwnHandleFrame(self, ColorPickerFrame, 132, 32, 117, 8, "ColorPickerFrame") },
	["ObjectiveTrackerFrame"] = { createQuestTrackerHandle() , ObjectiveTrackerFrame.BlocksFrame.QuestHeader, ObjectiveTrackerFrame.BlocksFrame.AchievementHeader, ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader},
}

movableFramesLoD = {
	["Blizzard_InspectUI"] = function() SetMoveHandle(self, InspectFrame) end,
	["Blizzard_GuildBankUI"] = function() SetMoveHandle(self, GuildBankFrame) end,
	["Blizzard_TradeSkillUI"] = function() SetMoveHandle(self, TradeSkillFrame) end,
	["Blizzard_ItemSocketingUI"] = function() SetMoveHandle(self, ItemSocketingFrame) end,
	["Blizzard_BarbershopUI"] = function() SetMoveHandle(self, BarberShopFrame) end,
	["Blizzard_MacroUI"] = function() SetMoveHandle(self, MacroFrame) end,
	["Blizzard_VoidStorageUI"] = function() SetMoveHandle(self, VoidStorageFrame) end,
	["Blizzard_ItemAlterationUI"] = function() SetMoveHandle(self, TransmogrifyFrame) end,
	["Blizzard_TalentUI"] = function() 	SetMoveHandle(self, PlayerTalentFrame) end,
	["Blizzard_Calendar"] = function() SetMoveHandle(self, CalendarFrame) end,
	["Blizzard_TrainerUI"] = function() SetMoveHandle(self, ClassTrainerFrame) end,
	["Blizzard_BindingUI"] = function() SetMoveHandle(self, KeyBindingFrame) end,
	["Blizzard_AuctionUI"] = function() SetMoveHandle(self, AuctionFrame) end,
	["Blizzard_ArchaeologyUI"] = function() SetMoveHandle(self, ArchaeologyFrame) end,
	["Blizzard_LookingForGuildUI"] = function() SetMoveHandle(self, LookingForGuildFrame) end,
	["Blizzard_GlyphUI"] = function() SetMoveHandle(self, SpellBookFrame, GlyphFrame) end,
	["Blizzard_AchievementUI"] = function() SetMoveHandle(self, AchievementFrame, AchievementFrameHeader) end,
	["Blizzard_GuildUI"] = function() SetMoveHandle(self, GuildFrame, GuildFrame.TitleMouseover) end,
	["Blizzard_ReforgingUI"] = function() SetMoveHandle(self, ReforgingFrame, ReforgingFrameInvisibleButton) end,
	["Blizzard_EncounterJournal"] = function() SetMoveHandle(self, EncounterJournal, createOwnHandleFrame(self, EncounterJournal, 775, 20, 0, 0, "EncounterJournal")) end,
	["Blizzard_GarrisonUI"] = function() SetMoveHandle(self, GarrisonMissionFrame); SetMoveHandle(self, GarrisonCapacitiveDisplayFrame); SetMoveHandle(self, GarrisonLandingPage) end,
}

function movableFramesLoD:BlizzMove()
	for _, frame in pairs(movableFrames) do
			SetMoveHandle(self, frame)
	end

	for frame, handlers in pairs(movableFramesWithHandler) do
			for index, handler in pairs(handlers) do
					SetMoveHandle(self, _G[frame],handler)
			end
	end
end

local function ADDON_LOADED(self, event, addonName)
	if movableFramesLoD[addonName] then movableFramesLoD[addonName]() end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", ADDON_LOADED)
frame:RegisterEvent("ADDON_LOADED")

function BlizzMove:Debug(...)
--@debug@
	local s = "BlizzMove:"
	for i=1,select("#", ...) do
		local x = select(i, ...)
		s = strjoin(" ",s,tostring(x))
	end
	print(s)
--@end-debug@
end
