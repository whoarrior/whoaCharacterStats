local config = whoaCharacterStats.config
local _, class = UnitClass("player")

local COLOR_RED  = "ff0000"
local COLOR_GOLD = "ffd700"
local INT = "Int"
local STR = "Strength"
local AGI = "Agi"

---------------------------------------------------
-- LOCAL LIBRARY
---------------------------------------------------
local base, posBuff, negBuff = 0
local ap = 0
local sp = 0
local function getAttackPower()
    base, posBuff, negBuff = UnitAttackPower("player")
    ap = base + posBuff + negBuff
    return "|cffffffff"..ap.."|r"
end

local function round(n, dp)
    return math.floor((n * 10^dp) + .5) / (10^dp)
end

local function formatNr(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)')
    return left..(num:reverse():gsub('(%d%d%d)', '%1'.."."):reverse())..right
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
    local versatilty = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    return "|cffffffff"..round(versatilty, config.dp).."|r%"
end

-- # Mastery
local function getMastery()
    local mastery = GetMasteryEffect()
    return "|cffffffff"..round(mastery, config.dp).."|r%"
end

-- # Crit
local function getCrit()
    -- local specId = GetSpecialization()
    -- return "|cffffffff"..round(CLASSES[class][specId]["crit"], config.dp).."|r%"
    return "|cffffffff"..round(GetCritChance(), config.dp).."|r%"
end

-- # Haste
local function getHaste()
    local specId = GetSpecialization()
    if CLASSES[class][specId]["haste"] == CR_HASTE_SPELL
    or CLASSES[class][specId]["haste"] == CR_HASTE_RANGED
    then
        return "|cffffffff"..round(GetRangedHaste(), config.dp).."|r%"
    else
        return "|cffffffff"..round(GetMeleeHaste(), config.dp).."|r%"
    end
end

-- # Power
local function getPower()
    local specId = GetSpecialization()
    local v = CLASSES[class][specId]["power"]
    if v == 1 then
        return formatNr(getAttackPower())
    else
        return formatNr(GetSpellBonusDamage(v))
    end
end
local function getMainStat()
    local specId = GetSpecialization()
    return CLASSES[class][specId]["stat"]
end

---------------------------------------------------
-- TEXT
---------------------------------------------------
local function createFrame(spec, parent, point, xOffset, yOffset, width, alignment)
    local f = CreateFrame("Frame", spec, parent)
    f:SetPoint(point, parent, point, xOffset, yOffset)
    f:SetWidth(width)
    f:SetHeight(20)
    f:SetScale(config.scale)
    f.text = f:CreateFontString(spec.."text", "OVERLAY")
    f.text:SetAllPoints(f)
    f.text:SetFontObject(TextStatusBarText)
    f.text:SetJustifyH(alignment)
end

-- # config
local col1 = config.col1
local col2 = config.col2
local txt1 = config.txt1
local txt2 = config.txt2
local lh = config.lh
local p = config.position.p
local a = config.position.a
local x = config.position.x
local y = config.position.y
local function getY(v)
    local n = config.order[v]
    if n == 1 then
        return 3*lh+y
    elseif n == 2 then
        return 2*lh+y
    elseif n == 3 then
        return 1*lh+y
    elseif n == 4 then
        return y
    else
        print("|cff"..COLOR_GOLD.."[ whoa|rCharacterStats |cff"..COLOR_GOLD.."] configuration fail:|r config.order."..v.." = |cff"..COLOR_RED..config.order[v].."|r")
        return y
    end
end
local statValue, hasteValue, critValue, masteryValue, versatilityValue, statText, hasteText, critText, masteryText, versatilityText
createFrame("whoaCharacterStats_col1Mainstat",    p, a, x, 4.4*lh+y,            col1, txt1); createFrame("whoaCharacterStats_col2Mainstat",    whoaCharacterStats_col1Mainstat,    "LEFT", col1+3, 0, col2, txt2)
createFrame("whoaCharacterStats_col1Haste",       p, a, x, getY("Haste"),       col1, txt1); createFrame("whoaCharacterStats_col2Haste",       whoaCharacterStats_col1Haste,       "LEFT", col1+3, 0, col2, txt2)
createFrame("whoaCharacterStats_col1Mastery",     p, a, x, getY("Mastery"),     col1, txt1); createFrame("whoaCharacterStats_col2Mastery",     whoaCharacterStats_col1Mastery,     "LEFT", col1+3, 0, col2, txt2)
createFrame("whoaCharacterStats_col1Crit",        p, a, x, getY("Crit"),        col1, txt1); createFrame("whoaCharacterStats_col2Crit",        whoaCharacterStats_col1Crit,        "LEFT", col1+3, 0, col2, txt2)
createFrame("whoaCharacterStats_col1Versatility", p, a, x, getY("Versatility"), col1, txt1); createFrame("whoaCharacterStats_col2Versatility", whoaCharacterStats_col1Versatility, "LEFT", col1+3, 0, col2, txt2)
if config.stats == "left" then
    statValue = whoaCharacterStats_col1Mainstat
    hasteValue = whoaCharacterStats_col1Haste
    masteryValue = whoaCharacterStats_col1Mastery
    critValue = whoaCharacterStats_col1Crit
    versatilityValue = whoaCharacterStats_col1Versatility
    statText = whoaCharacterStats_col2Mainstat
    hasteText = whoaCharacterStats_col2Haste
    masteryText = whoaCharacterStats_col2Mastery
    critText = whoaCharacterStats_col2Crit
    versatilityText = whoaCharacterStats_col2Versatility
else
    statValue = whoaCharacterStats_col2Mainstat
    hasteValue = whoaCharacterStats_col2Haste
    masteryValue = whoaCharacterStats_col2Mastery
    critValue = whoaCharacterStats_col2Crit
    versatilityValue = whoaCharacterStats_col2Versatility
    statText = whoaCharacterStats_col1Mainstat
    hasteText = whoaCharacterStats_col1Haste
    masteryText = whoaCharacterStats_col1Mastery
    critText = whoaCharacterStats_col1Crit
    versatilityText = whoaCharacterStats_col1Versatility
end
hasteText.text:SetText("Haste")
masteryText.text:SetText("Mastery")
critText.text:SetText("Crit")
versatilityText.text:SetText("Versatility")

local function update()
    statText.text:SetText(getMainStat())
    statValue.text:SetText(getPower())
    hasteValue.text:SetText(getHaste())
    masteryValue.text:SetText(getMastery())
    critValue.text:SetText(getCrit())
    versatilityValue.text:SetText(getVersatility())
end

---------------------------------------------------
-- EVENTS
---------------------------------------------------
local w = CreateFrame("Frame", nil, UIParent)
w:RegisterEvent("PLAYER_LOGIN")
w:RegisterEvent("UNIT_AURA")
function w:OnEvent(event)
    if event == "PLAYER_LOGIN" then
        SlashCmdList['RELOAD'] = function() ReloadUI() end
        SLASH_RELOAD1 = '/rl'
        update()
    elseif event == "UNIT_AURA" then
        update()
    end
end
w:SetScript("OnEvent", w.OnEvent)
