local button = require "button"
local rectangle = require "rectangle"
local text_format = require "text"

local checkbox = {}

function checkbox.init_state()
    return {activated=false}
end

function checkbox.enter(core, id)
    if core:has_focus(id) then
        local _, _, state = core:args(id)
        state.activated = not state.activated
        core:release_focus(id)
    end
end

function checkbox.exit()

end

function checkbox.draw(core, id)
    local shape = core:shape(id)
    local text, opt, state = core:args(id)
    opt = opt or {}

    local marker_size = opt.marker_size or {10, 10}

    if not shape then return end

    local inner_shape = button.draw_frame(
        shape, core.theme, opt.border
    )
    gfx.setColor(core.theme.color.text)
    local text_shape = inner_shape:expand(-12, 0)
    text_format.draw(text, opt.font, text_shape, opt)
    local marker_shape = checkbox.marker_shape(text_shape, unpack(marker_size))

    if state.activated then
        local c = core.theme.color.text
        gfx.setColor(c[1], c[2], c[3], (c[4] or 1) * 0.5)
        gfx.rectangle("fill", marker_shape:unpack())
    end
    gfx.setColor(core.theme.color.text)
    gfx.rectangle("line", marker_shape:unpack())
end

function checkbox.marker_shape(base_shape, w, h)
    return base_shape:expand(w - base_shape.w, h - base_shape.h, "right")
end

function checkbox.keypressed(core, id, key)
    if not core:has_focus(id) then return end

    if key == "space" then
        local _, _, state = core:args(id)
    end
end

return checkbox
