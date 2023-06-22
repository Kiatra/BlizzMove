-- up-value the globals
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
local tinsert = _G.tinsert;
local unpack = _G.unpack;
local wipe = _G.wipe;
local GetScreenWidth = _G.GetScreenWidth;
local GetScreenHeight = _G.GetScreenHeight;
local CreateFrame = _G.CreateFrame;
local abs = _G.abs;

local name = ... or "BlizzMove";
--- @class BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");
if not BlizzMove then return; end

BlizzMove.Frames = BlizzMove.Frames or {};
BlizzMove.FrameData = BlizzMove.FrameData or {};
BlizzMove.FrameRegistry = BlizzMove.FrameRegistry or {};
BlizzMove.CombatLockdownQueue = BlizzMove.CombatLockdownQueue or {};

------------------------------------------------------------------------------------------------------
--- Debug Functions
------------------------------------------------------------------------------------------------------
do
	function BlizzMove:DebugPrint(...)
		if self.DB and self.DB.DebugPrints then self:Print("Debug message:\n", ...); end
	end
end

------------------------------------------------------------------------------------------------------
--- Frame Registration and Enabling/Disabling Functions
------------------------------------------------------------------------------------------------------
local IsFrame;
do
	function IsFrame(value)
		return type(value) == "table" and value.GetObjectType and value:GetObjectType() == "Frame";
	end

	function BlizzMove:ValidateFrame(frameName, frameData, isSubFrame)
		return self:ValidateFrameName(frameName) and self:ValidateFrameData(frameName, frameData, isSubFrame);
	end

	function BlizzMove:ValidateFrameName(frameName)
		return #frameName > 0;
	end

	function BlizzMove:ValidateFrameData(frameName, frameData, isSubFrame)
		local validationError;

		for key, value in pairs(frameData) do
			if key == "SubFrames" then
				if type(value) ~= "table" then validationError = true; end
				for subFrameName, subFrameData in pairs(value) do
					if not self:ValidateFrame(subFrameName, subFrameData, true) then validationError = true; break; end
				end
			elseif (
				key == "MinVersion"
				or key == "MaxVersion"
				or key == "MinBuild"
				or key == "MaxBuild"
			) then
				if (type(value) ~= "number" or value < 0) then validationError = true; end
			elseif (
				key == "BuildRanges"
				or key == "VersionRanges"
			) then
				if (type(value) ~= "table") then
					validationError = true;
				else
					for _, range in pairs(value) do
						if (
							type(range) ~= "table"
							or (range.Min and (type(range.Min) ~= "number" or range.Min < 0))
							or (range.Max and (type(range.Max) ~= "number" or range.Max < 0))
						) then
							validationError = true;
							break;
						end
					end
				end
			elseif (
				key == "Detachable"
				or key == "ManuallyScaleWithParent"
			) then
				if (type(value) ~= "boolean" or (value == true and not isSubFrame)) then validationError = true; end
			elseif (
				key == "IgnoreMouse"
				or key == "IgnoreMouseWheel"
				or key == "ForceParentage"
				or key == "NonDraggable"
				or key == "DefaultDisabled"
				or key == "SilenceCompatabilityWarnings"
			) then
				if type(value) ~= "boolean" then validationError = true; end
			elseif key == "FrameReference" then
				if not IsFrame(value) then validationError = true; end
			else
				self:Print("Ignoring unsupported key supplied in frameData, for frame:", frameName, "; key:", key);
			end

			if (validationError) then
				self:Print('Validation error, frame:', frameName, '; key:', key, '; value:', value);

				return false;
			end
		end

		return true;
	end

	function BlizzMove:RegisterFrame(addOnName, frameName, frameData, skipConfigUpdate)
		if not addOnName then addOnName = self.name; end

		local copiedData = self:CopyTable(frameData);

		self.Frames[addOnName]            = self.Frames[addOnName] or {};
		self.Frames[addOnName][frameName] = copiedData;

		if (
			not self:IsFrameDisabled(addOnName, frameName)
			and IsAddOnLoaded(addOnName)
			and (addOnName ~= self.name and self.enabled or self.initialized)
		) then
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
			self:UnprocessFrame(addOnName, frameName);
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

		local frame = self:GetFrameFromName(addOnName, frameName)
		local frameData;

		if (frame and self.FrameData[frame]) then
			frameData = self.FrameData[frame];
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

		if (
			self:IsFrameDefaultDisabled(addOnName, frameName)
			and not (self.DB and self.DB.enabledFrames and self.DB.enabledFrames[addOnName] and self.DB.enabledFrames[addOnName][frameName])
		) then
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
end

------------------------------------------------------------------------------------------------------
--- FrameData and storage Functions
------------------------------------------------------------------------------------------------------
do
	function BlizzMove:GetFrameFromName(addOnName, frameName)
		if(self.FrameRegistry[addOnName] and self.FrameRegistry[addOnName][frameName]) then
			return self.FrameRegistry[addOnName][frameName];
		end

		local frameTable = _G;

		for keyName in string__gmatch(frameName, "([^.]+)") do
			if not frameTable[keyName] then return nil; end

			frameTable = frameTable[keyName];
		end

		return frameTable;
	end

	function BlizzMove:GetFrameName(frame)
		return
			frame
			and self.FrameData
			and self.FrameData[frame]
			and self.FrameData[frame].storage
			and self.FrameData[frame].storage.frameName
	end

	function BlizzMove:ResetScaleStorage()
		wipe(self.DB.scales);
	end

	function BlizzMove:ResetPointStorage()
		wipe(self.DB.points);
	end

	function BlizzMove:SetupPointStorage(frame)
		local frameName = self:GetFrameName(frame);
		if not frameName then return false; end

		if self.DB.savePosStrategy ~= "permanent" then
			if not self.FrameData[frame].storage.points then
				self.FrameData[frame].storage.points = {};
			end
			return true;
		end

		if self.FrameData[frame].storage.points and self.FrameData[frame].storage.points == self.DB.points[frameName] then return true; end
		if self.DB.points[frameName] == nil then
			self.DB.points[frameName] = {};
		end
		self.FrameData[frame].storage.points = self.DB.points[frameName];

		if (self.FrameData[frame].storage.points.detachPoints) then
			local relativeFrameName = self.FrameData[frame].storage.points.detachPoints[1].relativeFrameName;
			if (relativeFrameName and self:GetFrameFromName(nil, relativeFrameName)) then
				self.FrameData[frame].storage.detached = true;
				self.FrameData[frame].storage.points.detachPoints[1].relativeFrame = self:GetFrameFromName(nil, relativeFrameName);
			else
				wipe(self.FrameData[frame].storage.points);
			end
		end

		return true;
	end

	local _, buildNumber, _, gameVersion = GetBuildInfo();
	BlizzMove.gameBuild   = tonumber(buildNumber);
	BlizzMove.gameVersion = tonumber(gameVersion);

	local function checkRanges(ranges, needle)
		for _, range in ipairs(ranges) do
			if range.Min <= needle and not range.Max then
				return true;
			end
			if not range.Min and range.Max > needle then
				return true;
			end
			if range.Min <= needle and range.Max > needle then
				return true;
			end
		end
		return false;
	end
	function BlizzMove:MatchesCurrentBuild(frameData)
		-- Compare versus current build version.
		if frameData.MinBuild and frameData.MinBuild > self.gameBuild then return false; end
		if frameData.MaxBuild and frameData.MaxBuild <= self.gameBuild then return false; end

		-- Compare versus current interface version.
		if frameData.MinVersion and frameData.MinVersion > self.gameVersion then return false; end
		if frameData.MaxVersion and frameData.MaxVersion <= self.gameVersion then return false; end

		-- Compare ranges versus current build version.
		if frameData.BuildRanges then
			if not checkRanges(frameData.BuildRanges, self.gameBuild) then return false; end
		end

		-- Compare ranges versus current interface version.
		if frameData.VersionRanges then
			if not checkRanges(frameData.VersionRanges, self.gameVersion) then return false; end
		end

		return true;
	end

	function BlizzMove:CopyTable(table)
		local copy = {};
		for k, v in pairs(table) do
			if (type(v) == "table") then
				if(IsFrame(v)) then
					copy[k] = v;
				else
					copy[k] = self:CopyTable(v);
				end
			else
				copy[k] = v;
			end
		end
		return copy;
	end
end

------------------------------------------------------------------------------------------------------
--- Frame Points Helper Functions
------------------------------------------------------------------------------------------------------
local GetAbsoluteFramePosition;
local GetFramePoints;
local SetFramePoints;
local ignoreSetPointHook = false;
do
	function GetFramePoints(frame)
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

				local relativeFrame = framePoints[curPoint].relativeFrame;
				if (BlizzMove:GetFrameName(relativeFrame)) then
					framePoints[curPoint].relativeFrameName = BlizzMove:GetFrameName(relativeFrame);
				elseif (relativeFrame and relativeFrame.GetName and relativeFrame:GetName()) then
					framePoints[curPoint].relativeFrameName = relativeFrame:GetName();
				end
			end

			return framePoints;
		end

		return false;
	end

	function GetAbsoluteFramePosition(frame)
		-- inspired by LibWindow-1.1 (https://www.wowace.com/projects/libwindow-1-1)

		local scale = frame:GetScale();
		if not scale then return end
		if not frame:GetLeft() then
			local frameData = BlizzMove.FrameData[frame];
			local frameName = frameData and frameData.storage and frameData.storage.frameName or 'unknown';
			local sharedText = string__format('BlizzMove: The frame you just moved (%s) is probably in a broken state, possibly because of other addons. ', frameName);

			local loaded = LoadAddOn('BlizzMove_Debug');
			--- @type BlizzMove_Debug
			local DebugModule = loaded and BlizzMove:GetModule('Debug');
			if (not DebugModule) then
				error(sharedText .. 'Enable the Blizzmove_Debug plugin, to find more debugging information.');
				return;
			end
			local result = DebugModule:FindBadAnchorConnections(frame);
			local text = sharedText .. 'Copy the text from this popup window, and report it to the addon author.\n\nBad anchor connections for "' .. frameName .. '":\n';
			for _, info in pairs(result) do
				text = text .. string__format(
					'\n\n"%s" is outside anchor family, but referenced by "%s" (created in "%s", and "%s" respectively)',
					info.targetName, info.name, info.targetSource, info.source
				);
			end
			DebugModule:GetMainFrame(text):Show();
			error(sharedText .. 'Copy the text from the popup window, and report it to the addon author.');
			return;
		end
		local left, top = frame:GetLeft() * scale, frame:GetTop() * scale
		local right, bottom = frame:GetRight() * scale, frame:GetBottom() * scale
		local parentWidth = GetScreenWidth();
		local parentHeight = GetScreenHeight();

		local horizontalOffsetFromCenter = (left + right) / 2 - parentWidth / 2;
		local verticalOffsetFromCenter = (top + bottom) / 2 - parentHeight / 2;

		local x, y, point = 0, 0, "";
		if (left < (parentWidth - right) and left < abs(horizontalOffsetFromCenter))
		then
			x = left;
			point = "LEFT";
		elseif ((parentWidth - right) < abs(horizontalOffsetFromCenter)) then
			x = right - parentWidth;
			point = "RIGHT";
		else
			x = horizontalOffsetFromCenter;
		end

		if bottom < (parentHeight - top) and bottom < abs(verticalOffsetFromCenter) then
			y = bottom;
			point = "BOTTOM" .. point;
		elseif (parentHeight - top) < abs(verticalOffsetFromCenter) then
			y = top - parentHeight;
			point = "TOP" .. point;
		else
			y = verticalOffsetFromCenter;
		end

		if point == "" then
			point = "CENTER"
		end

		BlizzMove:DebugPrint("GetAbsoluteFramePosition", "x:", math.floor(x), "y:", math.floor(y), "point:", point);

		-- the nested table is for backwards compatibility
		return {
			{
				["anchorPoint"] = point,
				["relativeFrame"] = "UIParent",
				["relativePoint"] = point,
				["offX"] = x,
				["offY"] = y,
			},
		};
	end

	function SetFramePoints(frame, framePoints)
		if InCombatLockdown() and frame:IsProtected() then return false; end

		if framePoints and framePoints[1] then
			frame:ClearAllPoints();
			local SetPoint = frame.SetPointBase or frame.SetPoint;

			for curPoint = 1, #framePoints do
				ignoreSetPointHook = true;
				SetPoint(
					frame,
					framePoints[curPoint].anchorPoint,
					framePoints[curPoint].relativeFrame,
					framePoints[curPoint].relativePoint,
					framePoints[curPoint].offX,
					framePoints[curPoint].offY
				);
				ignoreSetPointHook = false;
			end
		end

		return true;
	end
end

------------------------------------------------------------------------------------------------------
--- Frame Scale Functions
------------------------------------------------------------------------------------------------------
local GetFrameScale;
local SetFrameScale;
do
	function GetFrameScale(frame)
		local frameData = BlizzMove.FrameData[frame];
		local parentScale = (frameData.storage.frameParent and not frameData.ManuallyScaleWithParent and GetFrameScale(frameData.storage.frameParent)) or 1;

		return frame:GetScale() * parentScale;
	end

	local function SetFrameScaleSubs(frame, oldScale, newScale)
		local frameData = BlizzMove.FrameData[frame];

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

	function SetFrameScale(frame, frameScale)
		local frameData = BlizzMove.FrameData[frame];
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

		BlizzMove.DB.scales[frameData.storage.frameName] = newScale;
		frame:SetScale(newScale);
		BlizzMove:DebugPrint("SetFrameScale:", frameData.storage.frameName, string__format("%.2f %.2f %.2f", frameScale, frame:GetScale(), GetFrameScale(frame)));

		SetFrameScaleSubs(frame, oldScale, newScale);

		return true;
	end
end

------------------------------------------------------------------------------------------------------
--- Frame Parentage Functions
------------------------------------------------------------------------------------------------------
local SetFrameParent;
do
	local function SetFrameParentSubs(frame, addOnName)
		local frameData = BlizzMove.FrameData[frame];
		local returnValue = true;

		if not frameData or not frameData.SubFrames then return returnValue end

		for subFrameName, subFrameData in pairs(frameData.SubFrames) do
			local subFrame = BlizzMove:GetFrameFromName(addOnName, subFrameName);

			if subFrame and BlizzMove:MatchesCurrentBuild(subFrameData) then
				if subFrameData.ForceParentage and subFrame.GetParent and subFrame.SetParent and subFrame:GetParent() ~= frame then
					subFrame:SetParent(frame);
				elseif subFrameData.ForceParentage then
					returnValue = false;
				end
				returnValue = SetFrameParentSubs(subFrame, addOnName) and returnValue;
			end
		end

		return returnValue;
	end

	function SetFrameParent(frame)
		local frameData = BlizzMove.FrameData[frame];

		return (frameData.storage.frameParent and SetFrameParent(frameData.storage.frameParent)) or SetFrameParentSubs(frame, frameData.storage.addOnName);
	end
end

------------------------------------------------------------------------------------------------------
--- Secure Script Hook Handlers
------------------------------------------------------------------------------------------------------
local OnMouseDown;
local OnMouseUp;
local OnMouseWheel;
local OnShow;
local OnSubFrameHide;
do
	function OnMouseDown(frame, button)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		local returnValue = false;
		local parentReturnValue = false;
		local frameData = BlizzMove.FrameData[frame];
		BlizzMove:SetupPointStorage(frame);

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

			if (
				(frameData.storage.detached or not parentReturnValue)
				and (not (BlizzMove.DB and BlizzMove.DB.requireMoveModifier) or IsShiftKeyDown())
			) then
					local userPlaced = frame:IsUserPlaced();

					frame:StartMoving();
					frame:SetUserPlaced(userPlaced);
					frameData.storage.points.startPoints = frameData.storage.points.startPoints or GetFramePoints(frame);
					frameData.storage.isMoving = true;
					returnValue = true;
			end
		end

		return returnValue or parentReturnValue;
	end

	function OnMouseUp(frame, button)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		local returnValue = false;
		local parentReturnValue = false;
		local frameData = BlizzMove.FrameData[frame];

		BlizzMove:DebugPrint("OnMouseUp:", frameData.storage.frameName, button);

		if not frameData.storage.detached then
			parentReturnValue = (frameData.storage.frameParent and OnMouseUp(frameData.storage.frameParent, button));
		end

		if frameData.storage.detached or not parentReturnValue then
			if button == "LeftButton" and frameData.storage.isMoving then
				frame:StopMovingOrSizing();

				frameData.storage.points.dragPoints = GetAbsoluteFramePosition(frame);
				frameData.storage.points.dragged = true;
				frameData.storage.isMoving = nil;
				returnValue = true;

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
					if(frameData.storage.points) then
						if (not fullReset and frameData.storage.points.startPoints) then
							SetFramePoints(frame, frameData.storage.points.startPoints);
							frameData.storage.points.startPoints = nil;
						end

						frameData.storage.points.dragPoints = nil;
						frameData.storage.points.dragged = nil;
					end
					returnValue = true;
					UpdateUIPanelPositions(frame);
				end

				returnValue = true;
			end
		end

		return returnValue or parentReturnValue;
	end

	local nestedOnMouseWheelCall;
	local function OnMouseWheelChildren(frame, ...)
		local returnValue = false;

		for _, childFrame in pairs({ frame:GetChildren() }) do
			local childOnMouseWheel = childFrame:GetScript("OnMouseWheel");

			if childOnMouseWheel and MouseIsOver(childFrame) then
				nestedOnMouseWheelCall = true;
				childOnMouseWheel(childFrame, ...);
				nestedOnMouseWheelCall = false;
				returnValue = true;
			end

			returnValue = OnMouseWheelChildren(childFrame, ...) or returnValue;
		end

		return returnValue;
	end

	function OnMouseWheel(frame, delta, ...)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		local returnValue = false;
		local parentReturnValue = false;
		local frameData = BlizzMove.FrameData[frame];

		BlizzMove:DebugPrint("OnMouseWheel:", frameData.storage.frameName, delta, nestedOnMouseWheelCall);

		local onChildren = not IsControlKeyDown() and not nestedOnMouseWheelCall and OnMouseWheelChildren(frame, delta, ...);

		if not onChildren and not nestedOnMouseWheelCall and not frameData.storage.detached then
			parentReturnValue = (frameData.storage.frameParent and OnMouseWheel(frameData.storage.frameParent, delta, ...));
		end

		if (not nestedOnMouseWheelCall and (frameData.storage.detached or not parentReturnValue) and IsControlKeyDown()) then
			local oldScale = GetFrameScale(frame) or 1;

			local newScale = oldScale + 0.1 * delta;

			if newScale > 1.5 then newScale = 1.5; end
			if newScale < 0.5 then newScale = 0.5; end

			returnValue = SetFrameScale(frame, newScale) or returnValue;
		end

		return returnValue or parentReturnValue;
	end

	function OnShow(frame)

		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		BlizzMove:DebugPrint("OnShow:", BlizzMove:GetFrameName(frame));

		if InCombatLockdown() and frame:IsProtected() then
			BlizzMove:AddToCombatLockdownQueue(OnShow, frame);
			BlizzMove:DebugPrint('Adding to combatLockdownQueue: OnShow - ', BlizzMove:GetFrameName(frame));

			return;
		end

		SetFrameParent(frame);

		if(BlizzMove.DB.saveScaleStrategy == 'permanent' and BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]) then
			SetFrameScale(frame, BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]);
		end

	end

	function OnSubFrameHide(frame)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		local frameData = BlizzMove.FrameData[frame];
		local parent = frameData.storage.frameParent or nil;

		BlizzMove:DebugPrint("OnHide:", frameData.storage.frameName, frameData.storage.isMoving);
		if parent then return OnSubFrameHide(parent); end

		if frameData.storage.isMoving then
			BlizzMove:WaitForGlobalMouseUp(frame);
		end
	end
end

------------------------------------------------------------------------------------------------------
--- Secure Hook Handlers
------------------------------------------------------------------------------------------------------
local OnSetPoint;
local OnSizeUpdate;
do
	function OnSetPoint(frame, ...)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		if BlizzMove.DB.savePosStrategy == "off" then return; end

		if ignoreSetPointHook then return; end

		BlizzMove:SetupPointStorage(frame);

		if BlizzMove.FrameData[frame].storage.points.dragged then
			if BlizzMove.DB.savePosStrategy ~= "permanent" then
				SetFramePoints(frame, BlizzMove.FrameData[frame].storage.points.dragPoints);
			else
				BlizzMove:AddToSetFramePointsQueue(frame, BlizzMove.FrameData[frame].storage.points.dragPoints);
			end
		end
	end

	function OnSizeUpdate(frame)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		local clampDistance = 40;
		local clampWidth = (frame:GetWidth() - clampDistance) or 0;
		local clampHeight = (frame:GetHeight() - clampDistance) or 0;

		frame:SetClampRectInsets(clampWidth, -clampWidth, -clampHeight, clampHeight);
	end
end

------------------------------------------------------------------------------------------------------
--- Secure Global Hook Handlers
------------------------------------------------------------------------------------------------------
local OnUpdateScaleForFit;
do
	function OnUpdateScaleForFit(frame)
		if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

		BlizzMove:DebugPrint("OnUpdateScaleForFit:", BlizzMove:GetFrameName(frame));

		if InCombatLockdown() and frame:IsProtected() then
			BlizzMove:AddToCombatLockdownQueue(OnUpdateScaleForFit, frame);
			BlizzMove:DebugPrint('Adding to combatLockdownQueue: OnUpdateScaleForFit - ', BlizzMove:GetFrameName(frame));

			return;
		end

		if(BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]) then
			SetFrameScale(frame, BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]);
		end
	end
end

------------------------------------------------------------------------------------------------------
--- Processing Frame Functions
------------------------------------------------------------------------------------------------------
do
	local function hookScript(frame, script, handler)
		BlizzMove:SecureHookScript(frame, script, handler);
		if (frame:HasScript(script)) then
			hooksecurefunc(frame, 'SetScript', function(self, scriptName)
				if (scriptName == script and self == frame) then
					BlizzMove:DebugPrint('SetScript hook triggered for ', BlizzMove:GetFrameName(frame), scriptName);
					BlizzMove:Unhook(frame, script);
					BlizzMove:SecureHookScript(frame, script, handler);
				end
			end);
		end
	end

	local function MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent)
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

				if not frameData.IgnoreMouseWheel then
					frame:EnableMouseWheel(true);
				end
			end

			return true;
		end

		if frame and BlizzMove.FrameData[frame] and BlizzMove.FrameData[frame].storage and not frameData.storage then
			frameData.storage = BlizzMove.FrameData[frame].storage;
			frameData.storage.frameName = frameName;
			frameData.storage.addOnName = addOnName;
			frameData.storage.frameParent = frameParent;
			BlizzMove.FrameData[frame] = frameData;
		end

		if not frame or (frameData.storage and frameData.storage.hooked) then return false; end

		frame:SetMovable(true);
		frame:SetClampedToScreen(clampFrame);

		if not frameData.IgnoreMouse then
			if not frameData.NonDraggable then
				frame:EnableMouse(true);
				hookScript(frame, "OnMouseDown", OnMouseDown);
				hookScript(frame, "OnMouseUp",   OnMouseUp);
			end

			if not frameData.IgnoreMouseWheel then
				frame:EnableMouseWheel(true);
				hookScript(frame, "OnMouseWheel", OnMouseWheel);
			end
		end

		hookScript(frame, "OnShow", OnShow);
		if frameParent then
			hookScript(frame, "OnHide", OnSubFrameHide);
		end

		BlizzMove:SecureHook(frame, "SetPoint",  OnSetPoint);
		BlizzMove:SecureHook(frame, "SetWidth",  OnSizeUpdate);
		BlizzMove:SecureHook(frame, "SetHeight", OnSizeUpdate);

		frameData.storage = {};
		frameData.storage.hooked = true;
		frameData.storage.frame = frame;
		frameData.storage.frameName = frameName;
		frameData.storage.frameParent = frameParent;

		BlizzMove.FrameData[frame] = frameData;

		OnSizeUpdate(frame);
		OnSetPoint(frame);

		return true;
	end

	local function MakeFrameUnmovable(frame, frameData)
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

	function BlizzMove:MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent)
		return xpcall(MakeFrameMovable, CallErrorHandler, frame, addOnName, frameName, frameData, frameParent);
	end

	function BlizzMove:MakeFrameUnmovable(frame, frameData)
		return xpcall(MakeFrameUnmovable, CallErrorHandler, frame, frameData);
	end

	function BlizzMove:ProcessFrame(addOnName, frameName, frameData, frameParent)
		if self:IsFrameDisabled(addOnName, frameName) then return; end

		local matchesBuild = self:MatchesCurrentBuild(frameData);

		if(frameData.FrameReference) then
			self.FrameRegistry[addOnName] = self.FrameRegistry[addOnName] or {}
			self.FrameRegistry[addOnName][frameName] = frameData.FrameReference;
		end

		local frame = self:GetFrameFromName(addOnName, frameName);

		if(not matchesBuild) then
			if(frame and not frameData.SilenceCompatabilityWarnings) then
				self:Print("Frame was marked as incompatible, but does exist ( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);
			end

			return false;
		end

		if not frame then
			self.notFoundFrames = self.notFoundFrames or {};
			tinsert(self.notFoundFrames, frameName);
			self:Print("Could not find frame ( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);

			return false;
		end

		if InCombatLockdown() and frame:IsProtected() then
			self:AddToCombatLockdownQueue(BlizzMove.ProcessFrame, self, addOnName, frameName, frameData, frameParent);
			self:DebugPrint('Adding to combatLockdownQueue: ProcessFrame - ', addOnName, ' - ', frameName);

			return false;
		end

		if not self:MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent) then
			self:Print("Failed to make frame movable:", frameName);

			return false;
		end

		if frameData.SubFrames then
			for subFrameName, subFrameData in pairs(frameData.SubFrames) do
				self:ProcessFrame(addOnName, subFrameName, subFrameData, frame);
			end
		end
	end

	function BlizzMove:ProcessFrames(addOnName)
		if not(self.Frames and self.Frames[addOnName]) then return; end

		for frameName, frameData in pairs(self.Frames[addOnName]) do
			self:ProcessFrame(addOnName, frameName, frameData);
		end
	end

	function BlizzMove:UnprocessFrame(addOnName, frameName)
		local frame = self:GetFrameFromName(addOnName, frameName)

		if not frame then return; end

		if not self.FrameData[frame] then return; end

		local frameData = self.FrameData[frame];

		if not self:MatchesCurrentBuild(frameData) then return; end

		if InCombatLockdown() and frame:IsProtected() then
			self:AddToCombatLockdownQueue(BlizzMove.UnprocessFrame, self, addOnName, frameName);
			self:DebugPrint('Adding to combatLockdownQueue: UnprocessFrame - ', addOnName, ' - ', frameName);

			return;
		end

		self:MakeFrameUnmovable(frame, frameData);

		if frameData.SubFrames then
			for subFrameName, _ in pairs(frameData.SubFrames) do
				self:UnprocessFrame(addOnName, subFrameName);
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
--- Addon Init and Event Handling Functions
------------------------------------------------------------------------------------------------------
do
	function BlizzMove:AddToCombatLockdownQueue(func, ...)
		if #self.CombatLockdownQueue == 0 then
			self:RegisterEvent("PLAYER_REGEN_ENABLED");
		end

		tinsert(self.CombatLockdownQueue, { func = func, args = { ... } });
	end

	function BlizzMove:PLAYER_REGEN_ENABLED()
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
		if #self.CombatLockdownQueue == 0 then return; end
		self:DebugPrint('Processing self.CombatLockdownQueue, length:', #self.CombatLockdownQueue);

		for _, item in pairs(self.CombatLockdownQueue) do
			item.func(unpack(item.args));
		end
		wipe(self.CombatLockdownQueue);
	end

	local setFramePointsQueue = {};
	local onUpdateFrame = CreateFrame("Frame")
	function BlizzMove:SavePositionStrategyChanged(oldValue, newValue)
		if oldValue == 'permanent' then
			self:Unhook(onUpdateFrame, 'OnUpdate')
		end
		if newValue == 'permanent' then
			self:RawHookScript(onUpdateFrame, 'OnUpdate')
		end
	end

	function BlizzMove:AddToSetFramePointsQueue(frame, framePoints)
		if setFramePointsQueue[frame] then return; end
		self:DebugPrint('Adding to setFramePointsQueue: ', frame.GetName and frame:GetName() or 'unknown frame');

		setFramePointsQueue[frame] = framePoints;
	end

	function BlizzMove:OnUpdate()
		local count = 0;
		for frame, framePoints in pairs(setFramePointsQueue) do
			count = count + 1;
			SetFramePoints(frame, framePoints);
		end
		if count == 0 then return; end

		self:DebugPrint('Processed setFramePointsQueue, length: ', count);
		wipe(setFramePointsQueue)
	end

	local awaitingGlobalMouseUp;
	function BlizzMove:WaitForGlobalMouseUp(frame)
		awaitingGlobalMouseUp = frame;
		self:RegisterEvent('GLOBAL_MOUSE_UP');
	end

	function BlizzMove:GLOBAL_MOUSE_UP(event, button)
		self:UnregisterEvent(event);
		if not awaitingGlobalMouseUp then return; end
		self:DebugPrint('Processing global MouseUp event after sub-frame got hidden');

		OnMouseUp(awaitingGlobalMouseUp, button);
		awaitingGlobalMouseUp = nil;
	end

	local commands = {
		dumpDebugInfo = 'dumpDebugInfo',
		dumpChangedCVars = 'dumpChangedCVars',
		debugAnchor = 'debugAnchor',
		debugLoadAll = 'debugLoadAll',
		dumpMissingFrames = 'dumpMissingFrames',
		dumpTopLevelFrames = 'dumpTopLevelFrames',
	};
	function BlizzMove:OnInitialize()
		self.initialized = true;

		_G.BlizzMoveDB = _G.BlizzMoveDB or {};
		self.DB = _G.BlizzMoveDB;
		self:InitDefaults();

		self.Config:Initialize();

		self:RegisterChatCommand('blizzmove', 'OnSlashCommand');
		self:RegisterChatCommand('bm', 'OnSlashCommand');
		for _, command in pairs(commands) do
			self:RegisterChatCommand('bm'..command, function(message) self:OnSlashCommand(command..' '..message); end);
		end
		self:ProcessFrames(self.name);
		self:SecureHook('UpdateScaleForFit', OnUpdateScaleForFit);
	end

	function BlizzMove:OnSlashCommand(message)
		local arg1, arg2 = strsplit(' ', message);
		if (
			arg1 == commands.dumpDebugInfo
			or arg1 == commands.dumpChangedCVars
			or arg1 == commands.debugAnchor
			or arg1 == commands.dumpTopLevelFrames
		) then
			local loaded = LoadAddOn('BlizzMove_Debug');
			--- @type BlizzMove_Debug
			local DebugModule = loaded and self:GetModule('Debug');
			if (not DebugModule) then
				self:Print('Could not load BlizzMove_Debug plugin');

				return;
			end

			if arg1 == commands.dumpDebugInfo then
				-- `/bm dumpDebugInfo 1` will extract all CVars rather than just ones that got changed from the default
				DebugModule:DumpAllData(arg2 ~= '1');
			elseif arg1 == commands.dumpChangedCVars then
				DebugModule:DumpCVars({ changedOnly = true, pastableFormat = true });
			elseif arg1 == commands.debugAnchor then
				local result = DebugModule:FindBadAnchorConnections(self:GetFrameFromName(name, arg2));
				if #result > 0 then
					self:Print('Found bad anchor connections, copy the popup window contents to analyze them.');
					local text = 'Bad anchor connections for "' .. arg2 .. '":\n';
					for _, info in pairs(result) do
						text = text .. string__format(
							'\n\n"%s" is outside anchor family, but referenced by "%s" (created in "%s", and "%s" respectively)',
							info.targetName, info.name, info.targetSource, info.source
						);
					end
					DebugModule:GetMainFrame(text):Show();
				else
					self:Print('No bad anchor connections found');
				end
			elseif arg1 == commands.dumpTopLevelFrames then
				DebugModule:DumpTopLevelFrames();
			end

			return;
		end

		if arg1 == commands.debugLoadAll then
			for addOnName, _ in pairs(self:GetRegisteredAddOns()) do
				self:Print((LoadAddOn(addOnName) and "Loaded") or "Missing", addOnName) ;
			end
			return;
		elseif arg1 == commands.dumpMissingFrames then
			self.Config:ShowURLPopup(
				'Build:' .. self.gameBuild.. '| Version:' .. self.gameVersion.. '| BMVersion:' .. self.Config.version .. "\n\n"
						.. table.concat(self.notFoundFrames or {'<none>'}, "\n")
			);
			return;
		end

		-- after a reload, you need to open to category twice to actually open the correct page
		InterfaceOptionsFrame_OpenToCategory('BlizzMove'); InterfaceOptionsFrame_OpenToCategory('BlizzMove');
	end

	local defaults = {
		savePosStrategy = "session",
		saveScaleStrategy = "session",
		points = {},
		scales = {},
	};
	function BlizzMove:InitDefaults()
		for property, value in pairs(defaults) do
			if self.DB[property] == nil then
				self.DB[property] = value;
			end
		end
	end

	function BlizzMove:ADDON_LOADED(_, addOnName)
		if addOnName ~= self.name then self:ProcessFrames(addOnName); end

		-- fix a stupid anchor family connection issue blizzard added in 9.1.5
		if addOnName == "Blizzard_Collections" then
			local checkbox = _G.WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
			checkbox.Label:ClearAllPoints();
			checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1);
			checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1);
		end
		-- fix another anchor family connection issue caused by blizzard being blizzard
		if addOnName == "Blizzard_EncounterJournal" then
			local replacement = function(rewardFrame)
				if rewardFrame.data then
					_G.EncounterJournalTooltip:ClearAllPoints();
				end
				self.hooks.AdventureJournal_Reward_OnEnter(rewardFrame);
			end
			self:RawHook("AdventureJournal_Reward_OnEnter", replacement, true);
			self:RawHookScript(_G.EncounterJournal.suggestFrame.Suggestion1.reward, "OnEnter", replacement);
			self:RawHookScript(_G.EncounterJournal.suggestFrame.Suggestion2.reward, "OnEnter", replacement);
			self:RawHookScript(_G.EncounterJournal.suggestFrame.Suggestion3.reward, "OnEnter", replacement);
		end
		-- fix yet another anchor family connection issue, added in 10.0
		if addOnName == "Blizzard_Communities" and self.gameVersion >= 100000 then
			local dialog = _G.CommunitiesFrame.NotificationSettingsDialog or nil;
			if dialog then
				dialog:ClearAllPoints();
				dialog:SetAllPoints();
			end
		end

		if addOnName == self.name then
			-- fix BattlefieldFrame having weird positioning
			if _G.BattlefieldFrame and _G.PVPParentFrame then
				_G.BattlefieldFrame:SetParent(_G.PVPParentFrame);
				_G.BattlefieldFrame:ClearAllPoints();
				_G.BattlefieldFrame:SetAllPoints();
			end

			if self.gameVersion >= 100000 then
				-- fix anchor family connection issues with the combined bag
				local skipHook = false
				self:SecureHook(ContainerFrameSettingsManager, "GetBagsShown", function()
					if skipHook then return end
					skipHook = true
					local bags = ContainerFrameSettingsManager:GetBagsShown()
					for _, bag in pairs(bags or {}) do
						bag:ClearAllPoints()
					end
					skipHook = false
				end);
			end
		end
	end

	function BlizzMove:OnEnable()
		self.enabled = true;
		self:SavePositionStrategyChanged(nil, self.DB.savePosStrategy);
		C_CVar.SetCVar('enableSourceLocationLookup', 1)

		self:ADDON_LOADED(_, self.name);
		for addOnName, _ in pairs(self.Frames) do
			if addOnName ~= self.name and IsAddOnLoaded(addOnName) then
				self:ADDON_LOADED(_, addOnName);
			end
		end

		self:RegisterEvent("ADDON_LOADED");
	end
end
