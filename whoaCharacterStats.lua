---------------------------------------------------
-- CHECK EXTERNAL LIBRARIES
---------------------------------------------------
if not WHOA_LIB_LOGGING_LOADED then print("|cffff0000ERROR:|r whoaLibrary |cffffd700logging.lua|r was not loaded!"); return end
if not WHOA_LIB_COLORS_LOADED  then print("|cffff0000ERROR:|r whoaLibrary |cffffd700colors.lua|r was not loaded!");  return end

---------------------------------------------------
-- CONSTANTS & VARIABLES
---------------------------------------------------
local ADDON = ADDON_NAME
local defaults = whoaCharacterStats.defaults
local _, class = UnitClass("player")
local stat, crit, haste, mastery, versatility = 0
local statValue, hasteValue, critValue, masteryValue, versatilityValue, statText, hasteText, critText, masteryText, versatilityText

local INT         = "Int"
local STR         = "Strength"
local AGI         = "Agi"
local HASTE       = "Haste"
local MASTERY     = "Mastery"
local CRIT        = "Crit"
local VERSATILITY = "Versatility"

---------------------------------------------------
-- LOCAL LIBRARY
---------------------------------------------------
local base, posBuff, negBuff = 0
local ap = 0
local sp = 0
local function getAttackPower()
    base, posBuff, negBuff = UnitAttackPower("player")
    ap = base + posBuff + negBuff
    return ap
end

---------------------------------------------------
-- STATS
--   1 for Physical
--   2 for Holy
--   3 for Fire
--   4 for Nature
--   5 for Frost
--   6 for Shadow
--   7 for Arcane
---------------------------------------------------
local CLASSES = {
    PRIEST = {
        [1] = { spec = "DISCIPLINE",   stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 2, }, -- # Holy
        [2] = { spec = "HOLY",         stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 2, }, -- # Holy
        [3] = { spec = "SHADOW",       stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 6, }, -- # Shadow
    },
    MAGE = {
        [1] = { spec = "ARCANE",       stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 7, }, -- # Arcane
        [2] = { spec = "FIRE",         stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 3, }, -- # Fire
        [3] = { spec = "FROST",        stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 5, }, -- # Frost
    },
    WARLOCK = {
        [1] = { spec = "AFFLICTION",   stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 6, }, -- # Shadow
        [2] = { spec = "DEMONOLOGY",   stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 6, }, -- # Shadow
        [3] = { spec = "DESTRUCTION",  stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 3, }, -- # Fire
    },
    MONK = {
        [1] = { spec = "BREWMASTER",   stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "MISTWEAVER",   stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 4, }, -- # Nature
        [3] = { spec = "WINDWALKER",   stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    DRUID = {
        [1] = { spec = "BALANCE",      stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 4, }, -- # Nature (Arcane?)
        [2] = { spec = "FERAL",        stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [3] = { spec = "GUARDIAN",     stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [4] = { spec = "RESTORATION",  stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 4, }, -- # Nature
    },
    ROGUE = {
        [1] = { spec = "ASSASINATION", stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "OUTLAW",       stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [3] = { spec = "SUBTLETY",     stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    DEMONHUNTER = {
        [1] = { spec = "HAVOC",        stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "VENGEANCE",    stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    SHAMAN = {
        [1] = { spec = "ELEMENTAL",    stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 4, }, -- # Nature (Arcane?)
        [2] = { spec = "ENHANCEMENT",  stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [3] = { spec = "RESTORATION",  stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 4, }, -- # Nature
    },
    HUNTER = {
        [1] = { spec = "BEASTMASTERY", stat = AGI, crit = CR_CRIT_RANGED, haste = CR_HASTE_RANGED, power = 1, },
        [2] = { spec = "MARKSMANSHIP", stat = AGI, crit = CR_CRIT_RANGED, haste = CR_HASTE_RANGED, power = 1, },
        [3] = { spec = "SURVIVAL",     stat = AGI, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    PALADIN = {
        [1] = { spec = "PROTECTION",   stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "HOLY",         stat = INT, crit = CR_CRIT_SPELL,  haste = CR_HASTE_SPELL,  power = 2, }, -- # Holy
        [3] = { spec = "RETRIBUTION",  stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    DEATHKNIGHT = {
        [1] = { spec = "BLOOD",        stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "FROST",        stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [3] = { spec = "UNHOLY",       stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
    WARRIOR = {
        [1] = { spec = "ARMS",         stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [2] = { spec = "FURY",         stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
        [3] = { spec = "PROTECTION",   stat = STR, crit = CR_CRIT_MELEE,  haste = CR_HASTE_MELEE,  power = 1, },
    },
}

-- # Versatilty
local function getVersatility()
    return GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
end
local function getVersatilityText()
    local color = WHOA_LIB_COLOR_WHITE
    local v = getVersatility()
    if settings.highlight then
        if versatility < v then color = WHOA_LIB_COLOR_GREEN; whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Versatility:|r "..versatility.." |cff"..WHOA_LIB_COLOR_GREEN.."<|r "..v, "DEBUG", LOG_LEVEL, ADDON) end
        if versatility > v then color = WHOA_LIB_COLOR_RED;   whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Versatility:|r "..versatility.." |cff"..WHOA_LIB_COLOR_RED..">|r "..v,   "DEBUG", LOG_LEVEL, ADDON) end
    end
    versatilityText.text:SetText("|cff"..color..VERSATILITY.."|r")
    return "|cff"..color..whoaRound(v, settings.dp).."%|r"
end

-- # Mastery
local function getMastery()
    return GetMasteryEffect()
end
local function getMasteryText()
    local color = WHOA_LIB_COLOR_WHITE
    local m = getMastery()
    if settings.highlight then
        if mastery < m then color = WHOA_LIB_COLOR_GREEN; whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Mastery:|r "..mastery.." |cff"..WHOA_LIB_COLOR_GREEN.."<|r "..m, "DEBUG", LOG_LEVEL, ADDON) end
        if mastery > m then color = WHOA_LIB_COLOR_RED;   whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Mastery:|r "..mastery.." |cff"..WHOA_LIB_COLOR_RED..">|r "..m,   "DEBUG", LOG_LEVEL, ADDON) end
    end
    masteryText.text:SetText("|cff"..color..MASTERY.."|r")
    return "|cff"..color..whoaRound(m, settings.dp).."%|r"
end

-- # Crit
local function getCrit()
    -- local specId = GetSpecialization()
    -- return CLASSES[class][specId]["crit"]
    return GetCritChance()
end
local function getCritText()
    local color = WHOA_LIB_COLOR_WHITE
    local c = getCrit()
    if settings.highlight then
        if crit < c then color = WHOA_LIB_COLOR_GREEN; whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Crit:|r "..crit.." |cff"..WHOA_LIB_COLOR_GREEN.."<|r "..c, "DEBUG", LOG_LEVEL, ADDON) end
        if crit > c then color = WHOA_LIB_COLOR_RED;   whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Crit:|r "..crit.." |cff"..WHOA_LIB_COLOR_RED..">|r "..c,   "DEBUG", LOG_LEVEL, ADDON) end
    end
    critText.text:SetText("|cff"..color..CRIT.."|r")
    return "|cff"..color..whoaRound(c, settings.dp).."%|r"
end

-- # Haste
local function getHaste()
    local specId = GetSpecialization()
    if CLASSES[class][specId]["haste"] == CR_HASTE_SPELL
    or CLASSES[class][specId]["haste"] == CR_HASTE_RANGED
    then
        return GetRangedHaste()
    else
        return GetMeleeHaste()
    end
end
local function getHasteText()
    local color = WHOA_LIB_COLOR_WHITE
    local h = getHaste()
    if settings.highlight then
        if haste < h then color = WHOA_LIB_COLOR_GREEN; whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Haste:|r "..haste.." |cff"..WHOA_LIB_COLOR_GREEN.."<|r "..h, "DEBUG", LOG_LEVEL, ADDON) end
        if haste > h then color = WHOA_LIB_COLOR_RED;   whoaLog("|cff"..WHOA_LIB_COLOR_GOLD.."Haste:|r "..haste.." |cff"..WHOA_LIB_COLOR_RED..">|r "..h,   "DEBUG", LOG_LEVEL, ADDON) end
    end
    hasteText.text:SetText("|cff"..color..HASTE.."|r")
    return "|cff"..color..whoaRound(h, settings.dp).."%|r"
end

-- # MainStat
local function getMainStat()
    local specId = GetSpecialization()
    return CLASSES[class][specId]["stat"]
end
local function getPower()
    local specId = GetSpecialization()
    local v = CLASSES[class][specId]["power"]
    if v == 1 then
        return getAttackPower()
    else
        return GetSpellBonusDamage(v)
    end
end
local function getPowerText()
    local color = WHOA_LIB_COLOR_WHITE
    local p = getPower()
    if settings.highlight then
        if stat < p then color = WHOA_LIB_COLOR_GREEN; whoaLog("|cff"..WHOA_LIB_COLOR_GOLD..getMainStat()..":|r "..stat.." |cff"..WHOA_LIB_COLOR_GREEN.."<|r "..p, "DEBUG", LOG_LEVEL, ADDON) end
        if stat > p then color = WHOA_LIB_COLOR_RED;   whoaLog("|cff"..WHOA_LIB_COLOR_GOLD..getMainStat()..":|r "..stat.." |cff"..WHOA_LIB_COLOR_RED..">|r "..p,   "DEBUG", LOG_LEVEL, ADDON) end
    end
    statText.text:SetText("|cff"..color..getMainStat().."|r")
    return "|cff"..color..whoaFormatNr(p).."|r"
end

---------------------------------------------------
-- TEXT
---------------------------------------------------
local function createMainFrame(spec, parent, point, xOffset, yOffset, width, height)
    local f = CreateFrame("Frame", spec, parent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetPoint("BOTTOMLEFT", parent, point, xOffset, yOffset)
    f:SetWidth(width)
    f:SetHeight(height)
    f:SetScale(defaults.scale)
    return f
end
local function createFrame(spec, parent, xOffset, yOffset, width, alignment)
    local f = CreateFrame("Frame", spec, parent)
    f:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xOffset, yOffset)
    f:SetWidth(width)
    f:SetHeight(20)
    f.text = f:CreateFontString(spec.."text", "OVERLAY")
    f.text:SetAllPoints(f)
    f.text:SetFontObject(TextStatusBarText)
    f.text:SetJustifyH(alignment)
end

-- # config
local col1 = defaults.left.col1
local col2 = defaults.left.col2
local txt1 = defaults.left.txt1
local txt2 = defaults.left.txt2
local padding = defaults.left.padding
local lh = defaults.lh
local a = defaults.position.a
local x = defaults.position.x
local y = defaults.position.y
local function getY(value)
    local o = ""
    if settings.order == nil then
        settings.order = defaults.order
    end
    for k, v in pairs(settings.order) do
        if v == value then
            o = k
        end
    end
    if o == "1st" then
        return 3*lh+4
    elseif o == "2nd" then
        return 2*lh+4
    elseif o == "3rd" then
        return 1*lh+4
    elseif o == "4th" then
        return 4
    else
        whoaLog("configuration fail:|r", "WARN", LOG_LEVEL, ADDON)
        whoaLog("|r1st "..settings.order["1st"]..", 2nd "..settings.order["2nd"]..", 3rd "..settings.order["3rd"]..", 4th "..settings.order["4th"], "WARN", LOG_LEVEL, ADDON)
        whoaLog("|r|cff"..WHOA_LIB_COLOR_RED..value.."|r is not configured!", "WARN", LOG_LEVEL, ADDON)
        return 4
    end
end

createMainFrame("w", _G[defaults.position.p], a, x, y, col1+col2+padding, 4.4*lh+24)
y = 4.4*lh;              createFrame("whoaCharacterStats_col1Mainstat",    w, 0, y, col1, txt1); createFrame("whoaCharacterStats_col2Mainstat",    w, col1+padding, y, col2, txt2)
y = getY("Haste");       createFrame("whoaCharacterStats_col1Haste",       w, 0, y, col1, txt1); createFrame("whoaCharacterStats_col2Haste",       w, col1+padding, y, col2, txt2)
y = getY("Mastery");     createFrame("whoaCharacterStats_col1Mastery",     w, 0, y, col1, txt1); createFrame("whoaCharacterStats_col2Mastery",     w, col1+padding, y, col2, txt2)
y = getY("Crit");        createFrame("whoaCharacterStats_col1Crit",        w, 0, y, col1, txt1); createFrame("whoaCharacterStats_col2Crit",        w, col1+padding, y, col2, txt2)
y = getY("Versatility"); createFrame("whoaCharacterStats_col1Versatility", w, 0, y, col1, txt1); createFrame("whoaCharacterStats_col2Versatility", w, col1+padding, y, col2, txt2)

local function setColumns(v)
    if (v == nil) then
        settings.switch = defaults.switch
    else
        settings.switch = v
    end
    
    if settings.switch then
        col1 = defaults.right.col1  -- # column width
        col2 = defaults.right.col2  -- # column width
        txt1 = defaults.right.txt1  -- # text alignment column 1
        txt2 = defaults.right.txt2  -- # text alignment column 2
        padding = defaults.right.padding
        y = 4.4*lh;              statValue = whoaCharacterStats_col2Mainstat;           statValue:SetWidth(col2);        statValue.text:SetJustifyH(txt1);        statValue:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
                                 statText = whoaCharacterStats_col1Mainstat;            statText:SetWidth(col1);         statText.text:SetJustifyH(txt2);         statText:SetPoint(        "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
        y = getY("Haste");       hasteValue = whoaCharacterStats_col2Haste;             hasteValue:SetWidth(col2);       hasteValue.text:SetJustifyH(txt1);       hasteValue:SetPoint(      "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
                                 hasteText = whoaCharacterStats_col1Haste;              hasteText:SetWidth(col1);        hasteText.text:SetJustifyH(txt2);        hasteText:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
        y = getY("Mastery");     masteryValue = whoaCharacterStats_col2Mastery;         masteryValue:SetWidth(col2);     masteryValue.text:SetJustifyH(txt1);     masteryValue:SetPoint(    "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
                                 masteryText = whoaCharacterStats_col1Mastery;          masteryText:SetWidth(col1);      masteryText.text:SetJustifyH(txt2);      masteryText:SetPoint(     "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
        y = getY("Crit");        critValue = whoaCharacterStats_col2Crit;               critValue:SetWidth(col2);        critValue.text:SetJustifyH(txt1);        critValue:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
                                 critText = whoaCharacterStats_col1Crit;                critText:SetWidth(col1);         critText.text:SetJustifyH(txt2);         critText:SetPoint(        "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
        y = getY("Versatility"); versatilityValue = whoaCharacterStats_col2Versatility; versatilityValue:SetWidth(col2); versatilityValue.text:SetJustifyH(txt1); versatilityValue:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
                                 versatilityText = whoaCharacterStats_col1Versatility;  versatilityText:SetWidth(col1);  versatilityText.text:SetJustifyH(txt2);  versatilityText:SetPoint( "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
    else
        col1 = defaults.left.col1  -- # column width
        col2 = defaults.left.col2  -- # column width
        txt1 = defaults.left.txt1  -- # text alignment column 1
        txt2 = defaults.left.txt2  -- # text alignment column 2
        padding = defaults.left.padding
        y = 4.4*lh;              statValue = whoaCharacterStats_col1Mainstat;           statValue:SetWidth(col1);        statValue.text:SetJustifyH(txt1);        statValue:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
                                 statText = whoaCharacterStats_col2Mainstat;            statText:SetWidth(col2);         statText.text:SetJustifyH(txt2);         statText:SetPoint(        "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
        y = getY("Haste");       hasteValue = whoaCharacterStats_col1Haste;             hasteValue:SetWidth(col1);       hasteValue.text:SetJustifyH(txt1);       hasteValue:SetPoint(      "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
                                 hasteText = whoaCharacterStats_col2Haste;              hasteText:SetWidth(col2);        hasteText.text:SetJustifyH(txt2);        hasteText:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
        y = getY("Mastery");     masteryValue = whoaCharacterStats_col1Mastery;         masteryValue:SetWidth(col1);     masteryValue.text:SetJustifyH(txt1);     masteryValue:SetPoint(    "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
                                 masteryText = whoaCharacterStats_col2Mastery;          masteryText:SetWidth(col2);      masteryText.text:SetJustifyH(txt2);      masteryText:SetPoint(     "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
        y = getY("Crit");        critValue = whoaCharacterStats_col1Crit;               critValue:SetWidth(col1);        critValue.text:SetJustifyH(txt1);        critValue:SetPoint(       "BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
                                 critText = whoaCharacterStats_col2Crit;                critText:SetWidth(col2);         critText.text:SetJustifyH(txt2);         critText:SetPoint(        "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
        y = getY("Versatility"); versatilityValue = whoaCharacterStats_col1Versatility; versatilityValue:SetWidth(col1); versatilityValue.text:SetJustifyH(txt1); versatilityValue:SetPoint("BOTTOMLEFT", w, "BOTTOMLEFT",            0, y)
                                 versatilityText = whoaCharacterStats_col2Versatility;  versatilityText:SetWidth(col2);  versatilityText.text:SetJustifyH(txt2);  versatilityText:SetPoint( "BOTTOMLEFT", w, "BOTTOMLEFT", col1+padding, y)
    end
end

function whoaCharacterStats_update()
    statText.text:SetText(getMainStat())
    statValue.text:SetText(getPowerText())
    hasteValue.text:SetText(getHasteText())
    masteryValue.text:SetText(getMasteryText())
    critValue.text:SetText(getCritText())
    versatilityValue.text:SetText(getVersatilityText())
end

---------------------------------------------------
-- ADDON KEYBINDING FUNCTIONS
---------------------------------------------------
function whoaCharacterStats_initStats()
    stat = getPower()
    haste = getHaste()
    mastery = getMastery()
    crit = getCrit()
    versatility = getVersatility()
    whoaCharacterStats_update()
end

---------------------------------------------------
-- SETTINGS FUNCTIONS
---------------------------------------------------
function whoaCharacterStats_setScale(v)
    if v == nil and settings.scale == nil then
        w:SetScale(defaults.scale)
    elseif v == nil then
        w:SetScale(settings.scale)
    else
        settings.scale = v
        w:SetScale(v)
    end
end
function whoaCharacterStats_defaultScale() 
    whoaCharacterStats_setScale(defaults.scale)
    whoaCharacterStats_updateOptionPanel()
end

local function showBorder(v)
    if (v == nil and settings.showBorder == nil and defaults.showBorder)
    or (v == nil and settings.showBorder)
    or (v)
    then
        -- w:SetBackdrop(BACKDROP_SLIDER_8_8)
        w:SetBackdrop(BACKDROP_TEXT_PANEL_0_16)
        -- w:SetBackdrop(BACKDROP_TOOLTIP_0_12_0055)
    else
        w:SetBackdrop()
    end
end
function whoaCharacterStats_showBorder(v)
    if (v ~= nil) then
        settings.showBorder = v
    end
    showBorder(v)
end

function whoaCharacterStats_drawColumns(v)
    if (v ~= nil) then
        settings.switch = v
    end
    setColumns(v)
    whoaCharacterStats_update()
end

function whoaCharacterStats_defaultPosition()
    w:ClearAllPoints()
    settings.position.a1 = defaults.position.a1
    settings.position.p  = defaults.position.p
    settings.position.a2 = defaults.position.a2
    settings.position.x  = defaults.position.x
    settings.position.y  = defaults.position.y
    w:SetPoint(settings.position.a1, settings.position.p, settings.position.a2, settings.position.x, settings.position.y)
    whoaCharacterStats_updateOptionPanel()
end

function whoaCharacterStats_centerPosition()
    w:ClearAllPoints()
    settings.position.a1 = "CENTER"
    settings.position.p  = "UIParent"
    settings.position.a2 = "CENTER"
    settings.position.x  = 0
    settings.position.y  = 0
    w:SetPoint(settings.position.a1, settings.position.p, settings.position.a2, settings.position.x, settings.position.y)
    whoaCharacterStats_updateOptionPanel()
end

function whoaCharacterStats_updatePosition(x, y)
    if (x ~= nil and y ~= nil) then
        settings.position.x = x
        settings.position.y = y
    elseif (x ~= nil and y == nil) then
        settings.position.x = x
    elseif (x == nil and y ~= nil) then
        settings.position.y = y
    end
    w:ClearAllPoints()
    w:SetPoint(settings.position.a1, settings.position.p, settings.position.a2, settings.position.x, settings.position.y)
end

local function init()
    settings = whoaCharacterStats_getSettings()
    w:ClearAllPoints()
    w:SetPoint(settings.position.a1, settings.position.p, settings.position.a2, settings.position.x, settings.position.y)
    showBorder(settings.showBorder)
    setColumns(settings.switch)
end

---------------------------------------------------
-- EVENTS
---------------------------------------------------
--local w = CreateFrame("Frame", nil, UIParent)
w:RegisterEvent("PLAYER_LOGIN")
w:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
w:RegisterEvent("UNIT_AURA")
-- w:RegisterEvent("ADDON_LOADED")
w:RegisterEvent("VARIABLES_LOADED")
function w:OnEvent(event, ...)
    if event == "PLAYER_LOGIN" then
        whoaLog("PLAYER_LOGIN", "DEBUG", LOG_LEVEL, ADDON)
        SlashCmdList['RELOAD'] = function() ReloadUI() end
        SLASH_RELOAD1 = '/rl'
        SlashCmdList['INIT'] = function() whoaCharacterStats_initStats() end
        SLASH_INIT1 = '/i'
        whoaCharacterStats_initStats()
    -- elseif event == "ADDON_LOADED" then
    --     local addonName = ...
    --     whoaLog("ADDON_LOADED:"..addonName, "DEBUG", LOG_LEVEL, ADDON)
    --     if addonName == "whoaCharacterStats" then
    --         w:UnregisterEvent("ADDON_LOADED")
    --     end
    elseif event == "VARIABLES_LOADED" then
        whoaLog("VARIABLES_LOADED", "DEBUG", LOG_LEVEL, ADDON)
        init()
        whoaCharacterStats_updateOptionPanel()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        whoaLog("PLAYER_EQUIPMENT_CHANGED", "DEBUG", LOG_LEVEL, ADDON)
        whoaCharacterStats_initStats()
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            whoaLog("UNIT_AURA", "DEBUG", LOG_LEVEL, ADDON)
            whoaCharacterStats_update()
        end
    end
end
w:SetScript("OnEvent", w.OnEvent)

---------------------------------------------------
-- ONUPDATE TIMER
---------------------------------------------------
local timer = 0
local init = true

local function onUpdate(self, elapsed)
    if init then
        timer = timer + elapsed
        -- # init after 1sec delay
        if timer >= 1 then
            whoaCharacterStats_initStats()
            init = false
        end
    end
end
w:SetScript("OnUpdate", onUpdate)
