local name = ...
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name);
if not BlizzMove then return end

BlizzMoveAPI = BlizzMoveAPI or {}
------------------------------------------------------------------------------------------------------
-- API: Debug Functions
------------------------------------------------------------------------------------------------------
function BlizzMoveAPI:ToggleDebugPrints()
    BlizzMove.DB.DebugPrints = not BlizzMove.DB.DebugPrints

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

		BlizzMove:RegisterFrame(nil, frameName, frameData);

	end

end

function BlizzMoveAPI:RegisterAddOnFrames(addOnFramesTable)

	for addOnName, framesTable in pairs(addOnFramesTable) do

		for frameName, frameData in pairs(framesTable) do

			if not BlizzMove:ValidateFrame(frameName, frameData) then

				BlizzMove:DebugPrint("Invalid frame data provided for frame: '", frameName, "'.");
				return;

			end

			BlizzMove:RegisterFrame(addOnName, frameName, frameData);

		end

	end

end

function BlizzMoveAPI:UnregisterFrame(addOnName, frameName, permanent)

	return BlizzMove:UnregisterFrame(addOnName, frameName, permanent)

end
