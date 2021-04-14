local button = {}

function button.enter(core, id)
    local opt, shape = core:args(id)

    if shape then core:set_args(id, shape) end
end

function button.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end
    local shape = core:shape(id)
    if shape:is_outside(x, y) then return end
    id.active = true
end

function button.exit(core, id)
    return id.active
end

function button.draw()

end

return button
