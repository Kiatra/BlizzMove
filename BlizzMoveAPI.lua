-- upvalue the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local pairs = _G.pairs;
local string_match = _G.string.match;

local name = ... or "BlizzMove";
---@type BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name); ---@diagnostic disable-line: assign-type-mismatch
if not BlizzMove then return; end

_G.BlizzMoveAPI = _G.BlizzMoveAPI or {};
---@class BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI;

function BlizzMoveAPI:GetVersion()
    local rawVersion = BlizzMove.Config.version;

    local mayor, minor, patch = string_match(rawVersion, "v(%d*)%.(%d*)%.(%d*)[a-z]?")
    local versionInt = patch and (patch + minor * 100 + mayor * 10000);

    return rawVersion, mayor, minor, patch, versionInt
end

function BlizzMoveAPI:ToggleDebugPrints()
    BlizzMove.DB.DebugPrints = not BlizzMove.DB.DebugPrints;

    BlizzMove:Print("Debug prints have been:", (BlizzMove.DB.DebugPrints and "Enabled") or "Disabled");
end

--- @alias BlizzMoveAPI_FrameTable table<string, BlizzMoveAPI_FrameData> # Frame name as key
--- @alias BlizzMoveAPI_AddonFrameTable table<string, BlizzMoveAPI_FrameTable> # Addon name as key, these can be LoD addons

--- @class BlizzMoveAPI_FrameData
--- @field SubFrames table<string, BlizzMoveAPI_SubFrameData>|nil # Sub frame name as key, sub frames may be nested to any depth
--- @field FrameReference Frame|nil # Reference to the frame to be moved, if nil, the frame will be looked up by name
--- @field MinVersion number|nil # First Interface version that is considered compatible
--- @field MaxVersion number|nil # Last Interface version that is consider compatible
--- @field MinBuild number|nil # First Interface build number that is considered compatible
--- @field MaxBuild number|nil # Last Interface build number that is considered compatible
--- @field VersionRanges BlizzMoveAPI_Range[]|nil # Interface version ranges, can be combined with MinVersion and MaxVersion
--- @field BuildRanges BlizzMoveAPI_Range[]|nil # Interface build number ranges, can be combined with MinBuild and MaxBuild
--- @field SilenceCompatabilityWarnings boolean|nil # Suppress warnings caused by compatibility checks against Interface version and build number
--- @field IgnoreMouse boolean|nil # Ignore all mouse events, same as setting both IgnoreMouseWheel and NonDraggable to true
--- @field IgnoreMouseWheel boolean|nil # Ignore mouse wheel events
--- @field NonDraggable boolean|nil # Ignore mouse drag events
--- @field DefaultDisabled boolean|nil # Disables moving the frame in the settings by default, requiring the user to enable it manually

--- @class BlizzMoveAPI_SubFrameData: BlizzMoveAPI_FrameData
--- @field Detachable boolean|nil # Allow the frame to be detached from the parent and moved independently
--- @field ForceParentage boolean|nil # Will call child:SetParent(parent) on registration
--- @field ManuallyScaleWithParent boolean|nil # Manually scale the frame with the parent; will call SetScale on the child whenever the parent's scale is updated

--- @class BlizzMoveAPI_Range
--- @field Min number|nil # Either Min, Max, or both must be filled
--- @field Max number|nil # Either Min, Max, or both must be filled

--- @param framesTable BlizzMoveAPI_FrameTable
function BlizzMoveAPI:RegisterFrames(framesTable)
    for frameName, frameData in pairs(framesTable) do
        if not BlizzMove:ValidateFrame(frameName, frameData) then
            BlizzMove:DebugPrint("Invalid frame data provided for frame: '", frameName, "'.");

            return false;
        end

        BlizzMove:RegisterFrame(nil, frameName, frameData, true);
    end

    if BlizzMove.initialized then
        BlizzMove.Config:RegisterOptions();
    end
end

--- @param addOnFramesTable BlizzMoveAPI_AddonFrameTable
function BlizzMoveAPI:RegisterAddOnFrames(addOnFramesTable)
    for addOnName, framesTable in pairs(addOnFramesTable) do
        for frameName, frameData in pairs(framesTable) do
            if not BlizzMove:ValidateFrame(frameName, frameData) then
                BlizzMove:DebugPrint("Invalid frame data provided for frame: '", frameName, "'.");

                return;
            end
            BlizzMove:RegisterFrame(addOnName, frameName, frameData, true);
        end
    end

    if BlizzMove.initialized then
        BlizzMove.Config:RegisterOptions();
    end
end

function BlizzMoveAPI:UnregisterFrame(addOnName, frameName, permanent)
    return BlizzMove:UnregisterFrame(addOnName, frameName, permanent);
end

--- @return table<string, string> # Returns a table with the addon name as key and value
function BlizzMoveAPI:GetRegisteredAddOns()
    return BlizzMove:GetRegisteredAddOns();
end

--- @param addOnName ?string # The name of the addon, defaults to BlizzMove (i.e. framexml frames)
--- @return table<string, string> # Returns a table with the frame name as key and value
function BlizzMoveAPI:GetRegisteredFrames(addOnName)
    return BlizzMove:GetRegisteredFrames(addOnName);
end

function BlizzMoveAPI:IsFrameDefaultDisabled(addOnName, frameName)
    return BlizzMove:IsFrameDefaultDisabled(addOnName, frameName);
end

function BlizzMoveAPI:IsFrameDisabled(addOnName, frameName)
    return BlizzMove:IsFrameDisabled(addOnName, frameName);
end

function BlizzMoveAPI:SetFrameDisabled(addOnName, frameName, disable)
    if disable then
        return BlizzMove:DisableFrame(addOnName, frameName);
    else
        return BlizzMove:EnableFrame(addOnName, frameName);
    end
end
