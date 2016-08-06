-- BlizzMmove, move the blizzard frames by yess
if not _G.BlizzMove then BlizzMove = {} end
local BlizzMove = BlizzMove

function BlizzMove:createOwnHandleFrame(frame, width, height, offX, offY, name)
	local handler = CreateFrame("Frame", "BlizzMoveHandler"..name)
	handler:SetWidth(width)
	handler:SetHeight(height)
	handler:SetParent(frame)
	handler:EnableMouse(true)
	handler:SetMovable(true)
	handler:SetPoint("TOPLEFT", frame ,"TOPLEFT", offX, offY)
	--[[
	handler:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	                                        edgeFile = nil,
	                                       tile = true, tileSize = 16, edgeSize = 16,
	                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }})
	handler:SetBackdropColor(1,0,0,0.5)
	--]]
	--handler:SetFrameStrata("MEDIUM")
	return handler
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

function BlizzMove:createQuestTrackerHandle()
	local handler = CreateFrame("Frame", "BlizzMoveHandlerQuestTracker")
	handler:SetParent(ObjectiveTrackerFrame)
	handler:EnableMouse(true)
	handler:SetMovable(true)
	handler:SetAllPoints(ObjectiveTrackerFrame.HeaderMenu.Title)

	ObjectiveTrackerFrame.BlocksFrame.QuestHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.AchievementHeader:EnableMouse(true)
	ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader:EnableMouse(true)
	return handler
end

function BlizzMove:SetMoveHandle(frameToMove, handler)
	if not frameToMove then
		BlizzMove:Debug("Expected frame got nil.")
		return
	end
	if not handler then handler = frameToMove end
	handler.frameToMove = frameToMove

	if not frameToMove.EnableMouse then return end

	--frameToMove:EnableMouse(true)
	frameToMove:SetMovable(true)
	handler:RegisterForDrag("LeftButton");

	handler:SetScript("OnDragStart", OnDragStart)
	handler:SetScript("OnDragStop", OnDragStop)
end

----------------------------------------------------------
-- User function to move/lock a frame with a handler
-- handler, the frame the user has clicked on
-- frameToMove, the handler itself, a parent frame of handler
--              that has UIParent as Parent or nil
----------------------------------------------------------
function BlizzMove:Toggle(handler)
	if not handler then
		handler = GetMouseFocus()
	end

	if handler:GetName() == "WorldFrame" then
		return
	end

	local lastParent, frameToMove, i = handler, handler, 0

	--get the parent attached to UIParent from handler
	while lastParent and lastParent ~= UIParent and i < 100 do
			frameToMove = lastParent --set to last parent
			lastParent = lastParent:GetParent()
			i = i +1
	end
	if handler and frameToMove then
		if handler:GetScript("OnDragStart") then
			handler:SetScript("OnDragStart", nil)
			BlizzMove:Debug("Frame: ",frameToMove:GetName()," locked.")
		else
			BlizzMove:Debug("Frame: ",frameToMove:GetName()," to move with handler ",handler:GetName())
			SetMoveHandler(frameToMove, handler)
		end

	else
		BlizzMove:Debug("Error parent not found.")
	end
end

--@debug@
BINDING_HEADER_BLIZZMOVE = "BlizzMove";
BINDING_NAME_MOVEFRAME = "Move/Lock a Frame";
--@end-debug@
