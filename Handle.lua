-- BlizzMove, move the blizzard frames by yess
if not _G.BlizzMove then BlizzMove = {} end
local BlizzMove = BlizzMove

function BlizzMove:CreateOwnHandleFrame(frame, width, height, offX, offY, name)
	local handle = CreateFrame("Frame", "BlizzMoveHandle"..name)
	handle:SetWidth(width)
	handle:SetHeight(height)
	handle:SetParent(frame)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT", offX, offY)
	--[[
	handle:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
						tile = true,
						tileSize = 16,
						edgeSize = 16,
						insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	handle:SetBackdropColor(1,0,0,0.5)
	handle:SetFrameStrata("MEDIUM")
	--]]
	return handle
end

function BlizzMove:CreateQuestTrackerHandle()
	local handle = CreateFrame("Frame", "BlizzMoveHandleQuestTracker")
	handle:SetParent(ObjectiveTrackerFrame)
	handle:EnableMouse(true)
	handle:SetMovable(true)
	handle:SetAllPoints(ObjectiveTrackerFrame.HeaderMenu.Title)

	ObjectiveTrackerFrame.BlocksFrame.QuestHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.AchievementHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader:EnableMouse(true)

	return handle
end

local function OnDragStart(self)
	if self.frameToMove:IsMovable() then
		self.frameToMove:StartMoving()
		self.frameToMove.isMoving = true
	end
end

local function OnDragStop(self)
	self.frameToMove:StopMovingOrSizing()
	self.frameToMove.isMoving = false
end

local function OnMouseWheel(self, vector, ...)
	if not IsControlKeyDown() then return end

	local scale = self.frameToMove:GetScale() or 1

	scale = scale + .1 * vector

	if scale > 1.5 then scale = 1.5 end
	if scale < 0.5 then scale = 0.5 end

	self.frameToMove:SetScale(scale)
end

function BlizzMove:SetMoveHandle(frameToMove, handle)
	if not frameToMove or not frameToMove.EnableMouse then
		print("Expected frame got nil, or has mouse disabled.")
		return
	end

	frameToMove:SetMovable(true)

	if not handle then handle = frameToMove end

	handle.frameToMove = frameToMove
	handle:RegisterForDrag("LeftButton");

	handle:HookScript("OnDragStart", OnDragStart)
	handle:HookScript("OnDragStop", OnDragStop)
	handle:HookScript("OnMouseWheel", OnMouseWheel)

	handle:EnableMouseWheel(true)
end
