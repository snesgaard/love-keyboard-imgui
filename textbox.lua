local textbox = {}

function textbox.is_numerical(key)
    return string.match(key, '[0-9]')
end

function textbox.enter(core, id)
    local opt, state, shape = core:args(id)

    if shape then core:set_shape(id, shape) end
end

function textbox.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end

    local shape = core:shape(id)

    local opt, state = core:args(id)

    if shape:is_outside(x, y) then
        state.active = false
    else
        state.active = true
    end
end

function textbox.keypressed(core, id, key)
    if not core:has_focus(id) then return end

    local opt, state = core:args(id)

    if opt.filter and not opt.filter(key) then return end
end

function textbox.draw()
    local shape = core:shape(id)

    gfx.setColor(1, 1, 1)
    gfx.rectangle("fill", shape:unpack())
end


return textbox
