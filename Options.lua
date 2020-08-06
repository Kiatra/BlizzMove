_G.BlizzMove = _G.BlizzMove or {}
--local L = LibStub("AceLocale-3.0"):GetLocale("BlizzMove")
local version = GetAddOnMetadata("BlizzMove", "Version") or ""

options = {
	type = "group",
	args = {
		des = {
			order = 0,
			type = "description",
			name = [[
This addon makes the Blizzard windows movable.

To temporarily move a window just click title of the window and drag it to where you want it for the current game session.
CTRL + SCROLL over a window title to adjust the scale of the window.

Resetting a frame:
  SHIFT + Click to reset the position.
  CTRL + Click to reset the scale of a frame.

]],
		},
		version = {
			order = 1,
			type = "description",
			name = "Version" .. ": " .. version
		},
	}
}

function BlizzMove:RegisterOptions()
	if BlizzMove.OptionsAdded then return end
	BlizzMove.OptionsAdded = true

	LibStub("AceConfig-3.0"):RegisterOptionsTable("BlizzMove", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BlizzMove", "BlizzMove")
end
