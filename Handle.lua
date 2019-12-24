-- BlizzMove, move the blizzard frames by yess
_G.BlizzMove = _G.BlizzMove or {}

function BlizzMove:CreateHandleFromPoints(parentFrame, pointsFrame)
	local handleFrame = CreateFrame("Frame", "BlizzMoveHandle"..parentFrame:GetName())
	handleFrame:SetParent(parentFrame)
	handleFrame:SetAllPoints(pointsFrame)
	handleFrame:SetMovable(true)
	handleFrame:EnableMouse(true)

	return handleFrame
end

local function OnDragStart(self, button)
	if self.moveFrame:IsMovable() and BlizzMove:CanFrameMove(self.moveFrame:GetName()) then
		self.moveFrame:StartMoving()
	end
end

local function OnDragStop(self)
	self.moveFrame:StopMovingOrSizing()
end

local function OnMouseWheel(self, delta)
	if not IsControlKeyDown() then return end

	local scale = self.moveFrame:GetScale() or 1

	scale = scale + .1 * delta

	if scale > 1.5 then scale = 1.5 end
	if scale < 0.5 then scale = 0.5 end

	self.moveFrame:SetScale(scale)
end

function BlizzMove:SetMoveHandle(moveFrame, handleFrame)
	if not moveFrame or not moveFrame.EnableMouse then
		print("Expected frame got nil, or has mouse disabled.")
		return
	end

	moveFrame:SetMovable(true)

	if not handleFrame then handleFrame = moveFrame end

	handleFrame.moveFrame = moveFrame
	handleFrame:RegisterForDrag("LeftButton");

	handleFrame:HookScript("OnDragStart", OnDragStart)
	handleFrame:HookScript("OnDragStop", OnDragStop)
	handleFrame:HookScript("OnMouseWheel", OnMouseWheel)

	handleFrame:EnableMouseWheel(true)
end

function BlizzMove:CanFrameMove(moveFrameName)
	if movableFramesCanMove[moveFrameName] then
		return movableFramesCanMove[moveFrameName]()
	end

	return true
end
