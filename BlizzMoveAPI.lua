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
