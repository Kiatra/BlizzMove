-- BlizzMove, move the blizzard frames by yess
_G.BlizzMove = _G.BlizzMove or {}

local printPrefix = "|cFF33FF99[BlizzMove]|r: "

BlizzMoveInformDB = BlizzMoveInformDB or {}
BlizzMovePointsDB = BlizzMovePointsDB or {}

function BlizzMove:CreateMoveHandleAtPoint(parentFrame, anchorPoint, relativePoint, offX, offY)
	if not parentFrame then return nil end

	local handleFrame = CreateFrame("Frame", "BlizzMoveHandle" .. parentFrame:GetName(), parentFrame)
	handleFrame:EnableMouse(true)
	handleFrame:SetClampedToScreen(true)
	handleFrame:SetPoint(anchorPoint, parentFrame, relativePoint, offX, offY)
	handleFrame:SetHeight(16)
	handleFrame:SetWidth(16)

	handleFrame.texture = handleFrame:CreateTexture()
	handleFrame.texture:SetTexture("Interface/Buttons/UI-Panel-BiggerButton-Up")
	handleFrame.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	handleFrame.texture:SetAllPoints()

	return handleFrame
end

function BlizzMove:InformUser(action)
	if not BlizzMoveInformDB[action] then
		BlizzMoveInformDB[action] = true

		if action == "move" then
			print(printPrefix .. "Has just moved a frame. SHIFT+Click to reset the position.")
		else
			print(printPrefix .. "Has just resized a frame. CTRL+Click to reset the scale.")
		end
	end
end

function BlizzMove:ResetFrameScale(frame)
	if InCombatLockdown() and frame:IsProtected() then return end -- Cancel function in combat, can't use protected functions.

	frame:SetScale(1)
end

function BlizzMove:ResetFramePoints(frame, frameName)
	if InCombatLockdown() and frame:IsProtected() then return end -- Cancel function in combat, can't use protected functions.

	if BlizzMovePointsDB[frameName] then
		BlizzMovePointsDB[frameName] = nil

		UpdateUIPanelPositions(frame)
	end
end

function BlizzMove:RestoreFramePoints(frame, frameName)
	if InCombatLockdown() and frame:IsProtected() then return end -- Cancel function in combat, can't use protected functions.

	if BlizzMovePointsDB[frameName] and BlizzMovePointsDB[frameName][1] then
		frame:ClearAllPoints()

		for curPoint = 1, #BlizzMovePointsDB[frameName] do
			if BlizzMovePointsDB[frameName][curPoint] then
				frame.BlizzMoveBypassHook = true -- Used to block SetPoint hook from causing an infinite loop.
				frame:SetPoint(
					BlizzMovePointsDB[frameName][curPoint].anchorPoint,
					BlizzMovePointsDB[frameName][curPoint].relativeFrame,
					BlizzMovePointsDB[frameName][curPoint].relativePoint,
					BlizzMovePointsDB[frameName][curPoint].offX,
					BlizzMovePointsDB[frameName][curPoint].offY
				)
				frame.BlizzMoveBypassHook = nil
			end
		end
	end
end

function BlizzMove:StoreFramePoints(frame, frameName)
	local numPoints = frame:GetNumPoints()

	if numPoints then
		BlizzMovePointsDB[frameName] = {}

		for curPoint = 1, numPoints do
			BlizzMovePointsDB[frameName][curPoint] = {}
			BlizzMovePointsDB[frameName][curPoint].anchorPoint,
			BlizzMovePointsDB[frameName][curPoint].relativeFrame,
			BlizzMovePointsDB[frameName][curPoint].relativePoint,
			BlizzMovePointsDB[frameName][curPoint].offX,
			BlizzMovePointsDB[frameName][curPoint].offY = frame:GetPoint(curPoint)
		end
	end
end

local function OnSetPoint(self)
	if self.BlizzMoveBypassHook then return end

	BlizzMove:RestoreFramePoints(self, self:GetName())
end

local function OnSizeUpdate(self)
	local clampDistance = 40
	local clampWidth = (self:GetWidth() - clampDistance) or 0
	local clampHeight = (self:GetHeight() - clampDistance) or 0

	self:SetClampRectInsets(clampWidth, -clampWidth, -clampHeight, clampHeight)
end

local function OnMouseDown(self, button)
	if button ~= "LeftButton" then return end

	if self.moveFrame:IsMovable() then
		self.moveFrame:StartMoving()
	end
end

local function OnMouseUp(self, button)
	if button ~= "LeftButton" then return end

	self.moveFrame:StopMovingOrSizing()

	local storePoints = true
	if IsShiftKeyDown() then
		BlizzMove:ResetFramePoints(self.moveFrame, self.moveFrame:GetName())
		storePoints = false
	end

	if IsControlKeyDown() then
		BlizzMove:ResetFrameScale(self.moveFrame)
		storePoints = false
	end

	if storePoints then
		BlizzMove:StoreFramePoints(self.moveFrame, self.moveFrame:GetName())
		BlizzMove:InformUser("move")
	end
end

local function OnMouseWheelChildren(self, delta)
	local returnValue = false

	for _, childFrame in pairs({ self:GetChildren() }) do
		local OnMouseWheel = childFrame:GetScript("OnMouseWheel")

		if OnMouseWheel and MouseIsOver(childFrame) then
			OnMouseWheel(childFrame, delta)
			returnValue = true
		end

		returnValue = OnMouseWheelChildren(childFrame, delta) or returnValue
	end

	return returnValue
end

local function OnMouseWheel(self, delta)
	if not OnMouseWheelChildren(self, delta) and IsControlKeyDown() then
		local scale = self.moveFrame:GetScale() or 1

		scale = scale + 0.1 * delta

		if scale > 1.5 then scale = 1.5 end
		if scale < 0.5 then scale = 0.5 end

		self.moveFrame:SetScale(scale)

		BlizzMove:InformUser("scale")
	end
end

function BlizzMove:SetMoveHandle(moveFrame, handleFrame)
	if not moveFrame then print(printPrefix .. "Expected frame is nil") return end

	moveFrame:SetMovable(true)
	moveFrame:SetClampedToScreen(true)

	OnSizeUpdate(moveFrame)

	hooksecurefunc(moveFrame, "SetPoint",  OnSetPoint)
	hooksecurefunc(moveFrame, "SetWidth",  OnSizeUpdate)
	hooksecurefunc(moveFrame, "SetHeight", OnSizeUpdate)

	if not handleFrame then handleFrame = moveFrame end

	handleFrame.moveFrame = moveFrame
	handleFrame:HookScript("OnMouseDown", OnMouseDown)
	handleFrame:HookScript("OnMouseUp", OnMouseUp)
	handleFrame:HookScript("OnMouseWheel", OnMouseWheel)

	handleFrame:EnableMouse(true)
	handleFrame:EnableMouseWheel(true)
end
