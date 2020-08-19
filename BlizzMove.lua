local name = ...
local BlizzMove = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0");
if not BlizzMove then return end

BlizzMove.Frames = BlizzMove.Frames or {};

------------------------------------------------------------------------------------------------------
-- Main: Debug Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:DebugPrint(...)
	if self.DB and self.DB.DebugPrints then self:Print("Debug message:\n", ...); end
end

------------------------------------------------------------------------------------------------------
-- Main: Frame Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:ValidateFrame(frameName, frameData, isSubFrame)

	return self:ValidateFrameName(frameName) and self:ValidateFrameData(frameName, frameData, isSubFrame)

end

function BlizzMove:ValidateFrameName(frameName)

	return #frameName > 0;

end

function BlizzMove:ValidateFrameData(frameName, frameData, isSubFrame)

	local key, value;

	for key, value in pairs(frameData) do

		if key == "SubFrames" then

			if type(value) ~= "table" then return false; end

			for subFrameName, subFrameData in pairs(value) do

				if not self:ValidateFrame(subFrameName, subFrameData, true) then return false; end

			end

		elseif (
			key == "MinVersion"
			or key == "MaxVersion"
			or key == "MinBuild"
			or key == "MaxBuild"
		) then

			if (type(value) ~= "number" or value < 0) then return false; end

		elseif key == "Detachable" then

			if (type(frameData.Detachable) ~= "boolean" or (frameData.Detachable and not isSubFrame)) then return false; end

		elseif key == "IgnoreMouse" then

			if type(frameData.IgnoreMouse) ~= "boolean" then return false; end

		else

			self:Print("Unsupported key supplied in frameData for frame:", frameName, "; key:", key)

		end

	end

	return true;
end

function BlizzMove:RegisterFrame(addOnName, frameName, frameData)
	if not addOnName then addOnName = self.name end

	if self:IsFrameDisabled(addOnName, frameName) then return false end

	self.Frames[addOnName]            = self.Frames[addOnName] or {};
	self.Frames[addOnName][frameName] = frameData;

	if IsAddOnLoaded(addOnName) and (addOnName ~= self.name or self.initialized) then

		self:ProcessFrame(addOnName, frameName, frameData);

	end
end

function BlizzMove:UnregisterFrame(addOnName, frameName, permanent)
	if not addOnName then addOnName = self.name end

	if self:IsFrameDisabled(addOnName, frameName) then return end

	if not self.Frames[addOnName][frameName] then return false; end

	if permanent then

		self.DB.disabledFrames                       = self.DB.disabledFrames or {}
		self.DB.disabledFrames[addOnName]            = self.DB.disabledFrames[addOnName] or {}
		self.DB.disabledFrames[addOnName][frameName] = true

	end

	if IsAddOnLoaded(addOnName) then

		self:UnprocessFrame(frameName)

	end

	return true
end

function BlizzMove:GetRegisteredAddOns()

	local returnTable = {};

	for addOnName, _ in pairs(self.Frames) do

		if next(self:GetRegisteredFrames(addOnName)) ~= nil then

			returnTable[addOnName] = addOnName;

		end

	end

	return returnTable;

end

function BlizzMove:GetRegisteredFrames(addOnName)
	if not addOnName then addOnName = self.name end

	local returnTable = {};

	if not self.Frames[addOnName] then return returnTable; end

	for frameName, frameData in pairs(self.Frames[addOnName]) do

		if self:MatchesCurrentBuild(frameData) then

			returnTable[frameName] = frameName;

		end

	end

	return returnTable;

end

function BlizzMove:DisableFrame(addOnName, frameName)
	if not addOnName then addOnName = self.name end

	if self:IsFrameDisabled(addOnName, frameName) then return end

	BlizzMove:UnregisterFrame(addOnName, frameName, true)

end

function BlizzMove:EnableFrame(addOnName, frameName)
	if not addOnName then addOnName = self.name end

	if not self:IsFrameDisabled(addOnName, frameName) then return end

	self.DB.disabledFrames[addOnName][frameName] = nil

	local frame = self:GetFrameFromName(frameName)
	local frameData = nil;

	if frame and frame.frameData then
		frameData = frame.frameData;
	elseif self.Frames[addOnName] and self.Frames[addOnName][frameName] then
		frameData = self.Frames[addOnName][frameName]
	end

	if frameData then
		self:ProcessFrame(addOnName, frameName, frameData, (frameData.storage and frameData.storage.frameParent) or nil)
	end

end

function BlizzMove:IsFrameDisabled(addOnName, frameName)
	if not addOnName then addOnName = self.name end

	if self.DB and self.DB.disabledFrames and self.DB.disabledFrames[addOnName] and self.DB.disabledFrames[addOnName][frameName] then

		return true

	end

	return false
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

local buildVersion, buildNumber, buildDate, gameVersion = GetBuildInfo();

BlizzMove.gameBuild   = tonumber(buildNumber);
BlizzMove.gameVersion = tonumber(gameVersion);

function BlizzMove:MatchesCurrentBuild(frameData)

	-- Compare versus current build version.
	if frameData.MinBuild and frameData.MinBuild > self.gameBuild then return false end
	if frameData.MaxBuild and frameData.MaxBuild < self.gameBuild then return false end

	-- Compare versus current interface version.
	if frameData.MinVersion and frameData.MinVersion > self.gameVersion then return false end
	if frameData.MaxVersion and frameData.MaxVersion < self.gameVersion then return false end

	return true;
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

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return end

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

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return end

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

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return end

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
	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return end

	if frame.ignoreSetPointHook then return end

	if frame.frameData.storage.dragged then
		SetFramePoints(frame, frame.frameData.storage.dragPoints);
	end
end

local function OnSizeUpdate(frame)
	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return end

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

	local clampFrame = false;
	if not frameParent or frameData.Detachable then
		clampFrame = true;
	end

	if frame and frameData.storage and frameData.storage.disabled then
		-- it's already hooked, don't hook twice
		frameData.storage.disabled = false;

		frame:SetMovable(true);
		frame:SetClampedToScreen(clampFrame);

		if not frameData.IgnoreMouse then
			frame:EnableMouse(true);
			frame:EnableMouseWheel(true);
		end
		return true;
	end

	if not frame or (frameData.storage and frameData.storage.hooked) then return false end

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

function BlizzMove:MakeFrameUnmovable(frame, frameName, frameData)
	if InCombatLockdown() and frame:IsProtected() then return false end

	if not frame or not frameData.storage or not frameData.storage.hooked then return false end

	frame:SetMovable(false);
	frame:SetClampedToScreen(false);

	if not frameData.IgnoreMouse then
		frame:EnableMouse(false);
		frame:EnableMouseWheel(false);
	end

	frameData.storage.disabled = true;

	return true;
end

function BlizzMove:ProcessFrame(addOnName, frameName, frameData, frameParent)

	if self:IsFrameDisabled(addOnName, frameName) then return end

	if not self:MatchesCurrentBuild(frameData) then return end

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

		BlizzMove:Print("Could not find frame (Build: ", self.gameBuild, "|Version:", self.gameVersion, "):", frameName);

	end

end

function BlizzMove:ProcessFrames(addOnName)

	if self.Frames and self.Frames[addOnName] then

		for frameName, frameData in pairs(self.Frames[addOnName]) do

			self:ProcessFrame(addOnName, frameName, frameData);

		end

	end

end

function BlizzMove:UnprocessFrame(frameName)

	local frame = self:GetFrameFromName(frameName)

	if frame then

		if not frame.frameData then return end

		local frameData = frame.frameData

		if not self:MatchesCurrentBuild(frameData) then return end

		self:MakeFrameUnmovable(frame, frameName, frame.frameData)

		if frame.frameData.SubFrames then

			for subFrameName, _ in pairs(frame.frameData.SubFrames) do

				self:UnprocessFrame(subFrameName)

			end

		end

	end

end

function BlizzMove:OnInitialize()

	self.initialized = true

	BlizzMoveDB = BlizzMoveDB or {}
	self.DB = BlizzMoveDB

	self.Config:RegisterOptions()

	-- after a reload, you need to open to category twice to actually open the correct page
	self:RegisterChatCommand('blizzmove', function() InterfaceOptionsFrame_OpenToCategory('BlizzMove'); InterfaceOptionsFrame_OpenToCategory('BlizzMove') end);
	self:RegisterChatCommand('bm', function() InterfaceOptionsFrame_OpenToCategory('BlizzMove'); InterfaceOptionsFrame_OpenToCategory('BlizzMove') end);

	self:ProcessFrames(self.name)

end

function BlizzMove:ADDON_LOADED(event, addOnName)

	if addOnName ~= self.name then self:ProcessFrames(addOnName); end

end

function BlizzMove:OnEnable()

	self:RegisterEvent("ADDON_LOADED");

end
