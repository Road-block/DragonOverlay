local DragonOverlay = CreateFrame('Frame', 'DragonOverlay', UIParent)
local TargetFrame

DragonOverlayOptions = {
	['worldboss'] = 'ClassicBoss',
	['elite'] = 'ClassicElite',
	['rare'] = 'ClassicRare',
	['rareelite'] = 'ClassicRareElite',
	['ClassIcon'] = "1",
	['FlipDragon'] = "0",
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

function DragonOverlay:GetOptions()
	if not pfUI and pfUI.gui and pfUI.gui.CreateConfigTab and pfUI.gui.CreateConfig then return end
	local texValues = {
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
	if not pfUI.gui.dragonoverlay then
		pfUI.gui.dragonoverlay = pfUI.gui:CreateConfigTab("|cffDA70D6"..GetAddOnMetadata('DragonOverlay', 'Title').."|r")	
		pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "Class Icon", DragonOverlayOptions, "ClassIcon", "checkbox")
		pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "Flip Dragon", DragonOverlayOptions, "FlipDragon", "checkbox")
		local dd = {}
		table.insert(dd,pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "Rare", DragonOverlayOptions, "rare", "dropdown", texValues))
		table.insert(dd,pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "Elite", DragonOverlayOptions, "elite", "dropdown", texValues))
		table.insert(dd,pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "Rare Elite", DragonOverlayOptions, "rareelite", "dropdown", texValues))
		table.insert(dd,pfUI.gui:CreateConfig(pfUI.gui.dragonoverlay, "World Boss", DragonOverlayOptions, "worldboss", "dropdown", texValues))
		for _,opt in pairs(dd) do -- no idea why these specific dropdowns are drawn misaligned
			opt.input:ClearAllPoints()
			opt.input:SetPoint("TOPRIGHT", -30, 0)
			opt.input.point = "TOPRIGHT"
			opt.input.relativePoint = "TOPRIGHT"
		end
		if pfUI.gui.elements then
			local found = false
			for k,v in pairs(pfUI.gui.elements) do
				if v == pfUI.gui.dragonoverlay then
					found = true
					break
				end
			end
			if not found then 
				table.insert(pfUI.gui.elements, pfUI.gui.dragonoverlay)
			end
		end
	end
end

function DragonOverlay:SetOverlay(Texture)
	if UnitIsPlayer('target') and DragonOverlayOptions['ClassIcon']=="1" then
		local _,Class = UnitClass('target')
		self:SetWidth(24)
		self:SetHeight(24)
		self.Texture:SetTexture(DragonOverlay.ClassTextures.texture)
		self.Texture:SetTexCoord(unpack(DragonOverlay.ClassTextures[Class]))
	else
		if Texture and string.find(Texture, 'Classic') then
			self:SetWidth(80)
			self:SetHeight(80)
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
		self:SetPoint('CENTER', TargetFrame, 'TOP', 0, 5)
	end

	self:Show()
end

DragonOverlay:RegisterEvent('PLAYER_LOGIN')
DragonOverlay:SetScript('OnEvent', function()
	local self = this
	self:Hide()
	if event == 'PLAYER_LOGIN' then
		TargetFrame = pfUI and pfUI.uf and pfUI.uf.target
		if not TargetFrame then return end

		self:GetOptions()

		self.Texture = self:CreateTexture(nil, 'ARTWORK')
		self.Texture:SetAllPoints()
		self:SetParent(TargetFrame)
		self:SetFrameLevel(12)
		self:RegisterEvent('PLAYER_TARGET_CHANGED')
	else
		local TargetClass = UnitClassification('target')
		if TargetClass == 'normal' then
			self:SetOverlay(nil)
		else
			self:SetOverlay(DragonOverlay.Textures[DragonOverlayOptions[TargetClass]])
		end
	end
end)
