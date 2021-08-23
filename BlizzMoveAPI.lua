-- upvalue the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local pairs = _G.pairs;

local name = ... or "BlizzMove";
---@type BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name);
if not BlizzMove then return; end

_G.BlizzMoveAPI = _G.BlizzMoveAPI or {};
---@class BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI;


function BlizzMoveAPI:GetVersion()
	local rawVersion = BlizzMove.Config.version;

	if(rawVersion == '@project' .. '-version@') then
		return rawVersion, nil, nil, nil, nil;
	end

	local mayor, minor, patch = string.match(rawVersion, 'v(%d*)%.(%d*)%.(%d*)[a-z]?')
	local versionInt = patch + minor * 100 + mayor * 10000;

	return rawVersion, mayor, minor, patch, versionInt
end

------------------------------------------------------------------------------------------------------
-- API: Debug Functions
------------------------------------------------------------------------------------------------------
function BlizzMoveAPI:ToggleDebugPrints()
	BlizzMove.DB.DebugPrints = not BlizzMove.DB.DebugPrints;

	BlizzMove:Print("Debug prints have been:", (BlizzMove.DB.DebugPrints and "Enabled") or "Disabled");
end

------------------------------------------------------------------------------------------------------
-- API: Frame Registering Functions
------------------------------------------------------------------------------------------------------
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

function BlizzMoveAPI:GetRegisteredAddOns()

	return BlizzMove:GetRegisteredAddOns();

end

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
