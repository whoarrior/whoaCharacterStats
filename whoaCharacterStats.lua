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
    return "|cffffffff"..round(versatilty, 2).."|r%"
end

-- # Mastery
local function getMastery()
    local mastery = GetMasteryEffect()
    return "|cffffffff"..round(mastery, 2).."|r%"
end

-- # Crit
local function getCrit()
    -- local specId = GetSpecialization()
    -- return "|cffffffff"..round(CLASSES[class][specId]["crit"], 2).."|r%"
    return "|cffffffff"..round(GetCritChance(), 2).."|r%"
end

-- # Haste
local function getHaste()
    local specId = GetSpecialization()
    if CLASSES[class][specId]["haste"] == CR_HASTE_SPELL
    or CLASSES[class][specId]["haste"] == CR_HASTE_RANGED
    then
        return "|cffffffff"..round(GetRangedHaste(), 2).."|r%"
    else
        return "|cffffffff"..round(GetMeleeHaste(), 2).."|r%"
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
    f.text = f:CreateFontString(spec.."text", "OVERLAY")
    f.text:SetAllPoints(f)
    f.text:SetFontObject(TextStatusBarText)
    f.text:SetJustifyH(alignment)
end

-- # config
local col1 = config.col1
local col2 = config.col2
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
createFrame("whoaCharacterStats_valMainstat",    p, a, x, 4.4*lh+y,            col1, "RIGHT"); createFrame("whoaCharacterStats_txtMainstat",    whoaCharacterStats_valMainstat,    "LEFT", col1+3, 0, col2, "LEFT")
createFrame("whoaCharacterStats_valHaste",       p, a, x, getY("Haste"),       col1, "RIGHT"); createFrame("whoaCharacterStats_txtHaste",       whoaCharacterStats_valHaste,       "LEFT", col1+3, 0, col2, "LEFT")
createFrame("whoaCharacterStats_valMastery",     p, a, x, getY("Mastery"),     col1, "RIGHT"); createFrame("whoaCharacterStats_txtMastery",     whoaCharacterStats_valMastery,     "LEFT", col1+3, 0, col2, "LEFT")
createFrame("whoaCharacterStats_valCrit",        p, a, x, getY("Crit"),        col1, "RIGHT"); createFrame("whoaCharacterStats_txtCrit",        whoaCharacterStats_valCrit,        "LEFT", col1+3, 0, col2, "LEFT")
createFrame("whoaCharacterStats_valVersatility", p, a, x, getY("Versatility"), col1, "RIGHT"); createFrame("whoaCharacterStats_txtVersatility", whoaCharacterStats_valVersatility, "LEFT", col1+3, 0, col2, "LEFT")
whoaCharacterStats_txtHaste.text:SetText("Haste")
whoaCharacterStats_txtMastery.text:SetText("Mastery")
whoaCharacterStats_txtCrit.text:SetText("Crit")
whoaCharacterStats_txtVersatility.text:SetText("Versatility")

local function update()
    whoaCharacterStats_txtMainstat.text:SetText(getMainStat())
    whoaCharacterStats_valMainstat.text:SetText(getPower())
    whoaCharacterStats_valHaste.text:SetText(getHaste())
    whoaCharacterStats_valMastery.text:SetText(getMastery())
    whoaCharacterStats_valCrit.text:SetText(getCrit())
    whoaCharacterStats_valVersatility.text:SetText(getVersatility())
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
