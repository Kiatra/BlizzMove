local BlizzMove = LibStub("AceAddon-3.0"):GetAddon("BlizzMove");
if not BlizzMove then return end

BlizzMoveAPI = BlizzMoveAPI or {}
------------------------------------------------------------------------------------------------------
-- API: Debug Functions
------------------------------------------------------------------------------------------------------
function BlizzMoveAPI:ToggleDebugPrints()
    BlizzMove.DebugPrints = not BlizzMove.DebugPrints

	BlizzMove:Print("Debug prints have been:", ((BlizzMove.DebugPrints and "Enabled") or "Disabled"));
end

------------------------------------------------------------------------------------------------------
-- API: Frame Registering Functions
------------------------------------------------------------------------------------------------------
function BlizzMoveAPI:RegisterFrames(framesTable)

	for frameName, frameData in pairs(framesTable) do

		if not BlizzMove:ValidateFrame(frameName, frameData) then

			BlizzMove:DebugPrint("Invalid frame data provided for frame: '", frameName, "'.");
			return;

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