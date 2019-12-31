-- BlizzMove, move the blizzard frames by yess
_G.BlizzMove = _G.BlizzMove or {}

function BlizzMove:CreateMoveHandleAtPoint(parentFrame, anchorPoint, relativePoint, offX, offY)
	if not parentFrame then return nil end

	local handleFrame = CreateFrame("Frame", "BlizzMoveHandle"..parentFrame:GetName(), parentFrame)
	handleFrame:EnableMouse(true)
	handleFrame:SetPoint(anchorPoint, parentFrame, relativePoint, offX, offY)
	handleFrame:SetHeight(16)
	handleFrame:SetWidth(16)

	handleFrame.texture = handleFrame:CreateTexture()
	handleFrame.texture:SetTexture("Interface/Buttons/UI-Panel-BiggerButton-Up")
	handleFrame.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	handleFrame.texture:SetAllPoints()

	return handleFrame
end

local function OnDragStart(self, button)
	if self.moveFrame:IsMovable() then
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
	moveFrame:SetClampedToScreen(true)

	if not handleFrame then handleFrame = moveFrame end

	handleFrame.moveFrame = moveFrame
	handleFrame:RegisterForDrag("LeftButton")

	handleFrame:HookScript("OnDragStart", OnDragStart)
	handleFrame:HookScript("OnDragStop", OnDragStop)
	handleFrame:HookScript("OnMouseWheel", OnMouseWheel)

	handleFrame:EnableMouseWheel(true)
end
