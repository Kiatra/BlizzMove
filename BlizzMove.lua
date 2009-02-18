-- BlizzMmove, move the blizzard frames by yess
local db
local defaultDB = { 
	AchievementFrame = {save = true},
	CalendarFrame = {save = true},
	AuctionFrame = {save = true},
	GuildBankFrame = {save = true},
}

local debug = false
local function Debug(...)
	if debug then
		local s = "BlizzMove:"
		for i=1,select("#", ...) do
			local x = select(i, ...)
			if(type(x)== "string" or type(x)== "number")then
					s = s.." "..x
			else
				if(x)then
					s = s.." ".."not a string"
				else
					s = s.." ".."nil"
				end
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage(s)
	end
end

local function SetMoveHandler(frameToMove, handler)
	if not frameToMove then
		return
	end
	if not handler then
		handler = frameToMove
	end
	
	local settings = db[frameToMove:GetName()]
	if not settings then
		settings = defaultDB[frameToMove:GetName()]
		db[frameToMove:GetName()] = settings
	end
	
	frameToMove:EnableMouse(true)
	frameToMove:SetMovable(true) 
	handler:RegisterForDrag("LeftButton");
	
	handler:SetScript("OnDragStart", 
		function()
			frameToMove:StartMoving()
			frameToMove.isMoving = true
		end
	)
	handler:SetScript("OnDragStop", 
		function()
			frameToMove:StopMovingOrSizing()
			frameToMove.isMoving = false
			if settings then
					settings.point, settings.relativeTo, settings.relativePoint, settings.xOfs, settings.yOfs = frameToMove:GetPoint()
			end
		end
	)

	--override frame position according to settings when shown
	frameToMove:HookScript("OnShow", 
		function(self, ...)
			if settings and settings.point and settings.save then
				self:ClearAllPoints()
				self:SetPoint(settings.point,settings.relativeTo, settings.relativePoint, settings.xOfs,settings.yOfs)
				local scale = settings.scale
				if scale then 
					self:SetScale(scale)
				end
			end
		end
	)			
	
	--hook OnMouseUp 
	handler:HookScript("OnMouseUp", 
		function(self, ...)
			if IsControlKeyDown() then
				--toggle save
				if settings then
					settings.save = not settings.save
				else
					db[frameToMove:GetName()] = {}
					settings = db[frameToMove:GetName()]
					settings.save = true
					settings.point, settings.relativeTo, settings.relativePoint, settings.xOfs, settings.yOfs = frameToMove:GetPoint()
				end
			end
		end
	)
	
	--hook Scroll for setting scale
	handler:EnableMouseWheel(true) 
	handler:HookScript("OnMouseWheel", 
		function(self, ...)
			if IsControlKeyDown() then
				local scale = frameToMove:GetScale() or 1
				if(arg1 == 1) then --scale up 
					scale = scale +.1
					if(scale > 1.5) then 
						scale = 1.5
					end
				else -- scale down
					scale = scale -.1
					if(scale < .5) then
						scale = .5
					end
				end
				frameToMove:SetScale(scale)
				if settings then
					settings.scale = scale
				end
				--Debug("scroll", arg1, scale, frameToMove:GetScale())
			end
		end
	)
end

local frame = CreateFrame("Frame")
local function OnEvent()
	Debug(event, arg1, arg2)
	if event == "PLAYER_ENTERING_WORLD" then
		frame:RegisterEvent("ADDON_LOADED") --for blizz lod addons
		db = BlizzMoveDB or defaultDB
		BlizzMoveDB = db
		--SetMoveHandler(frameToMove, handlerFrame)
		SetMoveHandler(CharacterFrame,PaperDollFrame)
		SetMoveHandler(CharacterFrame,TokenFrame)
		SetMoveHandler(CharacterFrame,SkillFrame)
		SetMoveHandler(CharacterFrame,ReputationFrame)
		SetMoveHandler(CharacterFrame,PetPaperDollFrameCompanionFrame)
		SetMoveHandler(SpellBookFrame)
		SetMoveHandler(QuestLogFrame)
		SetMoveHandler(FriendsFrame)
		SetMoveHandler(PVPFrame)
		SetMoveHandler(LFGParentFrame)
		SetMoveHandler(GameMenuFrame)
		SetMoveHandler(GossipFrame)
		SetMoveHandler(AuctionFrame)
		SetMoveHandler(DressUpFrame)
		SetMoveHandler(QuestFrame)
		SetMoveHandler(MerchantFrame)
		SetMoveHandler(HelpFrame)
		SetMoveHandler(PlayerTalentFrame)
		SetMoveHandler(ClassTrainerFrame)
		SetMoveHandler(MailFrame)
		SetMoveHandler(BankFrame)
		SetMoveHandler(VideoOptionsFrame)
		SetMoveHandler(InterfaceOptionsFrame)
		SetMoveHandler(LootFrame)
	-- blizzard lod addons
	elseif arg1 == "Blizzard_InspectUI" then
		SetMoveHandler(InspectFrame)
	elseif arg1 == "Blizzard_GuildBankUI" then
		SetMoveHandler(GuildBankFrame)
	elseif arg1 == "Blizzard_TradeSkillUI" then
		SetMoveHandler(TradeSkillFrame)
	elseif arg1 == "Blizzard_ItemSocketingUI" then
		SetMoveHandler(ItemSocketingFrame)
	elseif arg1 == "Blizzard_BarbershopUI" then
		SetMoveHandler(BarberShopFrame)
	elseif arg1 == "Blizzard_GlyphUI" then
		SetMoveHandler(SpellBookFrame, GlyphFrame)
	elseif arg1 == "Blizzard_MacroUI" then
		SetMoveHandler(MacroFrame)
	elseif arg1 == "Blizzard_AchievementUI" then
		SetMoveHandler(AchievementFrame, AchievementFrameHeader)
	elseif arg1 == "Blizzard_TalentUI" then
		SetMoveHandler(PlayerTalentFrame)
	elseif arg1 == "Blizzard_Calendar" then
		SetMoveHandler(CalendarFrame)
	elseif arg1 == "Blizzard_TrainerUI" then
		SetMoveHandler(ClassTrainerFrame)
	elseif arg1 == "Blizzard_BindingUI" then
		SetMoveHandler(KeyBindingFrame)
	end
end

frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")


----------------------------------------------------------
-- User function to move/lock a frame with a handler
-- handler, the frame the user has clicked on
-- frameToMove, the handler itself, a parent frame of handler 
--              that has UIParent as Parent or nil  
----------------------------------------------------------
BlizzMove = {}
function BlizzMove:Toggle(handler)
	if not handler then
		handler = GetMouseFocus()
	end
	
	if handler:GetName() == "WorldFrame" then
		return
	end
	
	local lastParent = handler
	local frameToMove = handler
	local i=0
	--get the parent attached to UIParent from handler
	while lastParent and lastParent ~= UIParent and i < 100 do
			frameToMove = lastParent --set to last parent
			lastParent = lastParent:GetParent()
			i = i +1
	end
	if handler and frameToMove then
		if handler:GetScript("OnDragStart") then
			handler:SetScript("OnDragStart", nil)
		else
			DEFAULT_CHAT_FRAME:AddMessage("Frame: ", frameToMove:GetName(), " to move with handler ", handler:GetName())
			SetMoveHandler(frameToMove, handler)
		end
	
	else
		DEFAULT_CHAT_FRAME:AddMessage("Error parent not found.")
	end
	
end

BINDING_HEADER_BLIZZMOVE = "BlizzMove";
BINDING_NAME_MOVEFRAME = "Move/Lock a Frame";