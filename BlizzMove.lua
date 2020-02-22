_G.BlizzMove = _G.BlizzMove or {};

local version = select(4, GetBuildInfo());





function pairsByKeys (t, f)
	local a = {}

	for n in pairs(t) do table.insert(a, n) end

	table.sort(a, f)

	local i = 0
	local iter = function ()
		i = i + 1
		if a[i] then return a[i], t[a[i]] else return nil end
	end

	return iter
end





function BlizzMove:FuckReturnBreaksLoop(frameName, frameData, addonName)

	if frameData.MinVersion and frameData.MinVersion > version then return end
	if frameData.MaxVersion and frameData.MaxVersion < version then return end

	local frameHandle = _G[frameName];

	if not frameHandle then

		print("The frame '" .. frameName .. "' does not exist on version (" .. version .. ")[" .. addonName .. "], notify authors!");

		return;

	else

		if frameData.SubFrames then

			for subFrameName, subFrameData in pairsByKeys(frameData.SubFrames) do

				BlizzMove:FuckReturnBreaksLoop(subFrameName, subFrameData, addonName);

			end

		end

	end

end

function BlizzMove:PrintHelloWorld()

	if BlizzMove.Frames then

		for frameName, frameData in pairsByKeys(BlizzMove.Frames) do

			BlizzMove:FuckReturnBreaksLoop(frameName, frameData, "UIParent");

		end

	end

	if BlizzMove.AddOnFrames then

		for addonName, frameList in pairsByKeys(BlizzMove.AddOnFrames) do

			if not IsAddOnLoaded(addonName) then LoadAddOn(addonName); end

			if frameList then

				for frameName, frameData in pairsByKeys(frameList) do

					BlizzMove:FuckReturnBreaksLoop(frameName, frameData, addonName);

				end

			end

		end

	end

end