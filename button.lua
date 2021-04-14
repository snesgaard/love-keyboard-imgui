local BASE = (...):match('(.-)[^%.]+$')

local rectangle = require(BASE .. "rectangle").create
local text_format = require(BASE .. "text")

local button = {}
button.__index = button

function button.enter(core, id)
    local text, opt, shape = core:args(id)
    if shape then core:set_shape(id, shape) end

    return core:has_focus(id)
end

function button.add_element(core, id, element)
    if core:has_focus(id) then core:give_focus(element) end
end

function button.draw_frame(shape, theme, border, select)
    local inner_shape = border and shape:expand(-border * 2, -border * 2) or shape

    gfx.push("all")
    gfx.stencil(
        function()
            if select then
                gfx.setColor(theme.color.select)
            else
                gfx.setColor(theme.color.front)
            end
            gfx.setColorMask(true, true, true, true)
            gfx.rectangle("fill", inner_shape.x, inner_shape.y, inner_shape.w, inner_shape.h)
        end,
        "replace", 1
    )
    gfx.setStencilTest("equal", 0)
    gfx.setColor(theme.color.middle)
    gfx.rectangle("fill", shape.x, shape.y, shape.w, shape.h)
    gfx.pop()

    return inner_shape
end

function button.draw(core, id)
    local shape = core:shape(id)

    if not shape then return end

    local text, opt = core:args(id)

    opt = opt or {}
    local font = opt.font or gfx.getFont()
    local inner_shape = opt.border and shape:expand(-opt.border * 2, -opt.border * 2) or shape
    local dy = text_format.vertical_align_offset(opt.valign, font, inner_shape.h)

    gfx.push("all")
    gfx.setFont(font)
    gfx.stencil(
        function()
            if core:has_focus(id) then
                gfx.setColor(core.theme.color.select)
            else
                gfx.setColor(core.theme.color.front)
            end
            gfx.setColorMask(true, true, true, true)
            gfx.rectangle("fill", inner_shape.x, inner_shape.y, inner_shape.w, inner_shape.h)
            gfx.setColor(core.theme.color.text)
            gfx.printf(text, inner_shape.x, inner_shape.y + dy, inner_shape.w, opt.align or "center")
        end, "replace", 1
    )
    gfx.setStencilTest("equal", 0)
    gfx.setColor(core.theme.color.middle)
    gfx.rectangle("fill", shape.x, shape.y, shape.w, shape.h)

    gfx.pop()
end

function button.keypressed(core, id)
    if key == "space" and core:has_focus(id) then
        id.active = true
    end
end

function button.exit(core, id)
    local _, opt = core:args(id)

    return core:has_focus(id)
end

return button
