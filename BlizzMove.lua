-- upvalue the globals
local _G = getfenv(0);
local InCombatLockdown = _G.InCombatLockdown;
local LibStub = _G.LibStub;
local pairs = _G.pairs;
local type = _G.type;
local IsAddOnLoaded = _G.IsAddOnLoaded;
local next = _G.next;
local string__gmatch = _G.string.gmatch;
local tonumber = _G.tonumber;
local string__format = _G.string.format;
local IsAltKeyDown = _G.IsAltKeyDown;
local PlaySound = _G.PlaySound;
local SOUNDKIT = _G.SOUNDKIT;
local IsControlKeyDown = _G.IsControlKeyDown;
local IsShiftKeyDown = _G.IsShiftKeyDown;
local UpdateUIPanelPositions = _G.UpdateUIPanelPositions;
local MouseIsOver = _G.MouseIsOver;
local xpcall = _G.xpcall;
local CallErrorHandler = _G.CallErrorHandler;
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory;
local strsplit = _G.strsplit;
local LoadAddOn = _G.LoadAddOn;
local GetBuildInfo = _G.GetBuildInfo;

local name = ... or "BlizzMove";
--- @class BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");
if not BlizzMove then return; end

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

	return self:ValidateFrameName(frameName) and self:ValidateFrameData(frameName, frameData, isSubFrame);

end

function BlizzMove:ValidateFrameName(frameName)

	return #frameName > 0;

end

function BlizzMove:ValidateFrameData(frameName, frameData, isSubFrame)

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

		elseif (
			key == "Detachable"
			or key == "ManuallyScaleWithParent"
		) then

			if (type(value) ~= "boolean" or (value == true and not isSubFrame)) then return false; end

		elseif (
			key == "IgnoreMouse"
			or key == "ForceParentage"
			or key == "NonDraggable"
			or key == "DefaultDisabled"
			or key == "SilenceCompatabilityWarnings"
		) then

			if type(value) ~= "boolean" then return false; end

		else

			self:Print("Unsupported key supplied in frameData for frame:", frameName, "; key:", key);

		end

	end

	return true;
end

function BlizzMove:RegisterFrame(addOnName, frameName, frameData, skipConfigUpdate)
	if not addOnName then addOnName = self.name; end

	if self:IsFrameDisabled(addOnName, frameName) then return false; end

	local copiedData = self:CopyTable(frameData);

	self.Frames[addOnName]            = self.Frames[addOnName] or {};
	self.Frames[addOnName][frameName] = copiedData;

	if IsAddOnLoaded(addOnName) and (addOnName ~= self.name and self.enabled or self.initialized) then

		self:ProcessFrame(addOnName, frameName, copiedData);

	end

	if self.initialized and not skipConfigUpdate then

		self.Config:RegisterOptions();

	end

end

function BlizzMove:UnregisterFrame(addOnName, frameName, permanent)
	if not addOnName then addOnName = self.name; end

	if self:IsFrameDisabled(addOnName, frameName) then return; end

	if not self.Frames[addOnName][frameName] then return false; end

	if permanent then

		self.DB.disabledFrames                       = self.DB.disabledFrames or {};
		self.DB.disabledFrames[addOnName]            = self.DB.disabledFrames[addOnName] or {};
		self.DB.disabledFrames[addOnName][frameName] = true;

	end

	if IsAddOnLoaded(addOnName) then

		self:UnprocessFrame(frameName);

	end

	return true;
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
	if not addOnName then addOnName = self.name; end

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
	if not addOnName then addOnName = self.name; end

	if self:IsFrameDisabled(addOnName, frameName) then return; end

	BlizzMove:UnregisterFrame(addOnName, frameName, true);

end

function BlizzMove:EnableFrame(addOnName, frameName)
	if (not addOnName) then addOnName = self.name; end

	if (not self:IsFrameDisabled(addOnName, frameName)) then return; end

	if (self:IsFrameDefaultDisabled(addOnName, frameName)) then
		self.DB.enabledFrames                       = self.DB.enabledFrames or {};
		self.DB.enabledFrames[addOnName]            = self.DB.enabledFrames[addOnName] or {};
		self.DB.enabledFrames[addOnName][frameName] = true;
	end

	if (self:IsFrameDisabled(addOnName, frameName)) then
		self.DB.disabledFrames[addOnName][frameName] = nil;
	end

	local frame = self:GetFrameFromName(frameName)
	local frameData;

	if (frame and frame.frameData) then
		frameData = frame.frameData;
	elseif (self.Frames[addOnName] and self.Frames[addOnName][frameName]) then
		frameData = self.Frames[addOnName][frameName];
	end

	if (frameData) then
		self:ProcessFrame(addOnName, frameName, frameData, (frameData.storage and frameData.storage.frameParent) or nil);
	end

end

function BlizzMove:IsFrameDisabled(addOnName, frameName)
	if (not addOnName) then addOnName = self.name; end

	if (self.DB and self.DB.disabledFrames and self.DB.disabledFrames[addOnName] and self.DB.disabledFrames[addOnName][frameName]) then

		return true;

	end

	if (self:IsFrameDefaultDisabled(addOnName, frameName) and not (self.DB and self.DB.enabledFrames and self.DB.enabledFrames[addOnName] and self.DB.enabledFrames[addOnName][frameName])) then

		return true;

	end

	return false;
end

function BlizzMove:IsFrameDefaultDisabled(addOnName, frameName)
	if (not addOnName) then addOnName = self.name; end

	if (self.Frames[addOnName] and self.Frames[addOnName][frameName] and self.Frames[addOnName][frameName].DefaultDisabled) then

		return true;

	end

	return false;
end

------------------------------------------------------------------------------------------------------
-- Main: Helper Functions
------------------------------------------------------------------------------------------------------
function BlizzMove:GetFrameFromName(frameName)
	local frameTable = _G;

	for keyName in string__gmatch(frameName, "([^.]+)") do
		if not frameTable[keyName] then return nil; end

		frameTable = frameTable[keyName];
	end

	return frameTable;
end

function BlizzMove:ResetPointStorage()
	self.DB.points = {};
end

function BlizzMove:ResetScaleStorage()
	self.DB.scales = {};
end

function BlizzMove:SetupPointStorage(frame)
	if not frame or not frame.frameData or not frame.frameData.storage or not frame.frameData.storage.frameName then return false; end

	if self.DB.savePosStrategy ~= "permanent" then
		if not frame.frameData.storage.points then
			frame.frameData.storage.points = {};
		end
		return true;
	end

	local frameName = frame.frameData.storage.frameName;

	if frame.frameData.storage.points and frame.frameData.storage.points == self.DB.points[frameName] then return true; end
	if self.DB.points[frameName] == nil then
		self.DB.points[frameName] = {};
	end
	frame.frameData.storage.points = self.DB.points[frameName];

	return true;
end

local _, buildNumber, _, gameVersion = GetBuildInfo();

BlizzMove.gameBuild   = tonumber(buildNumber);
BlizzMove.gameVersion = tonumber(gameVersion);

function BlizzMove:MatchesCurrentBuild(frameData)

	-- Compare versus current build version.
	if frameData.MinBuild and frameData.MinBuild > self.gameBuild then return false; end
	if frameData.MaxBuild and frameData.MaxBuild <= self.gameBuild then return false; end

	-- Compare versus current interface version.
	if frameData.MinVersion and frameData.MinVersion > self.gameVersion then return false; end
	if frameData.MaxVersion and frameData.MaxVersion <= self.gameVersion then return false; end

	return true;
end

function BlizzMove:CopyTable(table)
	local copy = {};
	for k, v in pairs(table) do
		if (type(v) == "table") then
			copy[k] = self:CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

------------------------------------------------------------------------------------------------------
-- Main: Helper Functions
------------------------------------------------------------------------------------------------------
local function GetFramePoints(frame)
	local numPoints = frame:GetNumPoints();

	if numPoints then
		local framePoints = {};

		for curPoint = 1, numPoints do
			framePoints[curPoint] = {};
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
	if InCombatLockdown() and frame:IsProtected() then return false; end

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
	local parentScale = (frameData.storage.frameParent and not frameData.ManuallyScaleWithParent and GetFrameScale(frameData.storage.frameParent)) or 1;

	return frame:GetScale() * parentScale;
end

local function SetFrameScaleSubs(frame, oldScale, newScale)
	local frameData = frame.frameData;

	if frameData.SubFrames then
		for subFrameName, subFrameData in pairs(frameData.SubFrames) do
			if subFrameData.storage then
				local subFrame = subFrameData.storage.frame;

				if subFrame then

					if subFrameData.ManuallyScaleWithParent and not subFrameData.storage.detached then

						subFrame:SetScale((subFrame:GetScale() / oldScale) * newScale);
						BlizzMove:DebugPrint("SetSubFrameScale:", subFrameName, string__format("%.2f %.2f %.2f %.2f", oldScale, newScale, subFrame:GetScale(), GetFrameScale(subFrame)));

					elseif not subFrameData.ManuallyScaleWithParent and subFrameData.storage.detached then

						subFrame:SetScale((oldScale * subFrame:GetScale()) / newScale);
						BlizzMove:DebugPrint("SetSubFrameScale:", subFrameName, string__format("%.2f %.2f %.2f %.2f", oldScale, newScale, subFrame:GetScale(), GetFrameScale(subFrame)));

					else
						SetFrameScaleSubs(subFrame, oldScale, newScale);
					end
				end
			end
		end
	end
end

local function SetFrameScale(frame, frameScale)
	local frameData = frame.frameData;
	local oldScale = GetFrameScale(frame);
	local newScale = frameScale;

	if frameData.storage.detached then
		local parentScale = GetFrameScale(frameData.storage.frameParent);
		newScale = frameData.ManuallyScaleWithParent and frameScale or (frameScale / parentScale);
	elseif frameData.ManuallyScaleWithParent then
		-- not detached, but scaled directly => full reset
		local parentScale = GetFrameScale(frameData.storage.frameParent);
		newScale = parentScale;
	end

	if (BlizzMove.DB.saveScaleStrategy == 'permanent') then
		BlizzMove.DB.scales[frameData.storage.frameName] = newScale;
	end

	frame:SetScale(newScale);
	BlizzMove:DebugPrint("SetFrameScale:", frameData.storage.frameName, string__format("%.2f %.2f %.2f", frameScale, frame:GetScale(), GetFrameScale(frame)));

	SetFrameScaleSubs(frame, oldScale, newScale);
	return true;
end

local function SetFrameParentSubs(frame)

	local frameData = frame.frameData;
	local returnValue = true;

	if not frameData or not frameData.SubFrames then return returnValue end

	for subFrameName, subFrameData in pairs(frameData.SubFrames) do

		local subFrame = BlizzMove:GetFrameFromName(subFrameName);

		if subFrame and BlizzMove:MatchesCurrentBuild(subFrameData) then

			if subFrameData.ForceParentage and subFrame.GetParent and subFrame.SetParent and subFrame:GetParent() ~= frame then
				subFrame:SetParent(frame);
			elseif subFrameData.ForceParentage then
				returnValue = false;
			end

			returnValue = SetFrameParentSubs(subFrame) and returnValue;

		end

	end

	return returnValue;

end

local function SetFrameParent(frame)

	local frameData = frame.frameData;

	return (frameData.storage.frameParent and SetFrameParent(frameData.storage.frameParent)) or SetFrameParentSubs(frame);

end

------------------------------------------------------------------------------------------------------
-- Main: Hooks
------------------------------------------------------------------------------------------------------
local function OnMouseDown(frame, button)

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;

	BlizzMove:DebugPrint("OnMouseDown:", frameData.storage.frameName, button);

	if button == "LeftButton" then

		if IsAltKeyDown() and frameData.Detachable and not frameData.storage.detached then

			frameData.storage.points.detachPoints = GetFramePoints(frame);
			frameData.storage.detached = true;
			returnValue = true;

			PlaySound((SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_OPEN) or 839);

		end

		if not frameData.storage.detached then
			parentReturnValue = (frameData.storage.frameParent and OnMouseDown(frameData.storage.frameParent, button));
		end

		if frameData.storage.detached or not parentReturnValue then

			if not (BlizzMove.DB and BlizzMove.DB.requireMoveModifier) or IsShiftKeyDown() then

				local userPlaced = frame:IsUserPlaced();

				frame:StartMoving();
				frame:SetUserPlaced(userPlaced);
				frameData.storage.isMoving = true;
				returnValue = true;

			end

		end

	end

	return returnValue or parentReturnValue;
end

local function OnMouseUp(frame, button)

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;
	BlizzMove:SetupPointStorage(frame);

	BlizzMove:DebugPrint("OnMouseUp:", frameData.storage.frameName, button);

	if not frameData.storage.detached then
		parentReturnValue = (frameData.storage.frameParent and OnMouseUp(frameData.storage.frameParent, button));
	end

	if frameData.storage.detached or not parentReturnValue then

		if button == "LeftButton" then

			if frameData.storage.isMoving then

				frame:StopMovingOrSizing();

				frameData.storage.points.dragPoints = GetFramePoints(frame);
				frameData.storage.points.dragged = true;
				frameData.storage.isMoving = nil;
				returnValue = true;

			end

		elseif button == "RightButton" then

			local fullReset = false;

			if IsAltKeyDown() and frameData.storage.detached then

				if SetFramePoints(frame, frameData.storage.points.detachPoints) then

					frameData.storage.points.detachPoints = nil;
					frameData.storage.detached = nil;
					returnValue = true;
					fullReset = true;

					PlaySound((SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_CLOSE) or 840);

				end

			end

			if IsControlKeyDown() or fullReset then

				returnValue = SetFrameScale(frame, 1) or returnValue;

			end

			if IsShiftKeyDown() or fullReset then

				frameData.storage.points.dragPoints = nil;
				frameData.storage.points.dragged = nil;
				returnValue = true;

				UpdateUIPanelPositions(frame);

			end

			returnValue = true;

		end

	end

	return returnValue or parentReturnValue;
end

local function OnMouseWheelChildren(frame, delta, scrollBar)
	local returnValue = false;

	for _, childFrame in pairs({ frame:GetChildren() }) do
		local OnMouseWheel = childFrame:GetScript("OnMouseWheel");

		if OnMouseWheel and MouseIsOver(childFrame) then
			OnMouseWheel(childFrame, delta, scrollBar, true);
			returnValue = true;
		end

		returnValue = OnMouseWheelChildren(childFrame, delta, scrollBar) or returnValue;
	end

	return returnValue;
end

local function OnMouseWheel(frame, delta, scrollBar, nestedCall)

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	local returnValue = false;
	local parentReturnValue = false;
	local frameData = frame.frameData;

	BlizzMove:DebugPrint("OnMouseWheel:", frameData.storage.frameName, delta, nestedCall);

	local onChildren = not IsControlKeyDown() and not nestedCall and OnMouseWheelChildren(frame, delta, scrollBar);

	if not onChildren and not nestedCall and not frameData.storage.detached then
		parentReturnValue = (frameData.storage.frameParent and OnMouseWheel(frameData.storage.frameParent, delta, scrollBar));
	end

	if not nestedCall and (frameData.storage.detached or not parentReturnValue) then

		if IsControlKeyDown() then

			local oldScale = GetFrameScale(frame) or 1;

			local newScale = oldScale + 0.1 * delta;

			if newScale > 1.5 then newScale = 1.5; end
			if newScale < 0.5 then newScale = 0.5; end

			returnValue = SetFrameScale(frame, newScale) or returnValue;

		end

	end

	return returnValue or parentReturnValue;
end

local function OnShow(frame)

	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	BlizzMove:DebugPrint("OnShow:", frame.frameData.storage.frameName);

	SetFrameParent(frame);

	if(BlizzMove.DB.saveScaleStrategy == 'permanent' and BlizzMove.DB.scales[frame.frameData.storage.frameName]) then
		SetFrameScale(frame, BlizzMove.DB.scales[frame.frameData.storage.frameName]);
	end

end

------------------------------------------------------------------------------------------------------
-- Main: Secure Hooks
------------------------------------------------------------------------------------------------------
local function OnSetPoint(frame, anchorPoint, relativeFrame, relativePoint, offX, offY)
	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	if BlizzMove.DB.savePosStrategy == "off" then return; end

	if frame.ignoreSetPointHook then return; end

	BlizzMove:SetupPointStorage(frame);

	if frame.frameData.storage.points.dragged then
		SetFramePoints(frame, frame.frameData.storage.points.dragPoints);
	end
end

local function OnSizeUpdate(frame)
	if not frame.frameData or not frame.frameData.storage or frame.frameData.storage.disabled then return; end

	local clampDistance = 40;
	local clampWidth = (frame:GetWidth() - clampDistance) or 0;
	local clampHeight = (frame:GetHeight() - clampDistance) or 0;

	frame:SetClampRectInsets(clampWidth, -clampWidth, -clampHeight, clampHeight);
end
------------------------------------------------------------------------------------------------------
-- Main: Frame Functions
------------------------------------------------------------------------------------------------------
local function MakeFrameMovable(frame, frameName, frameData, frameParent)
	if not frame then return false; end

	if InCombatLockdown() and frame:IsProtected() then return false; end

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

			if not frameData.NonDraggable then

				frame:EnableMouse(true);

			end

			frame:EnableMouseWheel(true);

		end

		return true;
	end

	if frame and frame.frameData and frame.frameData.storage and not frameData.storage then
		frameData.storage = frame.frameData.storage;
		frameData.storage.frameName = frameName;
		frameData.storage.frameParent = frameParent;
		frame.frameData = frameData;
	end

	if not frame or (frameData.storage and frameData.storage.hooked) then return false; end

	frame:SetMovable(true);
	frame:SetClampedToScreen(clampFrame);

	if not frameData.IgnoreMouse then

		if not frameData.NonDraggable then

			frame:EnableMouse(true);
			BlizzMove:SecureHookScript(frame, "OnMouseDown", OnMouseDown);
			BlizzMove:SecureHookScript(frame, "OnMouseUp",   OnMouseUp);

		end

		frame:EnableMouseWheel(true);
		BlizzMove:SecureHookScript(frame, "OnMouseWheel", OnMouseWheel);

	end

	BlizzMove:SecureHookScript(frame, "OnShow", OnShow);
	BlizzMove:SecureHookScript(frame, "OnHide", function() end);

	BlizzMove:SecureHook(frame, "SetPoint",  OnSetPoint);
	BlizzMove:SecureHook(frame, "SetWidth",  OnSizeUpdate);
	BlizzMove:SecureHook(frame, "SetHeight", OnSizeUpdate);

	OnSizeUpdate(frame);

	frameData.storage = {};
	frameData.storage.hooked = true;
	frameData.storage.frame = frame;
	frameData.storage.frameName = frameName;
	frameData.storage.frameParent = frameParent;

	frame.frameData = frameData;

	return true;
end

local function MakeFrameUnmovable(frame, frameName, frameData)
	if not frame or not frameData.storage or not frameData.storage.hooked then return false; end

	if InCombatLockdown() and frame:IsProtected() then return false; end

	frame:SetMovable(false);
	frame:SetClampedToScreen(false);

	if not frameData.IgnoreMouse then
		frame:EnableMouse(false);
		frame:EnableMouseWheel(false);
	end

	frameData.storage.disabled = true;

	return true;
end

function BlizzMove:MakeFrameMovable(frame, frameName, frameData, frameParent)
	return xpcall(MakeFrameMovable, CallErrorHandler, frame, frameName, frameData, frameParent);
end

function BlizzMove:MakeFrameUnmovable(frame, frameName, frameData)
	return xpcall(MakeFrameUnmovable, CallErrorHandler, frame, frameName, frameData);
end

function BlizzMove:ProcessFrame(addOnName, frameName, frameData, frameParent)

	if self:IsFrameDisabled(addOnName, frameName) then return; end

	local matchesBuild = self:MatchesCurrentBuild(frameData);

	local frame = self:GetFrameFromName(frameName);

	if(not matchesBuild) then
		if(frame and not frameData.SilenceCompatabilityWarnings) then
			self:Print("Frame was marked as incompatible, but does exist ( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);
		end

		return false;
	end

	if frame then

		if self:MakeFrameMovable(frame, frameName, frameData, frameParent) then

			if frameData.SubFrames then

				for subFrameName, subFrameData in pairs(frameData.SubFrames) do

					self:ProcessFrame(addOnName, subFrameName, subFrameData, frame);

				end

			end

		else

			self:Print("Failed to make frame movable:", frameName);

		end

	else

		self:Print("Could not find frame ( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);

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

		if not frame.frameData then return; end

		local frameData = frame.frameData;

		if not self:MatchesCurrentBuild(frameData) then return; end

		self:MakeFrameUnmovable(frame, frameName, frame.frameData);

		if frame.frameData.SubFrames then

			for subFrameName, _ in pairs(frame.frameData.SubFrames) do

				self:UnprocessFrame(subFrameName);

			end

		end

	end

end

function BlizzMove:OnInitialize()

	self.initialized = true;

	_G.BlizzMoveDB = _G.BlizzMoveDB or {};
	self.DB = _G.BlizzMoveDB;
	self:InitDefaults();

	self.Config:Initialize();

	self:RegisterChatCommand('blizzmove', 'OnSlashCommand');
	self:RegisterChatCommand('bm', 'OnSlashCommand');

	self:ProcessFrames(self.name);

end

function BlizzMove:OnSlashCommand(message)
	local arg1, arg2 = strsplit(' ', message);
	if (
		arg1 == 'dumpDebugInfo'
		or arg1 == 'dumpChangedCVars'
	) then
		local loaded = LoadAddOn('BlizzMove_Debug');
		local DebugModule = loaded and self:GetModule('Debug');
		if (not DebugModule) then
			self:Print('Could not load BlizzMove_Debug plugin');
			return;
		end

		if arg1 == 'dumpDebugInfo' then
			-- `/bm dumpDebugInfo 1` will extract all CVars rather than just ones that got changed from the default
			DebugModule:DumpAllData(arg2 ~= '1');
		elseif arg1 == 'dumpChangedCVars' then
			DebugModule:DumpCVars({ changedOnly = true, pastableFormat = true });
		end

		return;
	end

	-- after a reload, you need to open to category twice to actually open the correct page
	InterfaceOptionsFrame_OpenToCategory('BlizzMove'); InterfaceOptionsFrame_OpenToCategory('BlizzMove');
end

function BlizzMove:InitDefaults()
	local defaults = {
		savePosStrategy = "session",
		saveScaleStrategy = "session",
		points = {},
		scales = {},
	};

	for property, value in pairs(defaults) do
		if self.DB[property] == nil then
			self.DB[property] = value;
		end
	end

end

function BlizzMove:ADDON_LOADED(event, addOnName)

	if addOnName ~= self.name then self:ProcessFrames(addOnName); end

end

function BlizzMove:OnEnable()

	self.enabled = true;

	for addOnName, _ in pairs(self.Frames) do

		if addOnName ~= self.name and IsAddOnLoaded(addOnName) then

			self:ProcessFrames(addOnName);

		end

	end

	self:RegisterEvent("ADDON_LOADED");

end
