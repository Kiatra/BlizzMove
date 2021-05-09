-- upvalue the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local CreateFrame = _G.CreateFrame;
local UIParent = _G.UIParent;
local pairs = _G.pairs;
local type = _G.type;
local C_Console__GetAllCommands = _G.C_Console.GetAllCommands;
local string__format = _G.string.format;
local GetCVarInfo = _G.GetCVarInfo;
local IsAddOnLoaded = _G.IsAddOnLoaded;
local GetNumAddOns = _G.GetNumAddOns;
local GetAddOnInfo = _G.GetAddOnInfo;
local GetAddOnMetadata = _G.GetAddOnMetadata;

local BlizzMove = LibStub('AceAddon-3.0'):GetAddon('BlizzMove');
if not BlizzMove then return ; end

local Module = BlizzMove:NewModule('Debug')

local json = LibStub('JsonLua-1.0');

Module.frameConfig = {
    point = 'CENTER',
    relativeFrame = nil,
    relativePoint = 'CENTER',
    ofsx = 0,
    ofsy = 0,
    width = 750,
    height = 400,
}
Module.bannedCharacterPattern = '[^a-zA-Z0-9 !@#$%^&*()_+\-=,.:;?~`{}[<>]';

local function encode_string(val)
    return '"' .. val:gsub(Module.bannedCharacterPattern, function(c) return string__format('"..strchar(%d).."', c:byte()); end) .. '"';
end

function Module:DumpAllData(changedCVarsOnly)
    local data = {};
    data.cvars = self:ExtractCVars(changedCVarsOnly);
    for _, info in pairs(data.cvars) do
        info.value = info.value:gsub(self.bannedCharacterPattern, function(c) return string__format('\\u%04x', c:byte()); end)
    end
    data.savedVars = self:ExtractSavedVars();
    data.addons = self:ExtractAddonList();

    local frame = self:GetMainFrame(json.encode(data));
    frame:Show();
end

function Module:DumpCVars(options)
    local pastableFormat = not not options.pastableFormat;
    local changedOnly = not not options.changedOnly;

    local data = self:ExtractCVars(changedOnly);
    local text = '';
    if(pastableFormat) then
        for command, info in pairs(data) do
            if not info.readonly then
                text = text .. string__format('/run C_CVar.SetCVar(\"%s\", %s)\n', command, encode_string(info.value));
            end
        end
    else
        for _, info in pairs(data) do
            info.value = info.value:gsub(self.bannedCharacterPattern, function(c) return string__format('\\u%04x', c:byte()); end)
        end
        text = json.encode(data);
    end

    local frame = self:GetMainFrame(text);
    frame:Show();
end

function Module:ExtractCVars(changedOnly)
    local ret = {};

    for _, v in pairs(C_Console__GetAllCommands()) do
        local value, defaultValue, account, character, _, _, readonly = GetCVarInfo(v.command);
        local changed = (value ~= defaultValue);
        if not changedOnly or changed then
            ret[v.command] = {
                value = value,
                defaultValue = defaultValue,
                changed = changed,
                scope = ((account and 'account') or (character and 'character') or 'unknown'),
                readonly = readonly,
            };
        end
    end

    return ret;
end

function Module:ExtractAddonList()
    local ret = {};
    for i = 1, GetNumAddOns() do
        local addonName, _, _, loadable, _ = GetAddOnInfo(i);
        if loadable then
            local version = GetAddOnMetadata(addonName, 'Version') or 'unknown';
            ret[addonName] = {
                version = version,
                loaded = IsAddOnLoaded(i),
            };
        end
    end
    return ret;
end

function Module:ExtractSavedVars()
    return BlizzMove.DB;
end

function Module:GetMainFrame(text)
    -- Frame code largely adapted from the simulationcraft addon
    if not _G.BlizzMoveCopyFrame then
        -- Main Frame
        local f = CreateFrame('Frame', 'BlizzMoveCopyFrame', UIParent, 'DialogBoxFrame');
        f:ClearAllPoints();
        -- load position from local DB
        f:SetPoint(
                self.frameConfig.point,
                self.frameConfig.relativeFrame,
                self.frameConfig.relativePoint,
                self.frameConfig.ofsx,
                self.frameConfig.ofsy
        );
        f:SetSize(self.frameConfig.width, self.frameConfig.height);
        f:SetBackdrop({
            bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
            edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
            edgeSize = 16,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        });
        f:SetMovable(true);
        f:SetClampedToScreen(true);
        f:SetScript('OnMouseDown', function(frame, button)
            if button == 'LeftButton' then
                frame:StartMoving();
            end
        end);
        f:SetScript('OnMouseUp', function(frame, button)
            frame:StopMovingOrSizing();
            -- save position between sessions
            local point, relativeFrame, relativeTo, ofsx, ofsy = frame:GetPoint();
            self.frameConfig.point = point;
            self.frameConfig.relativeFrame = relativeFrame;
            self.frameConfig.relativePoint = relativeTo;
            self.frameConfig.ofsx = ofsx;
            self.frameConfig.ofsy = ofsy;
        end);

        -- scroll frame
        local sf = CreateFrame('ScrollFrame', 'BlizzMoveCopyFrameScrollFrame', f, 'UIPanelScrollFrameTemplate');
        sf:SetPoint('LEFT', 16, 0);
        sf:SetPoint('RIGHT', -32, 0);
        sf:SetPoint('TOP', 0, -32);
        sf:SetPoint('BOTTOM', _G.BlizzMoveCopyFrameButton, 'TOP', 0, 0);

        -- edit box
        local eb = CreateFrame('EditBox', 'BlizzMoveCopyFrameEditBox', _G.BlizzMoveCopyFrameScrollFrame);
        eb:SetSize(sf:GetSize());
        eb:SetMultiLine(true);
        eb:SetAutoFocus(true);
        eb:SetFontObject('ChatFontNormal');
        eb:SetScript('OnEscapePressed', function() f:Hide() end);
        sf:SetScrollChild(eb);

        -- resizing
        f:SetResizable(true);
        f:SetMinResize(150, 100);
        local rb = CreateFrame('Button', f);
        rb:SetPoint('BOTTOMRIGHT', -6, 7);
        rb:SetSize(16, 16);

        rb:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up');
        rb:SetHighlightTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight');
        rb:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down');

        rb:SetScript('OnMouseDown', function(frame, button)
            if button == 'LeftButton' then
                f:StartSizing('BOTTOMRIGHT');
                frame:GetHighlightTexture():Hide(); -- more noticeable
            end
        end);
        rb:SetScript('OnMouseUp', function(frame, button)
            f:StopMovingOrSizing();
            frame:GetHighlightTexture():Show();
            eb:SetWidth(sf:GetWidth());

            -- save size between sessions
            self.frameConfig.width = f:GetWidth();
            self.frameConfig.height = f:GetHeight();
        end);

        _G.BlizzMoveCopyFrame = f;
    end
    _G.BlizzMoveCopyFrameEditBox:SetText(text);
    _G.BlizzMoveCopyFrameEditBox:HighlightText();
    return _G.BlizzMoveCopyFrame;
end