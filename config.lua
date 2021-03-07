-- # Loglevel
LOG_LEVEL = WHOA_LIB_LOGLEVEL_CHARSTATS

-- # bindings
ADDON_NAME = "|cff"..WHOA_LIB_COLOR_ADDON.."whoa|r CharacterStats"
BINDING_HEADER_WHOA_CHARACTERSTATS = ADDON_NAME
BINDING_NAME_WHOA_CHARACTERSTATS_INIT = "Initialize your stats before a fight"

-- # default values
whoaCharacterStats = {}
whoaCharacterStats.defaults = {
    switch = false,
    showBorder = false,
    highlight = true,
    lh = 12,
    dp = 0,
    scale = 1,
    left = {
        col1 = 46,      -- # column width
        col2 = 64,      -- # column width
        txt1 = "RIGHT", -- # text alignment column 1
        txt2 = "LEFT",  -- # text alignment column 2
        padding = 3,
    },
    right = {
        col1 = 64,      -- # column width
        col2 = 46,      -- # column width
        txt1 = "RIGHT", -- # text alignment column 1
        txt2 = "RIGHT", -- # text alignment column 2
        padding = -3,
    },
    order = {
        ["1st"] = "Haste",
        ["2nd"] = "Versatility",
        ["3rd"] = "Mastery",
        ["4th"] = "Crit",
    },
    position = {
        a1 = "BOTTOMLEFT",
        p  = "PlayerFrame",  -- # UIParent
        a2 = "TOPRIGHT",
        x  = 0,
        y  = 0,
    },
}
