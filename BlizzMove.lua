local BlizzMove = LibStub("AceAddon-3.0"):NewAddon("BlizzMove", "AceConsole-3.0", "AceEvent-3.0");
if not BlizzMove then return end

BlizzMove.Frames = BlizzMove.Frames or {};

------------------------------------------------------------------------------------------------------
-- Main: Debug Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:DebugPrint(...)
	if self.DebugPrints then self:Print("Debug message:\n", ...); end
end

------------------------------------------------------------------------------------------------------
-- Main: Frame Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:ValidateFrame(frameName, frameData)
	return true;
end

function BlizzMove:RegisterFrame(addOnName, frameName, frameData)
	if not addOnName then addOnName = "BlizzMove" end

	self.Frames[addOnName]            = self.Frames[addOnName] or {};
	self.Frames[addOnName][frameName] = frameData;

	if IsAddOnLoaded(addOnName) then

		self:ProcessFrame(addOnName, frameName, frameData);

	end
end

------------------------------------------------------------------------------------------------------
-- Main: Helper Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:GetFrameFromName(frameName)
	local frameTable = _G;

	for keyName in string.gmatch(frameName, "([^.]+)") do
		if not frameTable[keyName] then return nil end

		frameTable = frameTable[keyName];
	end

	return frameTable;
end

------------------------------------------------------------------------------------------------------
-- Main: Helper Functions
------------------------------------------------------------------------------------------------------
local function GetFramePoints(frame)
	local numPoints = frame:GetNumPoints();

	if numPoints then
		local framePoints = {};

		for curPoint = 1, numPoints do
			framePoints[curPoint] = {}
			framePoints[curPoint].anchorPoint,
			framePoints[curPoint].relativeFrame,
			framePoints[curPoint].relativePoint,
			framePoints[curPoint].offX,
			framePoints[curPoint].offY = frame:GetPoint(curPoint);
		end

		return framePoints;
	end

	return false;
end

local function SetFramePoints(frame, framePoints)
	if InCombatLockdown() and frame:IsProtected() then return false end

	if framePoints and framePoints[1] then

		frame:ClearAllPoints();

		for curPoint = 1, #framePoints do
			frame.ignoreSetPointHook = true;
			frame:SetPoint(
				framePoints[curPoint].anchorPoint,
				framePoints[curPoint].relativeFrame,
				framePoints[curPoint].relativePoint,
				framePoints[curPoint].offX,
				framePoints[curPoint].offY
			);
			frame.ignoreSetPointHook = nil;
		end
	end

	return true;
end

------------------------------------------------------------------------------------------------------
-- Main: Helper Functions
------------------------------------------------------------------------------------------------------
local function GetFrameScale(frame)
	local frameData = frame.frameData;
	local parentScale = (frameData.storage.frameParent and GetFrameScale(frameData.storage.frameParent)) or 1;

	return frame:GetScale() * parentScale;
end

local function SetFrameScaleSubs(frame, oldScale, newScale)
	local frameData = frame.frameData;

	if frameData.SubFrames then
		for subFrameName, subFrameData in pairs(frameData.SubFrames) do
			if subFrameData.storage then
				local subFrame = subFrameData.storage.frame;

				if subFrame and subFrameData.storage.detached then
					subFrame:SetScale((oldScale * subFrame:GetScale()) / newScale);
				else
					SetFrameScaleSubs(subFrame, oldScale, newScale);
				end
			end
		end
	end
end

local function SetFrameScale(frame, frameScale)
	local frameData = frame.frameData;
	local oldScale = GetFrameScale(frame)
	local newScale = frameScale

	if frameData.storage.detached then
		local parentScale = GetFrameScale(frameData.storage.frameParent)

		newScale = frameScale / parentScale
	end

	frame:SetScale(newScale)
	SetFrameScaleSubs(frame, oldScale, newScale);

	BlizzMove:DebugPrint("SetFrameScale:", frameData.storage.frameName, string.format("%.2f %.2f %.2f", frameScale, frame:GetScale(), GetFrameScale(frame)))

	return true;
end

------------------------------------------------------------------------------------------------------
-- Main: Hooks
------------------------------------------------------------------------------------------------------
local function OnMouseDown(frame, button)

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;

	BlizzMove:DebugPrint("OnMouseDown:", frameData.storage.frameName, button);

	if button == "LeftButton" then

		if IsAltKeyDown() and frameData.Detachable and not frameData.storage.detached then

			frameData.storage.detachPoints = GetFramePoints(frame);
			frameData.storage.detached = true;
			returnValue = true;

			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

		end

		if not frameData.storage.detached then
			parentReturnValue = (frameData.storage.frameParent and OnMouseDown(frameData.storage.frameParent, button));
		end

		if frameData.storage.detached or not parentReturnValue then

			local userPlaced = frame:IsUserPlaced();

			frame:StartMoving();
			frame:SetUserPlaced(userPlaced);
			returnValue = true;

		end

	end

	return returnValue or parentReturnValue;
end

local function OnMouseUp(frame, button)

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;

	BlizzMove:DebugPrint("OnMouseUp:", frameData.storage.frameName, button);

	if not frameData.storage.detached then
		parentReturnValue = (frameData.storage.frameParent and OnMouseUp(frameData.storage.frameParent, button));
	end

	if frameData.storage.detached or not parentReturnValue then

		if button == "LeftButton" then

			frame:StopMovingOrSizing();

			frameData.storage.dragPoints = GetFramePoints(frame);
			frameData.storage.dragged = true;
			returnValue = true;

		elseif button == "RightButton" then

			local fullReset = false;

			if IsAltKeyDown() and frameData.storage.detached then

				if SetFramePoints(frame, frameData.storage.detachPoints) then

					frameData.storage.detachPoints = nil;
					frameData.storage.detached = nil;
					returnValue = true;
					fullReset = true;

					PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

				end

			end

			if IsControlKeyDown() or fullReset then

				returnValue = SetFrameScale(frame, 1) or returnValue;

			end

			if IsShiftKeyDown() or fullReset then

				frameData.storage.dragPoints = nil;
				frameData.storage.dragged = nil;
				returnValue = true;

				UpdateUIPanelPositions(frame);

			end

			returnValue = true;

		end

	end

	return returnValue or parentReturnValue;
end

local function OnMouseWheel(frame, delta)

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;

	BlizzMove:DebugPrint("OnMouseWheel:", frameData.storage.frameName, delta);

	if not frameData.storage.detached then
		parentReturnValue = (frameData.storage.frameParent and OnMouseWheel(frameData.storage.frameParent, delta));
	end

	if frameData.storage.detached or not parentReturnValue then

		if IsControlKeyDown() then

			local oldScale = GetFrameScale(frame) or 1;

			local newScale = oldScale + 0.1 * delta;

			if newScale > 1.5 then newScale = 1.5 end
			if newScale < 0.5 then newScale = 0.5 end

			returnValue = SetFrameScale(frame, newScale) or returnValue;

		end

	end

	return returnValue or parentReturnValue;
end

------------------------------------------------------------------------------------------------------
-- Main: Secure Hooks
------------------------------------------------------------------------------------------------------
local function OnSetPoint(frame, anchorPoint, relativeFrame, relativePoint, offX, offY)
	if frame.ignoreSetPointHook then return end

	if frame.frameData.storage.dragged then
		SetFramePoints(frame, frame.frameData.storage.dragPoints);
	end
end

local function OnSizeUpdate(frame)
	local clampDistance = 40;
	local clampWidth = (frame:GetWidth() - clampDistance) or 0;
	local clampHeight = (frame:GetHeight() - clampDistance) or 0;

	frame:SetClampRectInsets(clampWidth, -clampWidth, -clampHeight, clampHeight);
end
------------------------------------------------------------------------------------------------------
-- Main: Frame Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:MakeFrameMovable(frame, frameName, frameData, frameParent)
	if InCombatLockdown() and frame:IsProtected() then return false end

	if not frame or (frameData.storage and frameData.storage.hooked) then return false end

	local clampFrame = false;
	if not frameParent or frameData.Detachable then
		clampFrame = true;
	end

	frame:SetMovable(true);
	frame:SetClampedToScreen(clampFrame);

	if not frameData.IgnoreMouse then
		frame:EnableMouse(true);
		frame:EnableMouseWheel(true);

		frame:HookScript("OnMouseDown",  OnMouseDown);
		frame:HookScript("OnMouseUp",    OnMouseUp);
		frame:HookScript("OnMouseWheel", OnMouseWheel);
	end

	frame:HookScript("OnShow", function() end);
	frame:HookScript("OnHide", function() end);

	hooksecurefunc(frame, "SetPoint",  OnSetPoint);
	hooksecurefunc(frame, "SetWidth",  OnSizeUpdate);
	hooksecurefunc(frame, "SetHeight", OnSizeUpdate);

	OnSizeUpdate(frame);

	frameData.storage = {};
	frameData.storage.hooked = true;
	frameData.storage.frame = frame;
	frameData.storage.frameName = frameName;
	frameData.storage.frameParent = frameParent;

	frame.frameData = frameData;

	return true;
end

local buildVersion, buildNumber, buildDate, gameVersion = GetBuildInfo();

BlizzMove.gameBuild   = tonumber(buildNumber);
BlizzMove.gameVersion = tonumber(gameVersion);

function BlizzMove:ProcessFrame(addOnName, frameName, frameData, frameParent)

	-- Compare versus current build version.
	if frameData.MinBuild and frameData.MinBuild > self.gameBuild then return end
	if frameData.MaxBuild and frameData.MaxBuild < self.gameBuild then return end

	-- Compare versus current interface version.
	if frameData.MinVersion and frameData.MinVersion > self.gameVersion then return end
	if frameData.MaxVersion and frameData.MaxVersion < self.gameVersion then return end

	local frame = self:GetFrameFromName(frameName);

	if frame then

		if self:MakeFrameMovable(frame, frameName, frameData, frameParent) then

			if frameData.SubFrames then

				for subFrameName, subFrameData in pairs(frameData.SubFrames) do

					self:ProcessFrame(addOnName, subFrameName, subFrameData, frame);

				end

			end

		else

			BlizzMove:Print("Failed to make frame movable:", frameName);

		end

	else

		BlizzMove:Print("Could not find frame (Build: ", self.gameBuild, "|Version:", self.gameVersio, "):", frameName);

	end

end

function BlizzMove:ProcessFrames(addOnName)

	if self.Frames and self.Frames[addOnName] then

		for frameName, frameData in pairs(self.Frames[addOnName]) do

			self:ProcessFrame(addOnName, frameName, frameData);

		end

	end

end


function BlizzMove:OnInitialize()

	self.Config:RegisterOptions()

end

function BlizzMove:ADDON_LOADED(event, addOnName)

	self:ProcessFrames(addOnName);

end

function BlizzMove:OnEnable()

	self:RegisterEvent("ADDON_LOADED");

end
