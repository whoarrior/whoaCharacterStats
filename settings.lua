local addonName, addon = ...

settings = {}
charSettings = {}

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

-- # Getter
local function getBorder()    if charSettings.enabled then return charSettings.showBorder else return settings.showBorder end end
local function getHighlight() if charSettings.enabled then return charSettings.highlight  else return settings.highlight  end end
local function getSwitch()    if charSettings.enabled then return charSettings.switch     else return settings.switch     end end
---------------------------------------------------
-- CHECKBOXES
---------------------------------------------------
whoaLibrary_createCheckButton(addonName.."CharSpecificCb",  COL3_X,          -10, "Character Specific Settings", "Click this to toggle between global settings and settings specific to this character.", charSettings.enabled, function(self, v) whoaCharacterStats_charSpecificSettings(v); whoaCharacterStats_updatePosition(); whoaCharacterStats_update(); whoaCharacterStats_updateOptionPanel() end)
whoaLibrary_createCheckButton(addonName.."SwitchColumnsCb", COL1_X+20, LINE_04_Y, "Switch Columns",              "Switch the values in the left and the right column.",                                   getSwitch(),          function(self, v) whoaCharacterStats_drawColumns(v) end)
whoaLibrary_createCheckButton(addonName.."ShowBorderCb",    COL1_X+20, LINE_05_Y, "Show Border",                 "Show a border.",                                                                        getBorder(),          function(self, v) whoaCharacterStats_showBorder(v); whoaCharacterStats_update() end)
whoaLibrary_createCheckButton(addonName.."HighlightCb",     COL1_X+20, LINE_06_Y, "Highlighting",                "Highlight increasing, or decreasing stats.",                                            getHighlight(),       function(self, v) if charSettings.enabled then charSettings.highlight = v else settings.highlight = v end end)

---------------------------------------------------
-- DROPDOWNS
---------------------------------------------------
whoaLibrary_createDropDown(addonName.."AnchorDropDown",        ANCHORS,  COL1_X, LINE_01_Y, "Anchor",             function() if charSettings.enabled then return charSettings.a1           else return settings.a1           end end, function(v) if charSettings.enabled then charSettings.a1           = v else settings.a1           = v end end, function() whoaCharacterStats_updatePosition() end)
whoaLibrary_createDropDown(addonName.."ParentDropDown",        PARENTS,  COL1_X, LINE_02_Y, "Parent",             function() if charSettings.enabled then return charSettings.p            else return settings.p            end end, function(v) if charSettings.enabled then charSettings.p            = v else settings.p            = v end end, function() whoaCharacterStats_updatePosition() end)
whoaLibrary_createDropDown(addonName.."AnchorParentDropDown",  ANCHORS,  COL1_X, LINE_03_Y, "Anchor Parent",      function() if charSettings.enabled then return charSettings.a2           else return settings.a2           end end, function(v) if charSettings.enabled then charSettings.a2           = v else settings.a2           = v end end, function() whoaCharacterStats_updatePosition() end)
whoaLibrary_createDropDown(addonName.."DecimalPlacesDropDown", DECIMALS, COL2_X, LINE_04_Y, "Decimal Places",     function() if charSettings.enabled then return charSettings.dp           else return settings.dp           end end, function(v) if charSettings.enabled then charSettings.dp           = v else settings.dp           = v end end, function() whoaCharacterStats_update() end)
whoaLibrary_createDropDown(addonName.."FirstDropDown",         STATS,    COL1_X, LINE_07_Y, "1st secondary stat", function() if charSettings.enabled then return charSettings.order["1st"] else return settings.order["1st"] end end, function(v) if charSettings.enabled then charSettings.order["1st"] = v else settings.order["1st"] = v end end, function() whoaCharacterStats_drawColumns() end)
whoaLibrary_createDropDown(addonName.."SecondDropDown",        STATS,    COL1_X, LINE_08_Y, "2nd secondary stat", function() if charSettings.enabled then return charSettings.order["2nd"] else return settings.order["2nd"] end end, function(v) if charSettings.enabled then charSettings.order["2nd"] = v else settings.order["2nd"] = v end end, function() whoaCharacterStats_drawColumns() end)
whoaLibrary_createDropDown(addonName.."ThirdDropDown",         STATS,    COL1_X, LINE_09_Y, "3rd secondary stat", function() if charSettings.enabled then return charSettings.order["3rd"] else return settings.order["3rd"] end end, function(v) if charSettings.enabled then charSettings.order["3rd"] = v else settings.order["3rd"] = v end end, function() whoaCharacterStats_drawColumns() end)
whoaLibrary_createDropDown(addonName.."FourthDropDown",        STATS,    COL1_X, LINE_10_Y, "4th secondary stat", function() if charSettings.enabled then return charSettings.order["4th"] else return settings.order["4th"] end end, function(v) if charSettings.enabled then charSettings.order["4th"] = v else settings.order["4th"] = v end end, function() whoaCharacterStats_drawColumns() end)

---------------------------------------------------
-- SLIDER
---------------------------------------------------
whoaLibrary_createSlider(addonName.."XSlider",       "x",       false, COL2_X, LINE_01_Y+2, -200, 200, function(v) whoaCharacterStats_updatePosition(v, nil) end)
whoaLibrary_createSlider(addonName.."YSlider",       "y",       false, COL2_X, LINE_02_Y+2, -200, 200, function(v) whoaCharacterStats_updatePosition(nil, v) end)
whoaLibrary_createSlider(addonName.."ScalingSlider", "Scaling", true,  COL2_X, LINE_06_Y,     .5,   3, function(v) whoaCharacterStats_setScale(v) end)

---------------------------------------------------

function whoaCharacterStats_setDefaults()
    if charSettings.enabled then
        charSettings.showBorder   = defaults.showBorder
        charSettings.highlight    = defaults.highlight
        charSettings.switch       = defaults.switch
        if charSettings.switch then
            charSettings.col1     = defaults.right.col1
            charSettings.col2     = defaults.right.col2
            charSettings.txt1     = defaults.right.txt1
            charSettings.txt2     = defaults.right.txt2
            charSettings.padding  = defaults.right.padding
        else
            charSettings.col1     = defaults.left.col1
            charSettings.col2     = defaults.left.col2
            charSettings.txt1     = defaults.left.txt1
            charSettings.txt2     = defaults.left.txt2
            charSettings.padding  = defaults.left.padding
        end
        charSettings.lh           = defaults.lh
        charSettings.dp           = defaults.dp
        charSettings.scale        = defaults.scale
        charSettings.order["1st"] = defaults.order["1st"]
        charSettings.order["2nd"] = defaults.order["2nd"]
        charSettings.order["3rd"] = defaults.order["3rd"]
        charSettings.order["4th"] = defaults.order["4th"]
        charSettings.a1           = defaults.position.a1
        charSettings.p            = defaults.position.p
        charSettings.a2           = defaults.position.a2
        charSettings.x            = defaults.position.x
        charSettings.y            = defaults.position.y
    else
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

function whoaCharacterStats_getCharSettings()
    if charSettings.enabled          == nil then charSettings.enabled      = false                  end
    if charSettings.showBorder       == nil then charSettings.showBorder   = defaults.showBorder    end
    if charSettings.highlight        == nil then charSettings.highlight    = defaults.highlight     end
    if charSettings.switch           == nil then
        charSettings.switch           = defaults.switch
        if charSettings.col1         == nil then charSettings.col1         = defaults.left.col1     end
        if charSettings.col2         == nil then charSettings.col2         = defaults.left.col2     end
        if charSettings.txt1         == nil then charSettings.txt1         = defaults.left.txt1     end
        if charSettings.txt2         == nil then charSettings.txt2         = defaults.left.txt2     end
        if charSettings.padding      == nil then charSettings.padding      = defaults.left.padding  end
    else
        if charSettings.col1         == nil then charSettings.col1         = defaults.right.col1    end
        if charSettings.col2         == nil then charSettings.col2         = defaults.right.col2    end
        if charSettings.txt1         == nil then charSettings.txt1         = defaults.right.txt1    end
        if charSettings.txt2         == nil then charSettings.txt2         = defaults.right.txt2    end
        if charSettings.padding      == nil then charSettings.padding      = defaults.right.padding end
    end
    if charSettings.lh               == nil then charSettings.lh           = defaults.lh            end
    if charSettings.dp               == nil then charSettings.dp           = defaults.dp            end
    if charSettings.scale            == nil then charSettings.scale        = defaults.scale         end
    if charSettings.a1               == nil then charSettings.a1           = defaults.position.a1   end
    if charSettings.p                == nil then charSettings.p            = defaults.position.p    end
    if charSettings.a2               == nil then charSettings.a2           = defaults.position.a2   end
    if charSettings.x                == nil then charSettings.x            = defaults.position.x    end
    if charSettings.y                == nil then charSettings.y            = defaults.position.y    end
    -- if charSettings.order            == nil then
    --     charSettings.order["1st"]     = defaults.order["1st"]
    --     charSettings.order["2nd"]     = defaults.order["2nd"]
    --     charSettings.order["3rd"]     = defaults.order["3rd"]
    --     charSettings.order["4th"]     = defaults.order["4th"]
    -- else
    --     if charSettings.order["1st"] == nil then charSettings.order["1st"] = defaults.order["1st"]  end
    --     if charSettings.order["2nd"] == nil then charSettings.order["2nd"] = defaults.order["2nd"]  end
    --     if charSettings.order["3rd"] == nil then charSettings.order["3rd"] = defaults.order["3rd"]  end
    --     if charSettings.order["4th"] == nil then charSettings.order["4th"] = defaults.order["4th"]  end
    -- end
    return charSettings
end

function whoaCharacterStats_updateOptionPanel()
    whoaCharacterStatsCharSpecificCb:SetChecked(charSettings.enabled)
    if charSettings.enabled then
        whoaCharacterStatsScalingSlider:SetValue(charSettings.scale)
        whoaCharacterStatsAnchorDropDownText:SetText(charSettings.a1)
        whoaCharacterStatsParentDropDownText:SetText(charSettings.p)
        whoaCharacterStatsAnchorParentDropDownText:SetText(charSettings.a2)
        whoaCharacterStatsXSlider:SetValue(charSettings.x)
        whoaCharacterStatsYSlider:SetValue(charSettings.y)
        whoaCharacterStatsSwitchColumnsCb:SetChecked(charSettings.switch)
        whoaCharacterStatsShowBorderCb:SetChecked(charSettings.showBorder)
        whoaCharacterStatsHighlightCb:SetChecked(charSettings.highlight)
        whoaCharacterStatsDecimalPlacesDropDownText:SetText(charSettings.dp)
        whoaCharacterStatsFirstDropDownText:SetText(charSettings.order["1st"])
        whoaCharacterStatsSecondDropDownText:SetText(charSettings.order["2nd"])
        whoaCharacterStatsThirdDropDownText:SetText(charSettings.order["3rd"])
        whoaCharacterStatsFourthDropDownText:SetText(charSettings.order["4th"])
    else
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
