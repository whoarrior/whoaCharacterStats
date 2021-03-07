local addonName, addon = ...

settings = {}

local ADDON = ADDON_NAME
local NAME = "whoa |cFFFFFFFFCharacterStats|r"
local REPO = "https://github.com/whoarrior/whoaCharacterStats"
local defaults = whoaCharacterStats.defaults
local _, class = UnitClass("player")
local realm = GetCVar("realmName")
local char = UnitName("player")

local COL_WIDTH    = 180
local COL_PADDING  = 25
local LINE_HEIGHT  = 25
local LINE_PADDING = 5

local BTN_WIDTH  = COL_WIDTH + 5
local BTN_HEIGHT = LINE_HEIGHT + 2

local ANCHOR = "TOPLEFT"
local COL1_X = 30
local COL2_X = 220
local COL3_X = 410
local LINE_01_Y =       -30 - LINE_HEIGHT - LINE_PADDING * 4
local LINE_02_Y = LINE_01_Y - LINE_HEIGHT - LINE_PADDING * 4
local LINE_03_Y = LINE_02_Y - LINE_HEIGHT - LINE_PADDING * 4
local LINE_04_Y = LINE_03_Y - LINE_HEIGHT - LINE_PADDING * 8
local LINE_05_Y = LINE_04_Y - LINE_HEIGHT - LINE_PADDING
local LINE_06_Y = LINE_05_Y - LINE_HEIGHT - LINE_PADDING
local LINE_07_Y = LINE_06_Y - LINE_HEIGHT - LINE_PADDING * 8
local LINE_08_Y = LINE_07_Y - LINE_HEIGHT - LINE_PADDING * 4
local LINE_09_Y = LINE_08_Y - LINE_HEIGHT - LINE_PADDING * 4
local LINE_10_Y = LINE_09_Y - LINE_HEIGHT - LINE_PADDING * 4
local BOTTOM_LINE = -530
local x, y = 16, -16

local ANCHORS = {
    "CENTER",
    "TOPLEFT",
    "TOP",
    "TOPRIGHT",
    "RIGHT",
    "BOTTOMRIGHT",
    "BOTTOM",
    "BOTTOMLEFT",
    "LEFT",
}
local PARENTS = {
    "UIParent",
    "PlayerFrame",
    "TargetFrame",
    "FocusFrame",
}
local DECIMALS = {
    0,
    1,
    2,
}
local STATS = {
    "Haste",
    "Mastery",
    "Crit",
    "Versatility",
}

local function createButton(width, x, y, label, onClick)
    local o = CreateFrame("Button", nil, whoaCharacterStats.optionPanel, "UIPanelButtonTemplate")
    o:SetSize(width, BTN_HEIGHT)
    o:SetText(label)
    o:SetPoint(ANCHOR, x, y)
    o:SetScript("OnClick", onClick)
end

local function createCheckButton(addon, n, x, y, label, desc, cvar, onClick)
    local o = CreateFrame("CheckButton", addon..n, whoaCharacterStats.optionPanel, "InterfaceOptionsCheckButtonTemplate")
    o:SetScript("OnClick", function(self)
        local tick = self:GetChecked()
        onClick(self, tick and true or false)
        if tick then
            PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)
    o.label = _G[o:GetName() .. "Text"]
    o.label:SetText(label)
    o.tooltipText = label
    o.tooltipRequirement = desc
    o:SetChecked(cvar)
    o:SetPoint(ANCHOR, x, y)
end

local function createDropDown(n, array, x, y, label, cvar, save, update)
    local info = {}
    local o = CreateFrame("Frame", n, whoaCharacterStats.optionPanel, "UIDropDownMenuTemplate")
    o:SetPoint(ANCHOR, x, y)
    o.initialize = function()
        wipe(info)
        for _, v in pairs(array) do
            info.text = v
            info.value = v
            info.func = function(self)
                save(self.value)
                _G[n.."Text"]:SetText(self:GetText())
                update()
            end
            info.checked = v == cvar()
            UIDropDownMenu_AddButton(info)
        end
    end
    local oLabel = o:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    oLabel:SetPoint("BOTTOMLEFT", o, "TOPLEFT", 25, -2)
    oLabel:SetJustifyH("LEFT")
    oLabel:SetHeight(18)
    oLabel:SetText(label)
end

local function createSlider(name, label, percent, x, y, min, max, update)
    local o = CreateFrame("Slider", name, whoaCharacterStats.optionPanel, "HorizontalSliderTemplate")
    o:SetPoint(ANCHOR, x, y)
    o:SetSize(170, 16)
    o:SetMinMaxValues(min, max)
    local oLabel = o:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    oLabel:SetPoint("BOTTOMLEFT", o, "TOPLEFT", 26, -2)
    oLabel:SetJustifyH("LEFT")
    oLabel:SetHeight(18)
    oLabel:SetText(label)
    local oMin = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    oMin:SetPoint("TOPLEFT", o, "BOTTOMLEFT", 2, -1)
    if percent then
        oMin:SetFormattedText("%s%%", (min * 100))
    else
        oMin:SetText(min)
    end
    local oMax = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    oMax:SetPoint("TOPRIGHT", o, "BOTTOMRIGHT", -2, -1)
    if percent then
        oMax:SetFormattedText("%s%%", (max * 100))
    else
        oMax:SetText(max)
    end
    local oValue = o:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    oValue:SetPoint("TOP", o, "BOTTOM", 0, -1)
    oValue:SetText(whoaRound(o:GetValue(), 0))
    o:SetScript("OnValueChanged", function(self, value)
        update(value)
        if percent then
            oValue:SetFormattedText("%s%%", (whoaRound(value, 2) * 100))
        else
            oValue:SetText(whoaRound(value, 0))
        end
    end)
end

---------------------------------------------------
-- OPTIONPANEL
---------------------------------------------------
whoaCharacterStats.optionPanel = CreateFrame("Frame", "whoaCharacterStats.optionPanel", UIParent)
local title = whoaCharacterStats.optionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint(ANCHOR, x, y)
title:SetText(NAME)
local repoLink = whoaCharacterStats.optionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
repoLink:SetPoint(ANCHOR, x, y-20)
repoLink:SetText(REPO)
whoaCharacterStats.optionPanel.name = NAME

---------------------------------------------------
-- BUTTONS
---------------------------------------------------
createButton(BTN_WIDTH-25, COL3_X+25, LINE_02_Y,   "Center Position",  function() whoaCharacterStats_centerPosition(); end)
createButton(BTN_WIDTH-25, COL3_X+25, LINE_03_Y,   "Default Position", function() whoaCharacterStats_defaultPosition(); end)
createButton(BTN_WIDTH-25, COL3_X+25, LINE_06_Y,   "Default Scaling",  function() whoaCharacterStats_defaultScale(); end)
createButton(BTN_WIDTH-25, COL3_X+25, BOTTOM_LINE, "Default Settings", function()
    whoaCharacterStats_setDefaults()
    whoaCharacterStats_drawColumns()
    whoaCharacterStats_showBorder()
    whoaCharacterStats_updatePosition()
    whoaCharacterStats_updateOptionPanel()
    whoaCharacterStats_update()
end)

---------------------------------------------------
-- CHECKBOXES
---------------------------------------------------
createCheckButton(addonName, "SwitchColumnsCb", COL1_X+20, LINE_04_Y, "Switch Columns", "Switch the values in the left and the right column.", settings.switch,     function(self, value) whoaCharacterStats_drawColumns(value); end)
createCheckButton(addonName, "ShowBorderCb",    COL1_X+20, LINE_05_Y, "Show Border",    "Show a border.",                                      settings.showBorder, function(self, value) whoaCharacterStats_showBorder(value); whoaCharacterStats_update(); end)
createCheckButton(addonName, "HighlightCb",     COL1_X+20, LINE_06_Y, "Highlighting",   "Highlight increasing, or decreasing stats.",          settings.highlight,  function(self, value) settings.highlight = value; end)

---------------------------------------------------
-- DROPDOWNS
---------------------------------------------------
createDropDown("WhoaCharacterStatsAnchorDropDown",        ANCHORS,  COL1_X, LINE_01_Y, "Anchor",             function() return settings.a1;           end, function(value) settings.a1           = value; end, function() whoaCharacterStats_updatePosition(); end)
createDropDown("WhoaCharacterStatsParentDropDown",        PARENTS,  COL1_X, LINE_02_Y, "Parent",             function() return settings.p;            end, function(value) settings.p            = value; end, function() whoaCharacterStats_updatePosition(); end)
createDropDown("WhoaCharacterStatsAnchorParentDropDown",  ANCHORS,  COL1_X, LINE_03_Y, "Anchor Parent",      function() return settings.a2;           end, function(value) settings.a2           = value; end, function() whoaCharacterStats_updatePosition(); end)
createDropDown("WhoaCharacterStatsDecimalPlacesDropDown", DECIMALS, COL2_X, LINE_04_Y, "Decimal Places",     function() return settings.dp;           end, function(value) settings.dp           = value; end, function() whoaCharacterStats_update(); end)
createDropDown("WhoaCharacterStatsFirstDropDown",         STATS,    COL1_X, LINE_07_Y, "1st secondary stat", function() return settings.order["1st"]; end, function(value) settings.order["1st"] = value; end, function() whoaCharacterStats_drawColumns(); end)
createDropDown("WhoaCharacterStatsSecondDropDown",        STATS,    COL1_X, LINE_08_Y, "2nd secondary stat", function() return settings.order["2nd"]; end, function(value) settings.order["2nd"] = value; end, function() whoaCharacterStats_drawColumns(); end)
createDropDown("WhoaCharacterStatsThirdDropDown",         STATS,    COL1_X, LINE_09_Y, "3rd secondary stat", function() return settings.order["3rd"]; end, function(value) settings.order["3rd"] = value; end, function() whoaCharacterStats_drawColumns(); end)
createDropDown("WhoaCharacterStatsFourthDropDown",        STATS,    COL1_X, LINE_10_Y, "4th secondary stat", function() return settings.order["4th"]; end, function(value) settings.order["4th"] = value; end, function() whoaCharacterStats_drawColumns(); end)

---------------------------------------------------
-- SLIDER
---------------------------------------------------
createSlider("whoaXSlider",       "x",       false, COL2_X, LINE_01_Y+2, -200, 200, function(value) whoaCharacterStats_updatePosition(value, nil); end)
createSlider("whoaYSlider",       "y",       false, COL2_X, LINE_02_Y+2, -200, 200, function(value) whoaCharacterStats_updatePosition(nil, value); end)
createSlider("whoaScalingSlider", "Scaling", true,  COL2_X, LINE_06_Y,     .5,   3, function(value) whoaCharacterStats_setScale(value); end)

---------------------------------------------------

function whoaCharacterStats_setDefaults()
    settings.showBorder   = defaults.showBorder
    settings.highlight    = defaults.highlight
    settings.switch       = defaults.switch
    if settings.switch then
        settings.col1     = defaults.right.col1
        settings.col2     = defaults.right.col2
        settings.txt1     = defaults.right.txt1
        settings.txt2     = defaults.right.txt2
        settings.padding  = defaults.right.padding
    else
        settings.col1     = defaults.left.col1
        settings.col2     = defaults.left.col2
        settings.txt1     = defaults.left.txt1
        settings.txt2     = defaults.left.txt2
        settings.padding  = defaults.left.padding
    end
    settings.lh           = defaults.lh
    settings.dp           = defaults.dp
    settings.scale        = defaults.scale
    settings.order["1st"] = defaults.order["1st"]
    settings.order["2nd"] = defaults.order["2nd"]
    settings.order["3rd"] = defaults.order["3rd"]
    settings.order["4th"] = defaults.order["4th"]
    settings.a1           = defaults.position.a1
    settings.p            = defaults.position.p
    settings.a2           = defaults.position.a2
    settings.x            = defaults.position.x
    settings.y            = defaults.position.y
end

function whoaCharacterStats_getSettings()
    if settings.showBorder   == nil then settings.showBorder   = defaults.showBorder    end
    if settings.highlight    == nil then settings.highlight    = defaults.highlight     end
    if settings.switch       == nil then settings.switch       = defaults.switch        end
    if settings.switch then
        if settings.col1     == nil then settings.col1         = defaults.right.col1    end
        if settings.col2     == nil then settings.col2         = defaults.right.col2    end
        if settings.txt1     == nil then settings.txt1         = defaults.right.txt1    end
        if settings.txt2     == nil then settings.txt2         = defaults.right.txt2    end
        if settings.padding  == nil then settings.padding      = defaults.right.padding end
    else
        if settings.col1     == nil then settings.col1         = defaults.left.col1     end
        if settings.col2     == nil then settings.col2         = defaults.left.col2     end
        if settings.txt1     == nil then settings.txt1         = defaults.left.txt1     end
        if settings.txt2     == nil then settings.txt2         = defaults.left.txt2     end
        if settings.padding  == nil then settings.padding      = defaults.left.padding  end
    end
    if settings.lh           == nil then settings.lh           = defaults.lh            end
    if settings.dp           == nil then settings.dp           = defaults.dp            end
    if settings.scale        == nil then settings.scale        = defaults.scale         end
    if settings.order["1st"] == nil then settings.order["1st"] = defaults.order["1st"]  end
    if settings.order["2nd"] == nil then settings.order["2nd"] = defaults.order["2nd"]  end
    if settings.order["3rd"] == nil then settings.order["3rd"] = defaults.order["3rd"]  end
    if settings.order["4th"] == nil then settings.order["4th"] = defaults.order["4th"]  end
    if settings.a1           == nil then settings.a1           = defaults.position.a1   end
    if settings.p            == nil then settings.p            = defaults.position.p    end
    if settings.a2           == nil then settings.a2           = defaults.position.a2   end
    if settings.x            == nil then settings.x            = defaults.position.x    end
    if settings.y            == nil then settings.y            = defaults.position.y    end
    return settings
end

function whoaCharacterStats_updateOptionPanel()
    whoaScalingSlider:SetValue(settings.scale)
    WhoaCharacterStatsAnchorDropDownText:SetText(settings.a1)
    WhoaCharacterStatsParentDropDownText:SetText(settings.p)
    WhoaCharacterStatsAnchorParentDropDownText:SetText(settings.a2)
    whoaXSlider:SetValue(settings.x)
    whoaYSlider:SetValue(settings.y)
    whoaCharacterStatsSwitchColumnsCb:SetChecked(settings.switch)
    whoaCharacterStatsShowBorderCb:SetChecked(settings.showBorder)
    whoaCharacterStatsHighlightCb:SetChecked(settings.highlight)
    WhoaCharacterStatsDecimalPlacesDropDownText:SetText(settings.dp)
    WhoaCharacterStatsFirstDropDownText:SetText(settings.order["1st"])
    WhoaCharacterStatsSecondDropDownText:SetText(settings.order["2nd"])
    WhoaCharacterStatsThirdDropDownText:SetText(settings.order["3rd"])
    WhoaCharacterStatsFourthDropDownText:SetText(settings.order["4th"])
end

whoaCharacterStats.optionPanel.okay = 
    function (self)
        whoaLog("optionPanel.okay triggered", "DEBUG", LOG_LEVEL, ADDON)
        -- self.originalValue = settings
    end

whoaCharacterStats.optionPanel.cancel =
    function (self)
        whoaLog("optionPanel.cancel triggered", "DEBUG", LOG_LEVEL, ADDON)
        -- settings = self.originalValue
    end

whoaCharacterStats.optionPanel.default =
    function (self)
        whoaLog("optionPanel.default triggered", "DEBUG", LOG_LEVEL, ADDON)
        whoaCharacterStats_setDefaults()
    end

InterfaceOptions_AddCategory(whoaCharacterStats.optionPanel)
