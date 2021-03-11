local addonName, addon = ...

settings = {}

local ADDON = ADDON_NAME
local NAME = GetAddOnMetadata(addonName, "Title")
local VERSION = GetAddOnMetadata(addonName, "Version")
local REPO = "https://github.com/whoarrior/whoaCharacterStats"
local defaults = whoaCharacterStats.defaults
local _, class = UnitClass("player")
local realm = GetCVar("realmName")
local char = UnitName("player")

local ANCHOR = "TOPLEFT"
local COL1_X = 30
local COL2_X = 220
local COL3_X = 410
local LINE_01_Y =       -30 - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
local LINE_02_Y = LINE_01_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
local LINE_03_Y = LINE_02_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
local LINE_04_Y = LINE_03_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 8
local LINE_05_Y = LINE_04_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING
local LINE_06_Y = LINE_05_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING
local LINE_07_Y = LINE_06_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 8
local LINE_08_Y = LINE_07_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
local LINE_09_Y = LINE_08_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
local LINE_10_Y = LINE_09_Y - WHOA_LIB_LINE_HEIGHT - WHOA_LIB_LINE_PADDING * 4
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

---------------------------------------------------
-- OPTIONPANEL
---------------------------------------------------
whoaCharacterStats.optionPanel = CreateFrame("Frame", "whoaCharacterStats.optionPanel", UIParent)
local title = whoaCharacterStats.optionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint(ANCHOR, x, y)
title:SetText(NAME.." "..VERSION)
local repoLink = whoaCharacterStats.optionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
repoLink:SetPoint(ANCHOR, x, y-20)
repoLink:SetText(REPO)
whoaCharacterStats.optionPanel.name = NAME

---------------------------------------------------
-- BUTTONS
---------------------------------------------------
whoaLibrary_createButton(WHOA_LIB_BTN_WIDTH-25, COL3_X+25, LINE_02_Y,   "Center Position",  function() whoaCharacterStats_centerPosition(); end)
whoaLibrary_createButton(WHOA_LIB_BTN_WIDTH-25, COL3_X+25, LINE_03_Y,   "Default Position", function() whoaCharacterStats_defaultPosition(); end)
whoaLibrary_createButton(WHOA_LIB_BTN_WIDTH-25, COL3_X+25, LINE_06_Y,   "Default Scaling",  function() whoaCharacterStats_defaultScale(); end)
whoaLibrary_createButton(WHOA_LIB_BTN_WIDTH-25, COL3_X+25, BOTTOM_LINE, "Default Settings", function()
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
whoaLibrary_createCheckButton(addonName.."SwitchColumnsCb", COL1_X+20, LINE_04_Y, "Switch Columns", "Switch the values in the left and the right column.", settings.switch,     function(self, value) whoaCharacterStats_drawColumns(value); end)
whoaLibrary_createCheckButton(addonName.."ShowBorderCb",    COL1_X+20, LINE_05_Y, "Show Border",    "Show a border.",                                      settings.showBorder, function(self, value) whoaCharacterStats_showBorder(value); whoaCharacterStats_update(); end)
whoaLibrary_createCheckButton(addonName.."HighlightCb",     COL1_X+20, LINE_06_Y, "Highlighting",   "Highlight increasing, or decreasing stats.",          settings.highlight,  function(self, value) settings.highlight = value; end)

---------------------------------------------------
-- DROPDOWNS
---------------------------------------------------
whoaLibrary_createDropDown(addonName.."AnchorDropDown",        ANCHORS,  COL1_X, LINE_01_Y, "Anchor",             function() return settings.a1;           end, function(value) settings.a1           = value; end, function() whoaCharacterStats_updatePosition(); end)
whoaLibrary_createDropDown(addonName.."ParentDropDown",        PARENTS,  COL1_X, LINE_02_Y, "Parent",             function() return settings.p;            end, function(value) settings.p            = value; end, function() whoaCharacterStats_updatePosition(); end)
whoaLibrary_createDropDown(addonName.."AnchorParentDropDown",  ANCHORS,  COL1_X, LINE_03_Y, "Anchor Parent",      function() return settings.a2;           end, function(value) settings.a2           = value; end, function() whoaCharacterStats_updatePosition(); end)
whoaLibrary_createDropDown(addonName.."DecimalPlacesDropDown", DECIMALS, COL2_X, LINE_04_Y, "Decimal Places",     function() return settings.dp;           end, function(value) settings.dp           = value; end, function() whoaCharacterStats_update(); end)
whoaLibrary_createDropDown(addonName.."FirstDropDown",         STATS,    COL1_X, LINE_07_Y, "1st secondary stat", function() return settings.order["1st"]; end, function(value) settings.order["1st"] = value; end, function() whoaCharacterStats_drawColumns(); end)
whoaLibrary_createDropDown(addonName.."SecondDropDown",        STATS,    COL1_X, LINE_08_Y, "2nd secondary stat", function() return settings.order["2nd"]; end, function(value) settings.order["2nd"] = value; end, function() whoaCharacterStats_drawColumns(); end)
whoaLibrary_createDropDown(addonName.."ThirdDropDown",         STATS,    COL1_X, LINE_09_Y, "3rd secondary stat", function() return settings.order["3rd"]; end, function(value) settings.order["3rd"] = value; end, function() whoaCharacterStats_drawColumns(); end)
whoaLibrary_createDropDown(addonName.."FourthDropDown",        STATS,    COL1_X, LINE_10_Y, "4th secondary stat", function() return settings.order["4th"]; end, function(value) settings.order["4th"] = value; end, function() whoaCharacterStats_drawColumns(); end)

---------------------------------------------------
-- SLIDER
---------------------------------------------------
whoaLibrary_createSlider(addonName.."XSlider",       "x",       false, COL2_X, LINE_01_Y+2, -200, 200, function(value) whoaCharacterStats_updatePosition(value, nil); end)
whoaLibrary_createSlider(addonName.."YSlider",       "y",       false, COL2_X, LINE_02_Y+2, -200, 200, function(value) whoaCharacterStats_updatePosition(nil, value); end)
whoaLibrary_createSlider(addonName.."ScalingSlider", "Scaling", true,  COL2_X, LINE_06_Y,     .5,   3, function(value) whoaCharacterStats_setScale(value); end)

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
    whoaCharacterStatsScalingSlider:SetValue(settings.scale)
    whoaCharacterStatsAnchorDropDownText:SetText(settings.a1)
    whoaCharacterStatsParentDropDownText:SetText(settings.p)
    whoaCharacterStatsAnchorParentDropDownText:SetText(settings.a2)
    whoaCharacterStatsXSlider:SetValue(settings.x)
    whoaCharacterStatsYSlider:SetValue(settings.y)
    whoaCharacterStatsSwitchColumnsCb:SetChecked(settings.switch)
    whoaCharacterStatsShowBorderCb:SetChecked(settings.showBorder)
    whoaCharacterStatsHighlightCb:SetChecked(settings.highlight)
    whoaCharacterStatsDecimalPlacesDropDownText:SetText(settings.dp)
    whoaCharacterStatsFirstDropDownText:SetText(settings.order["1st"])
    whoaCharacterStatsSecondDropDownText:SetText(settings.order["2nd"])
    whoaCharacterStatsThirdDropDownText:SetText(settings.order["3rd"])
    whoaCharacterStatsFourthDropDownText:SetText(settings.order["4th"])
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
