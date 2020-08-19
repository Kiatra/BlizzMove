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
			mainTab = {
				order = 0,
				name = "Info",
				type = "group",
				args = {
					version = {
						order = 0,
						type = "description",
						name = "Version: " .. Config.version
					},
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
				order = 1,
				name = "Enabled Frames",
				type = "group",
				childGroups = "select",
				args = self.DisableFramesTable,
			},
		},
	}
end

function Config:GetDisableFramesTable()
	local tempTable = {}

	for addOnName, _ in pairs(BlizzMoveAPI:GetRegisteredAddOns()) do
		tempTable["AddOnGroup_" .. addOnName] = {
			name = addOnName,
			type = "group",
			args = {
				["AddOn_" .. addOnName] = {
					name = "AddOn frames for " .. addOnName,
					type = "multiselect",
					values = function() return BlizzMoveAPI:GetRegisteredFrames(addOnName); end,
					get = function(_, frameName) return not BlizzMoveAPI:IsFrameDisabled(addOnName, frameName); end,
					set = function(_, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(addOnName, frameName, not enabled); end,
				},
			},
		}
	end

	return tempTable
end


function Config:RegisterOptions()
	if self.OptionsAdded then return end
	self.OptionsAdded = true

	self.DisableFramesTable = self:GetDisableFramesTable()

	LibStub("AceConfig-3.0"):RegisterOptionsTable("BlizzMove", self:GetOptions())
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BlizzMove", "BlizzMove")
end
