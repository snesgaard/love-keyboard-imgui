local slider = {}

function slider.init_state(min, max, value)
    return {min=min, max=max, value=value or min}
end

function slider.enter(core, id)
    local state, opt, shape = core:args(id)

    if shape then core:set_shape(id, shape) end
end

function slider.keypressed(core, id, key)
    if not core:has_focus(id) then return end

    local state = core:args(id)

    if key == "left" then
        state.value = math.max(state.min, state.value - 10)
    end

    if key == "right" then
        state.value = math.min(state.max, state.value + 10)
    end
end

function slider.exit(core, id)

end

local function normalize(min, max, value)
    return (value - min) / (max - min)
end

local function lerp(min, max, s)
    return min * (1 - s) + max * s
end

function slider.draw(core, id, x, y)
    local state, opt = core:args(id)
    local border_shape = core:shape(id)

    if not border_shape then return end

    local line_width = opt.line_width or 4
    local radius = opt.marker_radius or line_width * 2
    local line_border = border_shape
        :expand(-radius * 2, line_width - border_shape.h)

    gfx.push()
    --gfx.translate(x, y)
    if core:has_focus(id) then
        gfx.setColor(core.theme.color.select)
    else
        gfx.setColor(core.theme.color.front)
    end
    gfx.rectangle("fill", border_shape:unpack())
    gfx.setColor(core.theme.color.text)
    gfx.rectangle("fill", line_border:unpack())

    gfx.setColor(core.theme.color.text)
    local dx = lerp(
        line_border.x, line_border.x + line_border.w,
        normalize(state.min, state.max, state.value)
    )
    local _, dy = border_shape:center()
    gfx.circle("fill", dx, dy, radius)

    gfx.pop()
end

return slider
