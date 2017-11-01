-- Sucks that we have to do this but it's the simplest way
-- partial copy-paste of pfUI's private method with just the widget types we need
-- This will need to be updated if the pfUI implementation changes
local function pfUI_CreateConfig(parent, caption, category, config, widget, values, skip, named, type)
  if not pfUI_config then return end
  if not (pfUI and pfUI.api and pfUI.api.CreateBackdrop and pfUI.api.strsplit) then return end
  local CreateBackdrop,strsplit = pfUI.api.CreateBackdrop,pfUI.api.strsplit
  local C = pfUI_config
  if parent.objectCount == nil then
    parent.objectCount = 1
  elseif not skip then
    parent.objectCount = parent.objectCount + 1
    parent.lineCount = 1
  end

  if skip then
    if parent.lineCount == nil then
      parent.lineCount = 1
    end

    if skip then
      parent.lineCount = parent.lineCount + 1
    end
  end

  if not caption then return end

  -- basic frame
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetWidth(420)
  frame:SetHeight(25)
  frame:SetPoint("TOPLEFT", 25, parent.objectCount * -25)
  frame:EnableMouse(true)
  frame:SetScript("OnEnter", function()
    this:SetBackdropBorderColor(1,1,1,.3)
  end)

  frame:SetScript("OnLeave", function()
    this:SetBackdropBorderColor(1,1,1,.15)
  end)

  if not widget or (widget and widget ~= "button") then

    frame:SetBackdrop(pfUI.backdrop_underline)
    frame:SetBackdropBorderColor(1,1,1,.15)

    -- caption
    frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
    frame.caption:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
    frame.caption:SetAllPoints(frame)
    frame.caption:SetFontObject(GameFontWhite)
    frame.caption:SetJustifyH("LEFT")
    frame.caption:SetText(caption)
  end

  frame.configCategory = category
  frame.configEntry = config

  frame.category = category
  frame.config = config

  if widget == "header" then
    frame:SetBackdrop(nil)
    frame:SetHeight(40)
    parent.objectCount = parent.objectCount + 1
    frame.caption:SetJustifyH("LEFT")
    frame.caption:SetJustifyV("BOTTOM")
    frame.caption:SetTextColor(.2,1,.8,1)
    frame.caption:SetAllPoints(frame)
  end

  -- use text widget (default)
  if not widget or widget == "text" then
    -- input field
    frame.input = CreateFrame("EditBox", nil, frame)
    frame.input:SetTextColor(.2,1,.8,1)
    frame.input:SetJustifyH("RIGHT")

    frame.input:SetWidth(100)
    frame.input:SetHeight(16)
    frame.input:SetPoint("TOPRIGHT" , 0, -2)
    frame.input:SetFontObject(GameFontNormal)
    frame.input:SetAutoFocus(false)
    frame.input:SetText(category[config])
    frame.input:SetScript("OnEscapePressed", function(self)
      this:ClearFocus()
    end)

    frame.input:SetScript("OnTextChanged", function(self)
      if ( type and type ~= "number" ) or tonumber(this:GetText()) then
        if this:GetText() ~= this:GetParent().category[this:GetParent().config] then pfUI.gui.settingChanged = true end
        this:SetTextColor(.2,1,.8,1)
        this:GetParent().category[this:GetParent().config] = this:GetText()
      else
        this:SetTextColor(1,.3,.3,1)
      end
    end)
  end

  -- use checkbox widget
  if widget == "checkbox" then
    -- input field
    frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.input:SetNormalTexture("")
    frame.input:SetPushedTexture("")
    frame.input:SetHighlightTexture("")
    CreateBackdrop(frame.input, nil, true)
    frame.input:SetWidth(14)
    frame.input:SetHeight(14)
    frame.input:SetPoint("TOPRIGHT" , 0, -4)
    frame.input:SetScript("OnClick", function ()
      if this:GetChecked() then
        this:GetParent().category[this:GetParent().config] = "1"
      else
        this:GetParent().category[this:GetParent().config] = "0"
      end
      pfUI.gui.settingChanged = true
    end)

    if category[config] == "1" then frame.input:SetChecked() end
  end

  -- use dropdown widget
  if widget == "dropdown" and values then
    if not pfUI.gui.ddc then pfUI.gui.ddc = 1 else pfUI.gui.ddc = pfUI.gui.ddc + 1 end
    local name = pfUI.gui.ddc
    if named then name = named end

    frame.input = CreateFrame("Frame", "pfUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
    frame.input:ClearAllPoints()
    frame.input:SetPoint("TOPRIGHT" , 20, 3)
    frame.input:Show()
    frame.input.point = "TOPRIGHT"
    frame.input.relativePoint = "BOTTOMRIGHT"
    frame.input.values = values

    frame.input.Refresh = function()
      local function CreateValues()
        local info = {}
        for i, k in pairs(frame.input.values) do
          -- get human readable
          local value, text = strsplit(":", k)
          text = text or value

          info.text = text
          info.checked = false
          info.func = function()
            UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
            if category[config] ~= value then
              pfUI.gui.settingChanged = true
              category[config] = value
            end
          end

          UIDropDownMenu_AddButton(info)
          if category[config] == value then
            frame.input.current = i
          end
        end
      end

      UIDropDownMenu_Initialize(frame.input, CreateValues)
    end

    frame.input:Refresh()

    UIDropDownMenu_SetWidth(120, frame.input)
    UIDropDownMenu_SetButtonWidth(125, frame.input)
    UIDropDownMenu_JustifyText("RIGHT", frame.input)
    UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)

    for i,v in ipairs({frame.input:GetRegions()}) do
      if v.SetTexture then v:Hide() end
      if v.SetTextColor then v:SetTextColor(.2,1,.8) end
      if v.SetBackdrop then CreateBackdrop(v) end
    end
  end

  return frame
end

function DragonOverlay.pfUI_AddOptions(parent)
    DragonOverlay.Hooks["OnShow"](parent)
    parent.setup = nil
    pfUI_CreateConfig(parent, "|cffDA70D6DragonOverlay|r", nil, nil, "header")
    pfUI_CreateConfig(parent, "Enable", DragonOverlayOptions, "Enable", "checkbox")
    pfUI_CreateConfig(parent, "Flip Dragon", DragonOverlayOptions, "FlipDragon", "checkbox")
    pfUI_CreateConfig(parent, "Class Icon", DragonOverlayOptions, "ClassIcon", "checkbox")
    pfUI_CreateConfig(parent, "World Boss", DragonOverlayOptions, "worldboss", "dropdown", DragonOverlay.TextureIndex)
    pfUI_CreateConfig(parent, "Elite", DragonOverlayOptions, "elite", "dropdown", DragonOverlay.TextureIndex)
    pfUI_CreateConfig(parent, "Rare", DragonOverlayOptions, "rare", "dropdown", DragonOverlay.TextureIndex)
    pfUI_CreateConfig(parent, "Rare Elite", DragonOverlayOptions, "rareelite", "dropdown", DragonOverlay.TextureIndex)
    parent._dragonoverlay = true
    parent.setup = true
end