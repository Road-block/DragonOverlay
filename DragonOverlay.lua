local DragonOverlay = CreateFrame('Frame', 'DragonOverlay', UIParent)
DragonOverlay.EventManager = function()
	this:Hide()
	return this[event]~=nil and this[event](this,event,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11)
end
DragonOverlay:SetScript('OnEvent', DragonOverlay.EventManager)
DragonOverlay:RegisterEvent('VARIABLES_LOADED')
DragonOverlay:RegisterEvent('PLAYER_LOGIN')
DragonOverlay.Hooks = {}
local TargetFrame

local defaults = {
	['worldboss'] = 'ClassicBoss',
	['elite'] = 'ClassicElite',
	['rare'] = 'ClassicRare',
	['rareelite'] = 'ClassicRareElite',
	['ClassIcon'] = "1",
	['FlipDragon'] = "0",
	['Enable'] = "1"
}

DragonOverlay.Textures = {
	['Azure'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Azure',
	['Chromatic'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Chromatic',
	['Crimson'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Crimson',
	['Golden'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Golden',
	['Jade'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Jade',
	['Onyx'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\Onyx',
	['HeavenlyBlue'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\HeavenlyBlue',
	['HeavenlyCrimson'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\HeavenlyCrimson',
	['HeavenlyGolden'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\HeavenlyGolden',
	['HeavenlyJade'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\HeavenlyJade',
	['HeavenlyOnyx'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\HeavenlyOnyx',
	['ClassicElite'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\ClassicElite',
	['ClassicRareElite'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\ClassicRareElite',
	['ClassicRare'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\ClassicRare',
	['ClassicBoss'] = 'Interface\\AddOns\\DragonOverlay\\Textures\\ClassicBoss',
}
DragonOverlay.TextureIndex = {
	"Azure",
	"Chromatic",
	"Crimson",
	"Golden",
	"Jade",
	"Onyx",
	"HeavenlyBlue",
	"HeavenlyCrimson",
	"HeavenlyGolden",
	"HeavenlyJade",
	"HeavenlyOnyx",
	"ClassicElite",
	"ClassicRareElite",
	"ClassicRare",
	"ClassicBoss"	
}

DragonOverlay.ClassTextures = {}
do
	DragonOverlay.ClassTextures.texture = 'Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes'
	DragonOverlay.ClassTextures.size = 256
	DragonOverlay.ClassTextures.cols = 4
	DragonOverlay.ClassTextures.rows = 4
	DragonOverlay.ClassTextures.icon = 64
	DragonOverlay.ClassTextures.indexes = {
		["WARRIOR"]=1,
		["MAGE"]=2,
		["ROGUE"]=3,
		["DRUID"]=4,
		["HUNTER"]=5,
		["SHAMAN"]=6,
		["PRIEST"]=7,
		["WARLOCK"]=8,
		["PALADIN"]=9
	}
	local increment = DragonOverlay.ClassTextures.icon / DragonOverlay.ClassTextures.size
	for class,index in pairs(DragonOverlay.ClassTextures.indexes) do
		local index = index-1
		local left, right, top, bottom
		left = math.mod(index , DragonOverlay.ClassTextures.cols) * increment
		right = left + increment
		top = math.floor(index / DragonOverlay.ClassTextures.rows) * increment
		bottom = top + increment
		DragonOverlay.ClassTextures[class] = {left,right,top,bottom}
	end
end

function DragonOverlay:Update()
	self:GetScript('OnEvent')(self, 'PLAYER_TARGET_CHANGED')
end

function DragonOverlay:AddOptions()
	if not (pfUI 
	and pfUI.gui 
	and pfUI.gui.tabs 
	and pfUI.gui.tabs.uf
	and pfUI.gui.tabs.uf.tabs
	and pfUI.gui.tabs.uf.tabs.target) then 
		return 
	end

	local parent = pfUI.gui.tabs.uf.tabs.target
	if (parent) and (not parent._dragonoverlay) then
		self.Hooks.OnShow = parent:GetScript("OnShow")
		parent:SetScript("OnShow",function() DragonOverlay.pfUI_AddOptions(parent) end)
		parent._dragonoverlay = true
	end
end

function DragonOverlay:SetOverlay(Texture)
	if not (DragonOverlayOptions.Enable=="1") then
		self:Hide()
		return
	end
	if UnitIsPlayer('target') and (not UnitIsUnit('target','player')) and DragonOverlayOptions['ClassIcon']=="1" then
		local _,Class = UnitClass('target')
		self:SetWidth(24)
		self:SetHeight(24)
		self.Texture:SetTexture(DragonOverlay.ClassTextures.texture)
		self.Texture:SetTexCoord(unpack(DragonOverlay.ClassTextures[Class]))
	else
		if Texture and string.find(Texture, 'Classic') then
			local size = TargetFrame:GetHeight()/TargetFrame:GetEffectiveScale()
			self:SetWidth(size or 80)
			self:SetHeight(size or 80)
		else
			self:SetWidth(128)
			self:SetHeight(32)
		end
		self.Texture:SetTexture(Texture or nil)
		self.Texture:SetTexCoord(DragonOverlayOptions['FlipDragon']=="1" and 1 or 0, DragonOverlayOptions['FlipDragon']=="1" and 0 or 1, 0, 1)
	end
	self:ClearAllPoints()

	if Texture and string.find(Texture, 'Classic') then
		self:SetPoint('CENTER', TargetFrame, (DragonOverlayOptions['FlipDragon']=="1" and 'RIGHT' or 'LEFT'), (DragonOverlayOptions['FlipDragon']=="1" and -17 or 17), 0)
	else
		self:SetPoint('CENTER', TargetFrame, 'TOP', 25, 5)
	end

	self:Show()
end

function DragonOverlay:PLAYER_LOGIN(event)
	TargetFrame = pfUI and pfUI.uf and pfUI.uf.target
	if not TargetFrame then return end
	DragonOverlayOptions = DragonOverlayOptions or defaults
	self:AddOptions()

	self.Texture = self:CreateTexture(nil, 'ARTWORK')
	self.Texture:SetAllPoints()
	self:SetParent(TargetFrame)
	self:SetFrameLevel(12)
	self:RegisterEvent('PLAYER_TARGET_CHANGED')	
end
function DragonOverlay:VARIABLES_LOADED(event)
  if UnitIsConnected("player") then
    self:UnregisterEvent("PLAYER_LOGIN")
    self:PLAYER_LOGIN("PLAYER_LOGIN")
  end	
end
function DragonOverlay:PLAYER_TARGET_CHANGED()
	local TargetClass = UnitClassification('target')
	if TargetClass == 'normal' then
		self:SetOverlay(nil)
	else
		self:SetOverlay(DragonOverlay.Textures[DragonOverlayOptions[TargetClass]])
	end	
end
