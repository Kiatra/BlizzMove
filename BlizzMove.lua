-- up-value the globals
local InCombatLockdown = InCombatLockdown;
local LibStub = LibStub;
local pairs = pairs;
local type = type;
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded;
local LoadAddOn = C_AddOns and C_AddOns.LoadAddOn or LoadAddOn;
local EnableAddOn = C_AddOns and C_AddOns.EnableAddOn or EnableAddOn;
local next = next;
local string__gmatch = string.gmatch;
local tonumber = tonumber;
local string__format = string.format;
local IsAltKeyDown = IsAltKeyDown;
local PlaySound = PlaySound;
local SOUNDKIT = SOUNDKIT;
local IsControlKeyDown = IsControlKeyDown;
local IsShiftKeyDown = IsShiftKeyDown;
local UpdateUIPanelPositions = UpdateUIPanelPositions;
local MouseIsOver = MouseIsOver;
local xpcall = xpcall;
local CallErrorHandler = CallErrorHandler;
local Settings_OpenToCategory = Settings and Settings.OpenToCategory or InterfaceOptionsFrame_OpenToCategory;
local strsplit = strsplit;
local GetBuildInfo = GetBuildInfo;
local tinsert = tinsert;
local unpack = unpack;
local wipe = wipe;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;
local CreateFrame = CreateFrame;
local abs = abs;
local GetMouseFoci = GetMouseFoci or function() return { GetMouseFocus() }; end;

local name = ... or "BlizzMove";
--- @class BlizzMove: AceAddon,AceConsole-3.0,AceEvent-3.0,AceHook-3.0
local BlizzMove = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");
if not BlizzMove then return; end

local L = LibStub("AceLocale-3.0"):GetLocale(name);
-- Various debug texts have been left untranslated on purpose, to make debugging easier. Instructions or information for users is translated.

--- @type BlizzMoveAPI_AddonFrameTable
BlizzMove.Frames = {};
--- @type table<Frame, BlizzMove_FrameData>
BlizzMove.FrameData = {};
--- @type table<string, table<string, Frame>> # [addOnName][frameName] = frame
BlizzMove.FrameRegistry = {};
--- @type table<PanelDragBarTemplate, boolean> # [moveHandleFrame] = true
BlizzMove.MoveHandles = {};
--- @type BlizzMove_CombatLockdownQueueItem[]
BlizzMove.CombatLockdownQueue = {};
--- @type table<Frame, true>
BlizzMove.CurrentMouseoverFrames = {};

local MAX_SCALE = 2.5;
local MIN_SCALE = 0.3; -- steps are in 0.1 increments, and we'd like to stay above 0.25

------------------------------------------------------------------------------------------------------
--- Debug Functions
------------------------------------------------------------------------------------------------------
--@debug@
_G['BlizzMove'] = BlizzMove;
--@end-debug@
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
        return type(value) == "table" and type(value.IsObjectType) == "function" and value:IsObjectType("Frame");
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
            elseif
                key == "MinVersion"
                or key == "MaxVersion"
                or key == "MinBuild"
                or key == "MaxBuild"
            then
                if (type(value) ~= "number" or value < 0) then validationError = true; end
            elseif
                key == "BuildRanges"
                or key == "VersionRanges"
            then
                if (type(value) ~= "table") then
                    validationError = true;
                else
                    for _, range in pairs(value) do
                        if
                            type(range) ~= "table"
                            or (range.Min and (type(range.Min) ~= "number" or range.Min < 0))
                            or (range.Max and (type(range.Max) ~= "number" or range.Max < 0))
                            or (range.Max and range.Min and range.Max < range.Min)
                            or (not range.Max and not range.Min)
                        then
                            validationError = true;
                            break;
                        end
                    end
                end
            elseif
                key == "Detachable"
                or key == "ManuallyScaleWithParent"
                or key == "ForceParentage"
            then
                if (type(value) ~= "boolean" or (value == true and not isSubFrame)) then validationError = true; end
            elseif
                key == "IgnoreMouse"
                or key == "IgnoreMouseWheel"
                or key == "NonDraggable"
                or key == "IgnoreClamping"
                or key == "DefaultDisabled"
                or key == "SilenceCompatabilityWarnings"
                or key == "IgnoreSavedPositionWhenMaximized"
                or key == "ForcePosition"
            then
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

        if
            not self:IsFrameDisabled(addOnName, frameName)
            and IsAddOnLoaded(addOnName)
            and self.initialized
        then
            self:ProcessFrame(addOnName, frameName, copiedData);
        end

        if self.initialized and not skipConfigUpdate then
            self.Config:RegisterOptions();
        end

    end

    function BlizzMove:UnregisterFrame(addOnName, frameName, permanent)
        if not addOnName then addOnName = self.name; end

        if self:IsFrameDisabled(addOnName, frameName) then return; end

        if not self.Frames[addOnName] or not self.Frames[addOnName][frameName] then return false; end

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

        if (frameData and IsAddOnLoaded(addOnName)) then
            self:ProcessFrame(addOnName, frameName, frameData, (frameData.storage and frameData.storage.frameParent) or nil);
        end
    end

    function BlizzMove:IsFrameDisabled(addOnName, frameName)
        if (not addOnName) then addOnName = self.name; end

        if (self.DB and self.DB.disabledFrames and self.DB.disabledFrames[addOnName] and self.DB.disabledFrames[addOnName][frameName]) then
            return true;
        end

        if
            self:IsFrameDefaultDisabled(addOnName, frameName)
            and not (self.DB and self.DB.enabledFrames and self.DB.enabledFrames[addOnName] and self.DB.enabledFrames[addOnName][frameName])
        then
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
        if self.FrameRegistry[addOnName] and self.FrameRegistry[addOnName][frameName] then
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
            if not range.Min and not range.Max then
                return false;
            end
            if range.Min and not range.Max and range.Min <= needle then
                return true;
            end
            if not range.Min and range.Max and range.Max > needle then
                return true;
            end
            if range.Min and range.Max and range.Min <= needle and range.Max > needle then
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
            if type(v) == "table" then
                if IsFrame(v) then
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
    --- @param frame Frame
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

        return nil;
    end

    function GetAbsoluteFramePosition(frame)
        -- inspired by LibWindow-1.1 (https://www.wowace.com/projects/libwindow-1-1)

        local scale = frame:GetScale();
        if not scale then return end
        if not frame:GetLeft() then
            local frameData = BlizzMove.FrameData[frame];
            local frameName = frameData and frameData.storage and frameData.storage.frameName or 'unknown';
            local sharedText = L['BlizzMove: The frame you just moved (%s) is probably in a broken state, possibly because of other addons.']:format(frameName);

            EnableAddOn('BlizzMove_Debug', UnitName('player')); -- force enable the debug module before loading it
            local loaded = LoadAddOn('BlizzMove_Debug');
            --- @type BlizzMove_Debug
            local DebugModule = loaded and BlizzMove:GetModule('Debug'); ---@diagnostic disable-line: assign-type-mismatch
            if (not DebugModule) then
                error(sharedText .. ' ' .. L['Enable the Blizzmove_Debug plugin, to find more debugging information.']);
                return;
            end
            local result = DebugModule:FindBadAnchorConnections(frame);
            local text = sharedText .. ' ' .. L['Copy the text from this popup window, and report it to the addon author.'] .. '\n\nBad anchor connections for "' .. frameName .. '":\n';
            for _, info in pairs(result) do
                text = text .. string__format(
                    '\n\n"%s" is outside anchor family, but referenced by "%s" (created in "%s", and "%s" respectively)',
                    info.targetName, info.name, info.targetSource, info.source
                );
            end
            DebugModule:GetMainFrame(text):Show();
            error(sharedText .. L['Copy the text from the popup window, and report it to the addon author.']);
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

    --- @param frame Frame
    --- @param framePoints BlizzMove_FramePoint[]
    --- @param raw boolean? # if true, will not factor in the frame scale
    --- @return boolean
    function SetFramePoints(frame, framePoints, raw)
        if InCombatLockdown() and frame:IsProtected() then return false; end

        if framePoints and framePoints[1] then
            frame:ClearAllPoints();
            local SetPoint = frame.SetPointBase or frame.SetPoint;
            local scale = raw and 1 or frame:GetScale();

            for curPoint = 1, #framePoints do
                ignoreSetPointHook = true;
                SetPoint(
                    frame,
                    framePoints[curPoint].anchorPoint,
                    framePoints[curPoint].relativeFrame,
                    framePoints[curPoint].relativePoint,
                    framePoints[curPoint].offX / scale,
                    framePoints[curPoint].offY / scale
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
        if InCombatLockdown() and frame:IsProtected() then return false; end
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
--- Frame movement
------------------------------------------------------------------------------------------------------
local StartMoving;
local StopMoving;
do
    local function setNil(table, key)
        TextureLoadingGroupMixin.RemoveTexture({ textures = table, }, key);
    end
    local function returnFalse() return false; end

    function StartMoving(frame)
        if BlizzMove.MoveHandles[frame] then
            setNil(frame, 'onDragStartCallback');

            return;
        end
        frame:StartMoving()
    end

    function StopMoving(frame)
        if BlizzMove.MoveHandles[frame] then
            frame.onDragStartCallback = returnFalse;

            return;
        end
        frame:StopMovingOrSizing()
    end
end

------------------------------------------------------------------------------------------------------
--- Secure Script Hook Handlers
------------------------------------------------------------------------------------------------------
local OnMouseDown;
local DoOnMouseDown;
local OnMouseUp;
local DoOnMouseUp;
local OnMouseWheel;
local OnEnter;
local OnLeave;
local OnShow;
local OnSubFrameHide;
do
    function OnMouseDown(frame, button)
        local moveHandle = BlizzMove.MoveHandles[frame] and frame or nil;
        if moveHandle then
            frame = moveHandle:GetParent();
        end

        return DoOnMouseDown(frame, button, moveHandle);
    end
    function DoOnMouseDown(frame, button, moveHandle)
        if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

        local returnValue = false;
        local parentReturnValue = false;
        local frameData = BlizzMove.FrameData[frame];
        BlizzMove:SetupPointStorage(frame);

        BlizzMove:DebugPrint("OnMouseDown:", frameData.storage.frameName, button);

        if button == "LeftButton" then
            if not moveHandle and IsAltKeyDown() and frameData.Detachable and not frameData.storage.detached then
                frameData.storage.points.detachPoints = GetFramePoints(frame);
                frameData.storage.detached = true;
                returnValue = true;

                PlaySound((SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_OPEN) or 839);
            end

            if not frameData.storage.detached then
                parentReturnValue = (frameData.storage.frameParent and DoOnMouseDown(frameData.storage.frameParent, button, moveHandle)) or false;
            end

            if
                (frameData.storage.detached or not parentReturnValue)
                and (not (BlizzMove.DB and BlizzMove.DB.requireMoveModifier) or IsShiftKeyDown())
            then
                local userPlaced = frame:IsUserPlaced();

                frame:SetMovable(true);
                StartMoving(moveHandle or frame);
                frame:SetUserPlaced(userPlaced);
                frameData.storage.points.startPoints = frameData.storage.points.startPoints or GetAbsoluteFramePosition(frame);
                frameData.storage.isMoving = true;
                returnValue = true;
            end
        end

        return returnValue or parentReturnValue;
    end

    function OnMouseUp(frame, button)
        local moveHandle = BlizzMove.MoveHandles[frame] and frame or nil;
        if moveHandle then
            frame = moveHandle:GetParent();
        end
        return DoOnMouseUp(frame, button, moveHandle);
    end
    function DoOnMouseUp(frame, button, moveHandle)
        if moveHandle then StopMoving(moveHandle); end
        if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

        local returnValue = false;
        local parentReturnValue = false;
        local frameData = BlizzMove.FrameData[frame];

        BlizzMove:DebugPrint("OnMouseUp:", frameData.storage.frameName, button);

        if not frameData.storage.detached then
            parentReturnValue = (frameData.storage.frameParent and DoOnMouseUp(frameData.storage.frameParent, button, moveHandle)) or false;
        end

        if frameData.storage.detached or not parentReturnValue then
            if button == "LeftButton" and frameData.storage.isMoving then
                StopMoving(moveHandle or frame);

                frameData.storage.points.dragPoints = GetAbsoluteFramePosition(frame);
                frameData.storage.points.dragged = true;
                frameData.storage.isMoving = nil;
                returnValue = true;

            elseif button == "RightButton" then
                local fullReset = false;

                if IsAltKeyDown() and frameData.storage.detached then
                    if SetFramePoints(frame, frameData.storage.points.detachPoints, true) then
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
                    if (frameData.storage.points) then
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

    function OnMouseWheel(frame, delta, ...)
        if not IsControlKeyDown() then return; end
        if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

        local returnValue = false;
        local parentReturnValue = false;
        local frameData = BlizzMove.FrameData[frame];

        BlizzMove:DebugPrint("OnMouseWheel:", frameData.storage.frameName, delta);

        if not frameData.storage.detached then
            parentReturnValue = (frameData.storage.frameParent and OnMouseWheel(frameData.storage.frameParent, delta, ...)) or false;
        end

        if (frameData.storage.detached or not parentReturnValue) then
            local oldScale = GetFrameScale(frame) or 1;

            local newScale = oldScale + 0.1 * delta;
            newScale = max(MIN_SCALE, min(MAX_SCALE, newScale));

            returnValue = SetFrameScale(frame, newScale) or returnValue;
        end

        return returnValue or parentReturnValue;
    end

    function OnShow(frame, skipAdditionalRunNextFrame)
        local frameData = BlizzMove.FrameData[frame];
        if not frameData or not frameData.storage or frameData.storage.disabled then return; end

        BlizzMove:DebugPrint("OnShow:", BlizzMove:GetFrameName(frame));

        if InCombatLockdown() and frame:IsProtected() then
            BlizzMove:AddToCombatLockdownQueue(OnShow, frame);
            BlizzMove:DebugPrint('Adding to combatLockdownQueue: OnShow - ', BlizzMove:GetFrameName(frame));

            return;
        end

        SetFrameParent(frame);

        if BlizzMove.DB.saveScaleStrategy == 'permanent' and BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)] then
            SetFrameScale(frame, BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]);
        end

        if not skipAdditionalRunNextFrame then
            RunNextFrame(function() OnShow(frame, true) end);
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

    function OnEnter(frame)
        if not BlizzMove.FrameData[frame] or not BlizzMove.FrameData[frame].storage or BlizzMove.FrameData[frame].storage.disabled then return; end

        BlizzMove.CurrentMouseoverFrames[frame] = true;
        BlizzMove:CheckMouseWheelCapture();
    end

    function OnLeave(frame)
        if not BlizzMove.CurrentMouseoverFrames[frame] then return; end

        BlizzMove.CurrentMouseoverFrames[frame] = nil;
        BlizzMove:CheckMouseWheelCapture();
    end
end

------------------------------------------------------------------------------------------------------
--- MouseWheel handling
------------------------------------------------------------------------------------------------------
do
    local captureFrame
    --[[
    General idea of this setup:
    - We have a frame that spans the entire screen, and overlaps all frames.
    - When the user has CTRL down, and we're mousing over a BM handled frame that has scaling enabled,
        and there's no frame overlapping it that captures the mousewheel, we enable the mousewheel on this frame.
    - The mousewheel is then passed to the OnMouseWheel function, which does all the scaling magic (including scaling parent-/subframes).
    - Whenever mousewheel is disabled, other frames will continue to capture it as normal.
    - The above condtions are checked way more often than is needed, because my faith in any alternative working as expected is low.
    - And we have to do all this crap because we can't simply propegate mousewheel events to children :/

    The previous solution involved manually calling childFrame:GetScript("OnMouseWheel")(childFrame, delta)
        which results in scrolling being tainted, which in rare situations would cause problems.
    --]]
    function BlizzMove:InitMouseWheelCaptureFrame()
        captureFrame = CreateFrame("Frame");
        captureFrame:SetPoint("TOPLEFT", nil);
        captureFrame:SetPoint("BOTTOMRIGHT", nil);

        captureFrame:SetScript("OnUpdate", function() self:CheckMouseWheelCapture(); end);
        captureFrame:SetScript("OnEvent", function() self:CheckMouseWheelCapture(); end);
        captureFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
        captureFrame:SetScript("OnMouseWheel", function(_, delta)
            for i, frame in ipairs(GetMouseFoci()) do
                --- @type BlizzMoveAPI_FrameData?
                local frameData = self.FrameData[frame];

                if frameData and not (frameData.IgnoreMouse or frameData.IgnoreMouseWheel) and self.CurrentMouseoverFrames[frame] then
                    OnMouseWheel(frame, delta);

                    return;
                end
            end

            --@debug@
            self:Print('dev debug print: no frame found?? :-(');
            --@end-debug@
        end);
        captureFrame:SetFrameStrata("TOOLTIP");
        captureFrame:SetFrameLevel(9999); -- try to overlay everything ;-)
        captureFrame:Show();
        captureFrame:EnableMouseWheel(false);
        RunNextFrame(function() self:CheckMouseWheelCapture(); end);
    end

    function BlizzMove:CheckMouseWheelCapture()
        captureFrame:EnableMouseWheel(false);
        if not IsControlKeyDown() or not next(self.CurrentMouseoverFrames) or not next(GetMouseFoci()) then
            -- keep mouse wheel disabled
            return;
        end

        for _, frame in ipairs(GetMouseFoci()) do
            --- @type BlizzMoveAPI_FrameData?
            local frameData = self.FrameData[frame];
            local shouldHandleMouseWheel = frameData and not (frameData.IgnoreMouse or frameData.IgnoreMouseWheel);
            if
                not shouldHandleMouseWheel
                and (
                    frame:IsForbidden()
                    or (not self.MoveHandles[frame] and (frame:IsMouseWheelEnabled() or frame:IsMouseClickEnabled()))
                )
            then
                -- some clickable/scrollable thing is in the way
                return;
            end

            if shouldHandleMouseWheel and self.CurrentMouseoverFrames[frame] then
                captureFrame:EnableMouseWheel(true);

                return;
            end
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

        local frameData = BlizzMove.FrameData[frame];
        if
            BlizzMove.FrameData[frame].storage.points.dragged
            and (not frameData.IgnoreSavedPositionWhenMaximized or not frame.isMaximized)
            and (not frameData.storage.frameParent or frameData.storage.detached)
        then
            if BlizzMove.DB.savePosStrategy ~= "permanent" then
                SetFramePoints(frame, BlizzMove.FrameData[frame].storage.points.dragPoints);
            else
                BlizzMove:AddToSetFramePointsQueue(frame, BlizzMove.FrameData[frame].storage.points.dragPoints);
            end
        end
    end

    function OnSizeUpdate(frame)
        local frameData = BlizzMove.FrameData[frame];
        if not frameData or not frameData.storage or frameData.storage.disabled or frameData.IgnoreClamping then return; end

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

        if BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)] then
            SetFrameScale(frame, BlizzMove.DB.scales[BlizzMove:GetFrameName(frame)]);
        end
    end
end

------------------------------------------------------------------------------------------------------
--- Processing Frame Functions
------------------------------------------------------------------------------------------------------
do
    --- @param frame Frame
    --- @param script ScriptFrame
    --- @param handler? function|string
    local function hookScript(frame, script, handler)
        if (frame:HasScript(script)) then
            BlizzMove:SecureHookScript(frame, script, handler);
            hooksecurefunc(frame, 'SetScript', function(self, scriptName)
                if (scriptName == script and self == frame) then
                    BlizzMove:DebugPrint('SetScript hook triggered for ', BlizzMove:GetFrameName(frame), scriptName);
                    BlizzMove:Unhook(frame, script);
                    BlizzMove:SecureHookScript(frame, script, handler);
                end
            end);
        end
    end

    ---@param frame Frame
    ---@param parent Frame
    ---@return PanelDragBarTemplate
    local function MakeMoveHandle(frame, parent)
        BlizzMove:DebugPrint('Making move handle for', BlizzMove:GetFrameName(frame), 'parent:', BlizzMove:GetFrameName(parent));
        -- can't really use a framepool, since we need the OnLoad to run with the correct parent
        local handle = CreateFrame('Frame', nil, parent, 'PanelDragBarTemplate');
        handle:SetParent(frame);
        handle:SetAllPoints(frame);
        handle:SetFrameLevel(frame:GetFrameLevel() + 1);
        handle:SetPropagateMouseMotion(true);
        handle.onDragStartCallback = function() return false end;
        handle:HookScript('OnMouseDown', OnMouseDown);
        handle:HookScript('OnMouseUp', OnMouseUp);
        handle:HookScript('OnDragStop', function(self) OnMouseUp(self, 'LeftButton'); end);

        return handle;
    end

    ---@param frame Frame
    ---@param frameData BlizzMove_FrameData
    local function MakeMoveHandles(frame, frameData)
        if frameData.moveHandles then
            for _, handle in pairs(frameData.moveHandles) do
                -- disable old handles
                handle:SetScript("OnEvent", nil);
                handle:SetScript("OnUpdate", nil);
                handle:Hide();
                BlizzMove.MoveHandles[handle] = nil;
            end
        end
        frameData.moveHandles = {}; ---@diagnostic disable-line: inject-field
        local parentData = frameData;
        while parentData.parentData do
            --[[
            --[==[
                todo: handle detachable frames in the context of protected frames
                maybe that can be done by making DoOnMouseDown/Up check the relevant moveHandle themselves, but not sure..
                since it might require multiple moveHandles which internally have their own frame stacks
                maybe possible by creating a bunch of them, then reparenting them to a container frame, which then flattens the layers etc?

                or maybe propagate mouse clicks (do all frames get the drag events? or just the topmost one?)
                if propagation works, we'll just have to ensure only 1 moveHandle handles the main mouse events, depending on the detached state
                or re-attach, disable the mouse events again, and re-enable them on the main moveHandle
                alternatively, hiding the moveHandles for detachable frames, until detached, so only 1 moveHandle is shown at a time for a given frame

                for now the only sitations where this is relevant is for plugins that add detachable frames
            --]==]
            if parentData.Detachable then
                tinsert(frameData.moveHandles, MakeMoveHandle(frame, parentData.storage.frame));
            end
            --]]
            parentData = parentData.parentData;
        end

        local rootParent = parentData and parentData.storage and parentData.storage.frame or frame;
        local moveHandle = MakeMoveHandle(frame, rootParent);
        tinsert(frameData.moveHandles, moveHandle);
        BlizzMove.MoveHandles[moveHandle] = true;
    end

    --- @param frame Frame
    --- @param addOnName string
    --- @param frameName string
    --- @param frameData BlizzMoveAPI_FrameData|BlizzMoveAPI_SubFrameData|BlizzMove_FrameData
    --- @param frameParent Frame?
    local function MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent)
        if not frame then return false; end

        if InCombatLockdown() and frame:IsProtected() then return false; end

        local clampFrame = false;
        if not frameParent or frameData.Detachable then
            clampFrame = true;
        end

        if frame and BlizzMove.FrameData[frame] and BlizzMove.FrameData[frame].storage and not frameData.storage then
            frameData.storage = BlizzMove.FrameData[frame].storage;
            frameData.parentData = frameParent and BlizzMove.FrameData[frameParent] or nil;
            frameData.storage.frameName = frameName;
            frameData.storage.addOnName = addOnName;
            frameData.storage.frameParent = frameParent;
            BlizzMove.FrameData[frame] = frameData; ---@diagnostic disable-line: assign-type-mismatch
        end
        if frame and frameData.storage and frameData.storage.hooked then
            -- it's already hooked, don't hook twice
            frameData.storage.disabled = false;

            frame:SetMovable(true);
            if not frameData.IgnoreClamping then
                frame:SetClampedToScreen(clampFrame);
            end

            if not frameData.IgnoreMouse then
                if not frameData.NonDraggable then
                    local rootFrameData = frameData;
                    while rootFrameData.parentData do
                        rootFrameData = rootFrameData.parentData;
                    end
                    if frame:IsProtected() or rootFrameData.storage.frame:IsProtected() then
                        MakeMoveHandles(frame, frameData);
                    else
                        frame:EnableMouse(true);
                    end
                end

                if not frameData.IgnoreMouseWheel then
                    frame:EnableMouseWheel(true);
                end
            end

            return true;
        end

        frameData.parentData = frameParent and BlizzMove.FrameData[frameParent] or nil;

        if not frame or (frameData.storage and frameData.storage.hooked) then return false; end

        frameData.storage = {
            hooked = true,
            frame = frame,
            frameName = frameName,
            frameParent = frameParent,
            addOnName = addOnName,
        };

        BlizzMove.FrameData[frame] = frameData; ---@diagnostic disable-line: assign-type-mismatch

        frame:SetMovable(true);
        if not frameData.IgnoreClamping then
            frame:SetClampedToScreen(clampFrame);
        end

        if not frameData.IgnoreMouse then
            if not frameData.NonDraggable then
                local rootFrameData = frameData;
                while rootFrameData.parentData do
                    rootFrameData = rootFrameData.parentData;
                end
                if frame:IsProtected() or rootFrameData.storage.frame:IsProtected() then
                    MakeMoveHandles(frame, frameData);
                else
                    frame:EnableMouse(true);
                    hookScript(frame, "OnMouseDown", OnMouseDown);
                    hookScript(frame, "OnMouseUp", OnMouseUp);
                end
            end

            if not frameData.IgnoreMouseWheel then
                hookScript(frame, "OnEnter", OnEnter);
                hookScript(frame, "OnLeave", OnLeave);
                if MouseIsOver(frame) then
                    RunNextFrame(function()
                        if MouseIsOver(frame) then OnEnter(frame); end
                    end);
                end
            end
        end

        hookScript(frame, "OnShow", OnShow);
        if frameParent then
            hookScript(frame, "OnHide", OnSubFrameHide);
        end

        if frameData.ForcePosition or (not frameData.IgnoreMouse and not frameData.NonDraggable) then
            -- prevents rubberbanding when a frame's movement is handled by something else
            BlizzMove:SecureHook(frame, "SetPoint", OnSetPoint);
        end
        BlizzMove:SecureHook(frame, "SetWidth", OnSizeUpdate);
        BlizzMove:SecureHook(frame, "SetHeight", OnSizeUpdate);

        OnShow(frame);
        OnSizeUpdate(frame);
        OnSetPoint(frame);

        return true;
    end

    local function MakeFrameUnmovable(frame, frameData)
        if not frame or not frameData.storage or not frameData.storage.hooked then return false; end

        if InCombatLockdown() and frame:IsProtected() then return false; end

        frame:SetMovable(false);
        if not frameData.IgnoreClamping then
            frame:SetClampedToScreen(false);
        end

        if not frameData.IgnoreMouse then
            frame:EnableMouse(false);
            frame:EnableMouseWheel(false);
        end

        frameData.storage.disabled = true;

        if frameData.moveHandles then
            for _, handle in pairs(frameData.moveHandles) do
                -- disable old handles
                handle:SetScript("OnEvent", nil);
                handle:SetScript("OnUpdate", nil);
                handle:Hide();
                BlizzMove.MoveHandles[handle] = nil;
            end
            frameData.moveHandles = nil;
        end

        return true;
    end

    --- @param frame Frame
    --- @param addOnName string
    --- @param frameName string
    --- @param frameData BlizzMoveAPI_FrameData|BlizzMoveAPI_SubFrameData|BlizzMove_FrameData
    --- @param frameParent Frame?
    function BlizzMove:MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent)
        return xpcall(MakeFrameMovable, CallErrorHandler, frame, addOnName, frameName, frameData, frameParent);
    end

    function BlizzMove:MakeFrameUnmovable(frame, frameData)
        return xpcall(MakeFrameUnmovable, CallErrorHandler, frame, frameData);
    end

    --- @param addOnName string
    --- @param frameName string
    --- @param frameData BlizzMoveAPI_FrameData|BlizzMoveAPI_SubFrameData|BlizzMove_FrameData
    --- @param frameParent Frame?
    --- @param retriedAfterNotFound boolean?
    function BlizzMove:ProcessFrame(addOnName, frameName, frameData, frameParent, retriedAfterNotFound)
        if self:IsFrameDisabled(addOnName, frameName) then return; end

        local matchesBuild = self:MatchesCurrentBuild(frameData);

        if (frameData.FrameReference) then
            self.FrameRegistry[addOnName] = self.FrameRegistry[addOnName] or {}
            self.FrameRegistry[addOnName][frameName] = frameData.FrameReference;
        end

        local frame = self:GetFrameFromName(addOnName, frameName);

        if (not matchesBuild) then
            if (frame and not frameData.SilenceCompatabilityWarnings) then
                self:Print(L["Frame was marked as incompatible, but does exist"], "( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);
            end

            return false;
        end

        if not frame then
            if not retriedAfterNotFound then
                RunNextFrame(function()
                    self:ProcessFrame(addOnName, frameName, frameData, frameParent, true);
                end);

                return false;
            end
            self.notFoundFrames = self.notFoundFrames or {};
            tinsert(self.notFoundFrames, frameName);
            self:Print(L["Could not find frame"], "( Build:", self.gameBuild, "| Version:", self.gameVersion, "| BMVersion:", self.Config.version, "):", frameName);

            return false;
        end

        if InCombatLockdown() and frame:IsProtected() then
            self:AddToCombatLockdownQueue(BlizzMove.ProcessFrame, self, addOnName, frameName, frameData, frameParent);
            self:DebugPrint('Adding to combatLockdownQueue: ProcessFrame - ', addOnName, ' - ', frameName);

            return false;
        end

        if not self:MakeFrameMovable(frame, addOnName, frameName, frameData, frameParent) then
            self:Print(L["Failed to make frame movable:"], frameName);

            return false;
        end

        if frameData.SubFrames then
            for subFrameName, subFrameData in pairs(frameData.SubFrames) do
                self:ProcessFrame(addOnName, subFrameName, subFrameData, frame);
            end
        end
    end

    function BlizzMove:ProcessFrames(addOnName)
        if not (self.Frames and self.Frames[addOnName]) then return; end

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
        if not InCombatLockdown() then
            func(...);
        end
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
            onUpdateFrame:SetScript("OnUpdate", nil);
        end
        if newValue == 'permanent' then
            onUpdateFrame:SetScript("OnUpdate", function() self:OnUpdate(); end);
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
            local frameData = self.FrameData[frame];
            if not (frameData and frameData.IgnoreSavedPositionWhenMaximized and frame.isMaximized) then
                SetFramePoints(frame, framePoints);
            end
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
        --- @type BlizzMoveDB
        self.DB = _G.BlizzMoveDB;
        self:InitDefaults();

        self.Config:Initialize();

        self:InitMouseWheelCaptureFrame();

        self:RegisterChatCommand('blizzmove', 'OnSlashCommand');
        self:RegisterChatCommand('bm', 'OnSlashCommand');
        for _, command in pairs(commands) do
            self:RegisterChatCommand('bm' .. command, function(message) self:OnSlashCommand(command .. ' ' .. message); end);
        end

        if _G.UIPanelUpdateScaleForFit then
            self:SecureHook('UIPanelUpdateScaleForFit', OnUpdateScaleForFit);
        elseif _G.UpdateScaleForFit then
            self:SecureHook('UpdateScaleForFit', OnUpdateScaleForFit);
        end

        self:SavePositionStrategyChanged(nil, self.DB.savePosStrategy);
        C_CVar.SetCVar('enableSourceLocationLookup', 1)

        self:ProcessFrames(self.name);
        self:ApplyAddOnSpecificFixes(self.name);

        EventRegistry:RegisterCallback('SetItemRef', function(_, link)
            local linkType, addOnName, linkData = strsplit(':', link, 3);
            if linkType == 'addon' and addOnName == 'blizzmoveCopy' then
                self.Config:ShowURLPopup(linkData)
            elseif linkType == 'addon' and addOnName == 'blizzmoveMuteWarning' and linkData then
                ---@diagnostic disable-next-line: assign-type-mismatch
                self.DB.mutedCompatWarnings[linkData] = date('%Y%m%d');
                self:Print(L['Muted warning for %s']:format(linkData));
            end
        end);

        for i = 1, C_AddOns.GetNumAddOns() do
            local addOnName = C_AddOns.GetAddOnInfo(i);
            if IsAddOnLoaded(addOnName) then
                self:CheckCompatibility(addOnName);
            end
        end
        for addOnName in pairs(self.Frames) do
            if addOnName ~= self.name and IsAddOnLoaded(addOnName) then
                self:ADDON_LOADED(nil, addOnName);
            end
        end

        self:RegisterEvent("ADDON_LOADED");
    end

    function BlizzMove:OnSlashCommand(message)
        local arg1, arg2 = strsplit(' ', message);
        if
            arg1 == commands.dumpDebugInfo
            or arg1 == commands.dumpChangedCVars
            or arg1 == commands.debugAnchor
            or arg1 == commands.dumpTopLevelFrames
        then
            EnableAddOn('BlizzMove_Debug', UnitName('player')); -- force enable the debug module before loading it
            local loaded = LoadAddOn('BlizzMove_Debug');
            --- @type BlizzMove_Debug
            local DebugModule = loaded and BlizzMove:GetModule('Debug'); ---@diagnostic disable-line: assign-type-mismatch
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
                    self:Print(L['Found bad anchor connections, copy the popup window contents to analyze them.']);
                    local text = 'Bad anchor connections for "' .. arg2 .. '":\n';
                    for _, info in pairs(result) do
                        text = text .. string__format(
                            '\n\n"%s" is outside anchor family, but referenced by "%s" (created in "%s", and "%s" respectively)',
                            info.targetName, info.name, info.targetSource, info.source
                        );
                    end
                    DebugModule:GetMainFrame(text):Show();
                else
                    self:Print(L['No bad anchor connections found']);
                end
            elseif arg1 == commands.dumpTopLevelFrames then
                DebugModule:DumpTopLevelFrames();
            end

            return;
        end

        if arg1 == commands.debugLoadAll then
            for addOnName, _ in pairs(self:GetRegisteredAddOns()) do
                self:Print((LoadAddOn(addOnName) and "Loaded") or "Missing", addOnName);
            end
            return;
        elseif arg1 == commands.dumpMissingFrames then
            self.Config:ShowURLPopup(
                'Build:' .. self.gameBuild .. '| Version:' .. self.gameVersion .. '| BMVersion:' .. self.Config.version .. "\n\n"
                .. table.concat(self.notFoundFrames or { '<none>' }, "\n")
            );
            return;
        end

        Settings_OpenToCategory('BlizzMove');
    end

    --- @type BlizzMoveDB
    local defaults = {
        savePosStrategy = "session",
        saveScaleStrategy = "session",
        points = {},
        scales = {},
        mutedCompatWarnings = {},
    };
    function BlizzMove:InitDefaults()
        for property, value in pairs(defaults) do
            if self.DB[property] == nil then
                self.DB[property] = value;
            end
        end
        for addOnName, mutedAt in pairs(self.DB.mutedCompatWarnings) do
            if type(mutedAt) ~= 'number' then
                self.DB.mutedCompatWarnings[addOnName] = GetServerTime();
            end
        end
    end

    function BlizzMove:ADDON_LOADED(_, addOnName)
        if addOnName == self.name then return; end

        self:ProcessFrames(addOnName);
        self:ApplyAddOnSpecificFixes(addOnName);
        self:CheckCompatibility(addOnName);
    end

    function BlizzMove:ApplyAddOnSpecificFixes(addOnName)
        -- fix a stupid anchor family connection issue blizzard added in 9.1.5
        if addOnName == "Blizzard_Collections" then
            local checkbox = _G.WardrobeTransmogFrame and _G.WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
            if checkbox then
                checkbox.Label:ClearAllPoints();
                checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1);
                checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1);
            end
        end
        -- fix another anchor family connection issue caused by blizzard being blizzard
        if addOnName == "Blizzard_EncounterJournal" and _G.AdventureJournal_Reward_OnEnter and _G.EncounterJournalTooltip then
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
        if addOnName == "Blizzard_Communities" and _G.CommunitiesFrame.NotificationSettingsDialog then
            local dialog = _G.CommunitiesFrame.NotificationSettingsDialog;
            if dialog then
                dialog:ClearAllPoints();
                dialog:SetAllPoints();
            end
        end
        -- fix anchor family connection issues when opening PlayerChoiceFrame after moving it
        if addOnName == "Blizzard_PlayerChoice" and _G.PlayerChoiceFrame then
            _G.PlayerChoiceFrame:HookScript("OnHide", function()
                if not InCombatLockdown() or not _G.PlayerChoiceFrame:IsProtected() then
                    _G.PlayerChoiceFrame:ClearAllPoints();
                end
            end);
        end

        -- fix anchor family connection issues when opening/closing the hero talents dialog
        if addOnName == "Blizzard_PlayerSpells" and _G.HeroTalentsSelectionDialog and _G.PlayerSpellsFrame then
            local skipHook = false;
            hooksecurefunc(TalentFrameUtil, "GetNormalizedSubTreeNodePosition", function(talentFrame)
                if skipHook then return; end
                if
                    debugstack(3):find("in function .UpdateContainerVisibility.")
                    or debugstack(3):find("in function .UpdateAllTalentButtonPositions.")
                    or debugstack(3):find("in function .PlaceHeroTalentButton.")
                then
                    for talentButton in talentFrame:EnumerateAllTalentButtons() do
                        local nodeInfo = talentButton:GetNodeInfo();
                        if nodeInfo.subTreeID then
                            talentButton:ClearAllPoints();
                        end
                    end
                    RunNextFrame(function() skipHook = false; end);
                end
            end);
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

    function BlizzMove:CheckCompatibility(addOnName)
        local warnings = {
            ['MoveAny'] = L['MoveAny is loaded, some users reported this breaks moving frames. If you encounter this issue yourself, try disabling MoveAny.'],
            ['DeModal'] = L['DeModal is loaded, this addon is known to cause issues, consider replacing it with %s instead.']:format('|cff71d5ff|Haddon:blizzmoveCopy:https://www.curseforge.com/wow/addons/no-auto-close|h[NoAutoClose]|h|r'),
        };
        -- muted warnings are muted for 3 months
        if warnings[addOnName] and (not self.DB.mutedCompatWarnings[addOnName] or self.DB.mutedCompatWarnings[addOnName] < (GetServerTime() - (3 * 31 * 24 * 3600))) then
            self:Print(warnings[addOnName], ' |cff71d5ff|Haddon:blizzmoveMuteWarning:' .. addOnName .. '|h[' .. L['Mute this warning'] .. ']|h|r');
        end
    end
end
