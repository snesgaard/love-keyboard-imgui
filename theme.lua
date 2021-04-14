local theme = {}

theme.__default = {
    color = {
        text = {0, 0, 0},
        back = {0.25, 0.25, 0.25},
        middle = {0.5, 0.5, 0.5},
        front = {1, 1, 1},
        hover = {0.8, 0.9, 0.2, 1},
        select = {0.3, 0.9, 0.2, 1}
    },
    margin = {
        menu_element = 5,
        menu_border = 6
    },
    font = {}
}

local function assignment(src, dst)
    if not src then return end

    for key, val in pairs(src) do
        dst[key] = dst[key] or val
    end
end

function theme:__call(spefication)
    spefication = spefication or {}

    local this = {
        color = {},
        margin = {},
        font = {}
    }

    for category, dst in pairs(this) do
        assignment(spefication[category], dst)
        assignment(theme.__default[category], dst)
    end

    return this
end

return setmetatable(theme, theme)
