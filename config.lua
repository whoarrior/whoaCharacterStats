whoaCharacterStats = {}
-- # example with value on the left column
-- whoaCharacterStats.config = {
--     stats = "left", -- # stats on the left or right column
--     col1 = 40,      -- # column width
--     col2 = 80,      -- # column width
--     txt1 = "RIGHT", -- # text alignment column 1
--     txt2 = "LEFT",  -- # text alignment column 2
--     lh = 12,        -- # line height
--     dp = 0,         -- # decimal places
--     scale = 1.0,    -- # scaling
--     padding = 3,    -- # padding between columns
--     order = {
--         ["Haste"]       = 2,
--         ["Mastery"]     = 3,
--         ["Crit"]        = 1,
--         ["Versatility"] = 4,
--     },
--     position = {
--         p = PlayerFrame,
--         a = "TOPRIGHT",
--         x = 40,
--         y = 26,
--     },
-- }

-- # example with value on the right column
whoaCharacterStats.config = {
    stats = "right", -- # stats on the left or right column
    col1 = 80,       -- # column width
    col2 = 35,       -- # column width
    txt1 = "RIGHT",  -- # text alignment column 1
    txt2 = "RIGHT",  -- # text alignment column 2
    lh = 12,         -- # line height
    dp = 0,          -- # decimal places
    scale = 1.2,     -- # scaling
    padding = -15,   -- # padding between columns
    order = {
        ["Haste"]       = 2,
        ["Mastery"]     = 3,
        ["Crit"]        = 1,
        ["Versatility"] = 4,
    },
    position = {
        p = PlayerFrame,
        a = "TOPRIGHT",
        x = 60,
        y = 26,
    },
}
