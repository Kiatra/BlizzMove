-- BlizzMove, move the blizzard frames by yess
_G.BlizzMove = _G.BlizzMove or {}
BlizzMove.informedUser = false
BlizzMove.informationText = 'BlizzMove has just helped you to move/rescale a frame. SHIFT+click the frame to reset the scale and position.'

BlizzMovePointsDB = BlizzMovePointsDB or {}

function BlizzMove:CreateMoveHandleAtPoint(parentFrame, anchorPoint, relativePoint, offX, offY)
	if not parentFrame then return nil end

	local handleFrame = CreateFrame('Frame', 'BlizzMoveHandle' .. parentFrame:GetName(), parentFrame)
	handleFrame:EnableMouse(true)
	handleFrame:SetPoint(anchorPoint, parentFrame, relativePoint, offX, offY)
	handleFrame:SetHeight(16)
	handleFrame:SetWidth(16)

	handleFrame.texture = handleFrame:CreateTexture()
	handleFrame.texture:SetTexture('Interface/Buttons/UI-Panel-BiggerButton-Up')
	handleFrame.texture:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	handleFrame.texture:SetAllPoints()

	return handleFrame
end

function BlizzMove:InformUserOnce()
		if not BlizzMove.informedUser then
			print(BlizzMove.informationText)
			BlizzMove.informedUser = true;
		end
end

-- resets the frame scale, and toggles it open/close to open it in the default position
function BlizzMove:ResetFramePoints(frame, frameName)
	frame:SetScale(1)
	if BlizzMovePointsDB[frameName] then
		BlizzMovePointsDB[frameName] = nil

		HideUIPanel(frame)
		ShowUIPanel(frame)
	end
end

-- places the frame into a previously saved position after closing and reopening it
function BlizzMove:RestoreFramePoints(frame, frameName)
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

local function OnMouseDown(self, button)
	if button ~= 'LeftButton' then return end
	local frameToMove = self.moveFrame
	if frameToMove:IsMovable() then
		frameToMove:StartMoving()
	end
end

local function OnMouseUp(self, button)
	if button ~= 'LeftButton' then return end
	local frameToMove = self.moveFrame
	frameToMove:StopMovingOrSizing()

	if IsShiftKeyDown() then
		BlizzMove:ResetFramePoints(frameToMove, frameToMove:GetName())
	else
		BlizzMove:InformUserOnce()
		BlizzMove:StoreFramePoints(frameToMove, frameToMove:GetName())
	end
end

local function OnMouseWheelChildren(self, delta)
	local returnValue = false

	for _, childFrame in pairs({ self:GetChildren() }) do
		local OnMouseWheel = childFrame:GetScript('OnMouseWheel')

		if OnMouseWheel and MouseIsOver(childFrame) then
			OnMouseWheel(childFrame, delta)
			returnValue = true
		end

		OnMouseWheelChildren(childFrame, delta)
	end

	return returnValue
end

local function OnMouseWheel(self, delta)
	if not OnMouseWheelChildren(self, delta) and IsControlKeyDown() then
		local frameToMove = self.moveFrame
		local scale = frameToMove:GetScale() or 1

		scale = scale + 0.1 * delta

		if scale > 1.5 then scale = 1.5 end
		if scale < 0.5 then scale = 0.5 end

		BlizzMove:InformUserOnce()
		frameToMove:SetScale(scale)
	end
end


function BlizzMove:SetMoveHandle(moveFrame, handleFrame)
	if not moveFrame then print('Expected frame is nil') return end

	local clampDistance = 40
	local clampWidth  = moveFrame:GetWidth() - clampDistance
	local clampHeight = moveFrame:GetHeight() - clampDistance

	moveFrame:SetMovable(true)
	moveFrame:SetClampedToScreen(true)
	moveFrame:SetClampRectInsets(clampWidth, -clampWidth, -clampHeight, clampHeight)

	hooksecurefunc(moveFrame, 'SetPoint', OnSetPoint)

	if not handleFrame then handleFrame = moveFrame end

	handleFrame.moveFrame = moveFrame
	handleFrame:HookScript('OnMouseDown', OnMouseDown)
	handleFrame:HookScript('OnMouseUp', OnMouseUp)
	handleFrame:HookScript('OnMouseWheel', OnMouseWheel)

	handleFrame:EnableMouse(true)
	handleFrame:EnableMouseWheel(true)
end
