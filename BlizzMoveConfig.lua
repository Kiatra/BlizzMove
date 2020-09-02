local name = ...
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name);
if not BlizzMove then return end

BlizzMove.Config = BlizzMove.Config or {}
local Config = BlizzMove.Config

Config.version = GetAddOnMetadata("BlizzMove", "Version") or ""

function Config:GetOptions()
	return {
		type = "group",
		childGroups = "tab",
		args = {
			version = {
				order = 0,
				type = "description",
				name = "Version: " .. self.version
			},
			mainTab = {
				order = 1,
				name = "Info",
				type = "group",
				args = {
					des = {
						order = 1,
						type = "description",
						name = [[
This addon makes the Blizzard windows movable.

To temporarily move a window just Left-Click the window and drag it to where you want it for the current game session.

CTRL + SCROLL over a window to adjust the scale of the window.

ALT + Left-Click while dragging a detachable child window will detach it from the parent
Detached windows can be moved and resized independently from the parent.

Resetting a frame:
  SHIFT + Right-Click to reset the position.
  CTRL + Right-Click to reset the scale of a window.
  ALT + Right-Click to re-attach a child window.

Addon authors can enable support for their own custom frames by utilizing the BlizzMoveAPI functions
]],
					},
				},
			},
			disableFramesTab = {
				order = 2,
				name = "Enabled Frames",
				type = "group",
				childGroups = "tree",
				get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
				set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
				args = self.DisableFramesTable,
			},
		},
	}
end

function Config:GetDisableFramesTable()
	local tempTable = {}

	for addOnName, _ in pairs(BlizzMoveAPI:GetRegisteredAddOns()) do
		tempTable[addOnName] = {
			name = addOnName,
			type = "group",
			order = function(info)
				if info[#info] == name then return 0 end
				if string.match(info[#info], "Blizzard_") then return 5 end
				return 1
			end,
			args = {
				[addOnName] = {
					name = "Movable frames for " .. addOnName,
					type = "multiselect",
					values = function(info) return BlizzMoveAPI:GetRegisteredFrames(info[#info]); end,
				},
			},
		}
	end

	return tempTable
end

function Config:Initialize()

	self:RegisterOptions()
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BlizzMove", "BlizzMove")

end

function Config:RegisterOptions()

	self.DisableFramesTable = self:GetDisableFramesTable()

	LibStub("AceConfig-3.0"):RegisterOptionsTable("BlizzMove", self:GetOptions())

end
