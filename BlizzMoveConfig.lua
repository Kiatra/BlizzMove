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

local L = LibStub("AceLocale-3.0"):GetLocale(name);

---@type BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI;

---@class BlizzMoveConfig
local Config = {};
BlizzMove.Config = Config;

Config.version = GetAddOnMetadata(name, "Version") or "unknown";

function Config:GetOptions()
    local leftClick = CreateAtlasMarkup('NPE_LeftClick', 18, 18);
    local rightClick = CreateAtlasMarkup('NPE_RightClick', 18, 18);
    local increment = CreateCounter();

    return {
        type = "group",
        childGroups = "tab",
        args = {
            version = {
                order = increment(),
                type = "description",
                name = L["Version:"] .. " " .. self.version
            },
            mainTab = {
                order = increment(),
                name = L["Info"],
                type = "group",
                args = {
                    description = {
                        order = increment(),
                        type = "description",
                        name =
                            L["This addon makes the Blizzard windows movable."] .. "\n"
                            .. "\n"
                            .. L["To temporarily move a window just %s the window and drag it to where you want it for the current game session."]:format(leftClick) .. "\n"
                            .. "\n"
                            .. L["CTRL + SCROLL over a window to adjust the scale of the window."] .. "\n"
                            .. "\n"
                            .. L["ALT + %s while dragging a detachable child window will detach it from the parent"]:format(leftClick) .. "\n"
                            .. L["Detached windows can be moved and resized independently from the parent."] .. "\n"
                            .. "\n"
                            .. L["Resetting a frame:"] .. "\n"
                            .. "  " .. L["SHIFT + %s to reset the position."]:format(rightClick) .. "\n"
                            .. "  " .. L["CTRL + %s to reset the scale of a window."]:format(rightClick) .. "\n"
                            .. "  " .. L["ALT + %s to re-attach a child window."]:format(rightClick) .. "\n"
                            .. "\n"
                            .. L["Addon authors can enable support for their own custom frames by utilizing the BlizzMoveAPI functions"],
                    },
                    plugins = {
                        order = increment(),
                        type = "execute",
                        name = L["Search for plugins here"],
                        func = function() Config:ShowURLPopup("https://www.curseforge.com/wow/addons/search?search=BlizzMove+plugin"); end,
                        width = 1.5,
                    },
                },
            },
            fullFramesTab = {
                order = increment(),
                name = L["List of frames"],
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.ListOfFramesTable,
            },
            disabledFramesTab = {
                order = increment(),
                name = L["Default disabled frames"],
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.DefaultDisabledFramesTable,
            },
            globalConfigTab = {
                order = increment(),
                name = L["Global Config"],
                type = "group",
                get = function(info) return Config:GetConfig(info[#info]); end,
                set = function(info, value) return Config:SetConfig(info[#info], value); end,
                args = {
                    requireMoveModifier = {
                        order = increment(),
                        name = L["Require move modifier"],
                        desc = L["If enabled BlizzMove requires to hold SHIFT to move frames."],
                        type = "toggle",
                        width = "full",
                    },
                    newline1 = {
                        order = increment(),
                        type = "description",
                        name = "",
                    },
                    savePosStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = L["How should frame positions be remembered?"],
                        desc =
                            L["Do not remember"] .. " >> " .. L["frame positions are reset when you close and reopen them"] .. "\n"
                            .. "\n"
                            .. L["In Session"] .. " >> " .. L["frame positions are saved until you reload your UI"] .. "\n"
                            .. "\n"
                            .. L["Remember Permanently"] .. " >> " .. L["frame positions are remembered until you switch to another option, click the reset button, or disable BlizzMove"],
                        type = "select",
                        values = {
                            off = L["Do not remember"],
                            session = L["In Session, until you reload"],
                            permanent = L["Remember Permanently"],
                        },
                    },
                    saveScaleStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = L["How should frame scales be remembered?"],
                        desc =
                            L["In Session"] .. " >> " .. L["frame scales are saved until you reload your UI"] .. "\n"
                            .. "\n"
                            .. L["Remember Permanently"] .. " >> " .. L["frame scales are remembered until you switch to another option, click the reset button, or disable BlizzMove"],
                        type = "select",
                        values = {
                            session = L["In Session, until you reload"],
                            permanent = L["Remember Permanently"],
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
                        name = L["Reset Permanent Positions"],
                        desc = L["Reset permanently stored positions"],
                        type = "execute",
                        func = function() BlizzMove:ResetPointStorage(); ReloadUI(); end,
                        confirm = function() return L["Are you sure you want to reset permanently stored positions? This will reload the UI."] end,
                    },
                    resetScales = {
                        order = increment(),
                        width = 1.5,
                        name = L["Reset Permanent Scales"],
                        desc = L["Reset permanently stored scales"],
                        type = "execute",
                        func = function() BlizzMove:ResetScaleStorage(); ReloadUI(); end,
                        confirm = function() return L["Are you sure you want to reset permanently stored scales? This will reload the UI."] end,
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
            name = L["Filter"],
            type = "input",
            desc = L["Search by frame name, or '-' for disabled frames, or '+' for enabled frames."],
            order = 1,
            get = function() return self.search; end,
            set = function(_, value) self.search = value; end
        },
        ["1"] = {
            name = L["Clear"],
            type = "execute",
            desc = L["Clear the search filter."],
            order = 2,
            func = function() self.search = ""; end,
            width = 0.5,
        },
    }
    listOfFrames["0"] = {
        name = L["All frames"],
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
                    name = L["Movable frames for %s"]:format(addOnName),
                    type = "multiselect",
                    values = function(info) return BlizzMoveAPI:GetRegisteredFrames(info[#info]); end,
                },
            },
        };
        allFrames[addOnName] = {
            name = L["Movable frames for %s"]:format(addOnName),
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
                            name = L["Movable frames for %s"]:format(addOnName),
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
        text = L["CTRL-C to copy"],
        button1 = CLOSE,
        --- @param dialog StaticPopupTemplate
        --- @param data string
        OnShow = function(dialog, data)
            local function HidePopup()
                dialog:Hide();
            end
            --- @type StaticPopupTemplate_EditBox
            local editBox = dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox;
            editBox:SetScript('OnEscapePressed', HidePopup);
            editBox:SetScript('OnEnterPressed', HidePopup);
            editBox:SetScript('OnKeyUp', function(_, key)
                if IsControlKeyDown() and (key == 'C' or key == 'X') then
                    HidePopup();
                end
            end);
            editBox:SetMaxLetters(0);
            editBox:SetText(data);
            editBox:HighlightText();
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