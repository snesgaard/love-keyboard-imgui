local box = {}

function box.enter(core, id)
    local opt, shape = core:args(id)

    if shape then core:set_shape(id, shape) end
end

function box.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end
    local shape = core:shape(id)
    id.pressed = not shape:is_outside(x, y)
end

function box.exit(core, id)
    return id.pressed
end

function box.draw(core, id)
    local opt = core:args(id)
    local shape = core:shape(id)

    local color = opt.color or {1, 1, 1}

    if opt.selected then
        if color[3] < 0.5 then
            gfx.setColor(1, 1, 1)
        else
            gfx.setColor(0.4, 0.4, 0.2)
        end
        gfx.rectangle("fill", shape:unpack())
        gfx.setColor(hsv(unpack(color)))
        gfx.rectangle("fill", shape:expand(-6, -6):unpack())
    else
        gfx.setColor(hsv(unpack(color)))
        gfx.rectangle("fill", shape:unpack())
    end
end

return box
