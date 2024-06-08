-- up-value the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local pairs = _G.pairs;
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata;
local ReloadUI = _G.ReloadUI;
local string__match = _G.string.match;
local StaticPopupDialogs = _G.StaticPopupDialogs;
local StaticPopup_Show = _G.StaticPopup_Show;
local IsControlKeyDown = _G.IsControlKeyDown;

local name = ... or "BlizzMove";
---@class BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name);
if not BlizzMove then return; end

---@type BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI;

BlizzMove.Config = BlizzMove.Config or {};
---@class BlizzMoveConfig
local Config = BlizzMove.Config;

Config.version = GetAddOnMetadata(name, "Version") or "unknown";

function Config:GetOptions()
    local count = 1;
    local function increment() count = count + 1; return count end;
    return {
        type = "group",
        childGroups = "tab",
        args = {
            version = {
                order = increment(),
                type = "description",
                name = "Version: " .. self.version
            },
            mainTab = {
                order = increment(),
                name = "Info",
                type = "group",
                args = {
                    description = {
                        order = increment(),
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
                    plugins = {
                        order = increment(),
                        type = "execute",
                        name = "Search for plugins here",
                        func = function() Config:ShowURLPopup("https://www.curseforge.com/wow/addons/search?search=BlizzMove+plugin"); end,
                    },
                },
            },
            fullFramesTab = {
                order = increment(),
                name = "List of frames",
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.ListOfFramesTable,
            },
            disabledFramesTab = {
                order = increment(),
                name = "Default disabled frames",
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.DefaultDisabledFramesTable,
            },
            globalConfigTab = {
                order = increment(),
                name = "Global Config",
                type = "group",
                get = function(info) return Config:GetConfig(info[#info]); end,
                set = function(info, value) return Config:SetConfig(info[#info], value); end,
                args = {
                    requireMoveModifier = {
                        order = increment(),
                        name = "Require move modifier.",
                        desc = "If enabled BlizzMove requires to hold shift to move frames.",
                        type = "toggle",
                    },
                    newline1 = {
                        order = increment(),
                        type = "description",
                        name = "",
                    },
                    savePosStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = "How should frame positions be remembered?",
                        desc = [[Do not remember >> frame positions are reset when you close and reopen them

In Session >> frame positions are saved until you reload your UI

Remember Permanently >> frame positions are remembered until you switch to another option; click the reset button; or disable BlizzMove]],
                        type = "select",
                        values = {
                            off = "Do not remember",
                            session = "In Session, until you reload",
                            permanent = "Remember permanently",
                        },
                    },
                    saveScaleStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = "How should frame scales be remembered?",
                        desc = [[In Session >> frame scales are saved until you reload your UI

Remember Permanently >> frame scales are remembered until you switch to another option; click the reset button; or disable BlizzMove]],
                        type = "select",
                        values = {
                            session = "In Session, until you reload",
                            permanent = "Remember permanently",
                        },
                    },
                    newline2 = {
                        order = increment(),
                        type = "description",
                        name = "",
                    },
                    resetPositions = {
                        order = increment(),
                        width = 1.5,
                        name = "Reset Permanent Positions",
                        desc = "Reset permanently stored positions",
                        type = "execute",
                        func = function() BlizzMove:ResetPointStorage(); ReloadUI(); end,
                        confirm = function() return "Are you sure you want to reset permanently stored positions? This will reload the UI." end,
                    },
                    resetScales = {
                        order = increment(),
                        width = 1.5,
                        name = "Reset Permanent Scales",
                        desc = "Reset permanently stored scales",
                        type = "execute",
                        func = function() BlizzMove:ResetScaleStorage(); ReloadUI(); end,
                        confirm = function() return "Are you sure you want to reset permanently stored scales? This will reload the UI." end,
                    },
                },
            },
        },
    }
end

function Config:GetFramesTables()
    local listOfFrames = {};
    local defaultDisabledFrames = {};
    local addonOrder = function(info)
        if info[#info] == name then return 10; end
        if string__match(info[#info], "Blizzard_") then return 30; end
        return 20;
    end;

    local allFrames = {
        ["0"] = {
            name = "Filter",
            type = "input",
            desc = "Search by frame name, or '-' for disabled frames, or '+' for enabled frames.",
            order = 1,
            get = function() return self.search; end,
            set = function(_, value) self.search = value; end
        },
        ["1"] = {
            name = "Clear",
            type = "execute",
            desc = "Clear the search filter.",
            order = 2,
            func = function() self.search = ""; end,
            width = 0.5,
        },
    }
    listOfFrames["0"] = {
        name = "All frames",
        type = "group",
        order = 1,
        args = allFrames,
    };

    for addOnName, _ in pairs(BlizzMoveAPI:GetRegisteredAddOns()) do
        listOfFrames[addOnName] = {
            name = addOnName,
            type = "group",
            order = addonOrder,
            args = {
                [addOnName] = {
                    name = "Movable frames for " .. addOnName,
                    type = "multiselect",
                    values = function(info) return BlizzMoveAPI:GetRegisteredFrames(info[#info]); end,
                },
            },
        };
        allFrames[addOnName] = {
            name = "Movable frames for " .. addOnName,
            type = "multiselect",
            order = addonOrder,
            values = function(info) return self:GetFilteredFrames(info[#info], self.search); end,
            hidden = function(info) return not next(info.option.values(info)); end,
        }
        for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
            if(BlizzMoveAPI:IsFrameDefaultDisabled(addOnName, frameName)) then
                defaultDisabledFrames[addOnName] = {
                    name = addOnName,
                    type = "group",
                    order = addonOrder,
                    args = {
                        [addOnName] = {
                            name = "Movable frames for " .. addOnName,
                            type = "multiselect",
                            values = function(info) return self:GetDefaultDisabledFrames(info[#info]); end,
                        },
                    },
                };
                break;
            end
        end
    end

    return listOfFrames, defaultDisabledFrames;
end

function Config:GetFilteredFrames(addOnName, filter)
    local frames = {};
    for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
        if (
            not filter or filter == ''
            or (filter == '-' and BlizzMoveAPI:IsFrameDisabled(addOnName, frameName))
            or (filter == '+' and not BlizzMoveAPI:IsFrameDisabled(addOnName, frameName))
            or (string__match(string.lower(frameName), string.lower(filter)))
            or (string__match(string.lower(addOnName), string.lower(filter)))
        ) then
            frames[frameName] = frameName;
        end
    end
    return frames;
end

function Config:GetDefaultDisabledFrames(addOnName)
    local returnTable = {};

    for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
        if(BlizzMoveAPI:IsFrameDefaultDisabled(addOnName, frameName)) then
            returnTable[frameName] = frameName;
        end
    end

    return returnTable;
end

function Config:Initialize()
    self.search = "";
    self:RegisterOptions();
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BlizzMove", "BlizzMove");

    StaticPopupDialogs["BlizzMoveURLDialog"] = {
        text = "CTRL-C to copy",
        button1 = "Close",
        OnShow = function(dialog, data)
            local function HidePopup()
                dialog:Hide();
            end
            dialog.editBox:SetScript("OnEscapePressed", HidePopup);
            dialog.editBox:SetScript("OnEnterPressed", HidePopup);
            dialog.editBox:SetScript("OnKeyUp", function(_, key)
                if IsControlKeyDown() and key == "C" then
                    HidePopup();
                end
            end);
            dialog.editBox:SetMaxLetters(0);
            dialog.editBox:SetText(data);
            dialog.editBox:HighlightText();
        end,
        hasEditBox = true,
        editBoxWidth = 240,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    };
end

function Config:RegisterOptions()
    self.ListOfFramesTable, self.DefaultDisabledFramesTable = self:GetFramesTables();
    LibStub("AceConfig-3.0"):RegisterOptionsTable("BlizzMove", self:GetOptions());
end

function Config:GetConfig(property)
    return BlizzMove.DB[property];
end

function Config:SetConfig(property, value)
    local oldValue = BlizzMove.DB[property] or nil;
    BlizzMove.DB[property] = value;
    if property == "savePosStrategy" then
        BlizzMove:SavePositionStrategyChanged(oldValue, value);
    end
end

function Config:ShowURLPopup(url)
    StaticPopup_Show("BlizzMoveURLDialog", _, _, url);
end