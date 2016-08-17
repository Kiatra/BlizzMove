-- BlizzMmove, move the blizzard frames by yess
if not _G.BlizzMove then BlizzMove = {} end
local BlizzMove = BlizzMove

function BlizzMove:CreateOwnHandleFrame(frame, width, height, offX, offY, name)
	local handle = CreateFrame("Frame", "BlizzMovehandle"..name)
	handle:SetWidth(width)
	handle:SetHeight(height)
	handle:SetParent(frame)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:SetPoint("TOPLEFT", frame ,"TOPLEFT", offX, offY)
	--[[
	handle:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	                                        edgeFile = nil,
	                                       tile = true, tileSize = 16, edgeSize = 16,
	                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	handle:SetBackdropColor(1,0,0,0.5)
	--]]
	--handle:SetFrameStrata("MEDIUM")
	return handle
end

local function OnDragStart(self)
	local frameToMove = self.frameToMove
	if frameToMove:IsMovable() then
    frameToMove:StartMoving()
    frameToMove.isMoving = true
  end
end

local function OnDragStop(self)
	local frameToMove = self.frameToMove
	frameToMove:StopMovingOrSizing()
	frameToMove.isMoving = false
end

function BlizzMove:CreateQuestTrackerHandle()
	local handle = CreateFrame("Frame", "BlizzMovehandleQuestTracker")
	handle:SetParent(ObjectiveTrackerFrame)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:SetAllPoints(ObjectiveTrackerFrame.HeaderMenu.Title)

	ObjectiveTrackerFrame.BlocksFrame.QuestHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.AchievementHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader:EnableMouse(true)
	return handle
end

function BlizzMove:SetMoveHandle(frameToMove, handle)
	if not frameToMove then
		print("Expected frame got nil.")
		return
	end
	if not handle then handle = frameToMove end
	handle.frameToMove = frameToMove

	if not frameToMove.EnableMouse then return end
	frameToMove:SetMovable(true)
	handle:RegisterForDrag("LeftButton");

	handle:SetScript("OnDragStart", OnDragStart)
	handle:SetScript("OnDragStop", OnDragStop)
end
