local rectangle = require "rectangle"
local lume = require "lume"
local timer = require "timer"

local menu = {}

function menu.init_state(index)
    return {index=index, key_repeater={}}
end

function menu.slider_shape(inner_border, slider_width, slider_margin)
    slider_width = slider_width or 4
    slider_margin = slider_margin or slider_width * 2
    return inner_border:right(slider_width):move(slider_margin, 0)
end

function menu.draw_slider(slider_shape, view, max_visible, num_elements, theme)
    local inner_ratio = max_visible / num_elements
    local inner_height = math.ceil(slider_shape.h * inner_ratio)
    local start_pos = slider_shape.y
    local end_pos = slider_shape.y + slider_shape.h - inner_height

    local s = (view - 1) / (num_elements - max_visible)

    gfx.setColor(theme.color.middle)
    gfx.rectangle("fill", slider_shape:unpack())
    gfx.setColor(theme.color.front)
    gfx.rectangle(
        "fill", slider_shape.x, start_pos * (1 - s) + end_pos * s, slider_shape.w, inner_height
    )
end

function menu.right(core, opt)
    local margin = opt.element_margin or core.theme.margin.menu_element
    local width = opt.element_shape and opt.element_shape[1] or 0
    return width + margin
end

function menu.should_draw_slider(state, opt, num_elements)
    if not opt.max_visible then return false end
    return opt.max_visible < num_elements
end

function menu.enter(core, id)
    local state, opt = core:args(id)

    state.view = state.view or 1

    if state.index and opt.max_visible then
        if state.index <= state.view then
            state.view = state.index
        elseif state.index > state.view + opt.max_visible - 1 then
            state.view = state.index - opt.max_visible + 1
        end
    end

    local border = opt.border or core.theme.margin.menu_border

    local element_margin = opt.element_margin or core.theme.margin.menu_element

    core.layout
        :move(border, border - element_margin)
        :down(0, 0)
end

function menu.in_view(state, opt, index)
    if not opt.max_visible then return true end

    return state.view <= index and index < state.view + opt.max_visible
end

function menu.keypressed(core, id, key)
    if not core:has_focus(id) then return end

    local state, opt = core:args(id)

    if key == "backspace" and state.select then
        state.select = false
        return true
    end

    if state.select then return end

    if key == "up" then
        if state.index then
            state.index = state.index - 1
        else
            state.index = 0
        end
        state.key_repeater[key] = timer.period(0.3, menu.keypressed, core, id, key)
        return true
    elseif key == "down" then
        if state.index then
            state.index = state.index + 1
        else
            state.index = 1
        end
        state.key_repeater[key] = timer.period(0.3, menu.keypressed, core, id, key)
        return true
    elseif state.index and key == "space" then
        state.select = true
        return true
    end
end

function menu.keyreleased(core, id, key)
    local state, opt = core:args(id)

    state.key_repeater[key] = nil
end

function menu.add_element(core, id, element, index)
    local state, opt = core:args(id)
    local in_view = menu.in_view(state, opt, index)

    if state.select and state.index == index then
        id.selected = index
        core:give_focus(element)
    end

    local element_margin = opt.element_margin or core.theme.margin.menu_element

    if in_view then
        core.layout
            :down(opt.element_shape[1], opt.element_shape[2])
            :move(0, element_margin)
        core:set_shape(element, core.layout:get())
    end

    return is_select
end

function menu.draw(core, id, x, y)
    local state, opt = core:args(id)
    local shape = core:shape(id)
    local pen = core:children(id)
    if not shape then return end


    gfx.setColor(core.theme.color.back)
    gfx.rectangle("fill", shape:unpack())

    local slider_shape = id.slider

    if slider_shape then
        menu.draw_slider(slider_shape, state.view, opt.max_visible, #pen, core.theme)
    end

    local index = state.index
    if not index or not core:has_focus(id) then return end

    local child = pen[index]

    if not child then return end

    local shape = core:shape(child)

    if not shape then return end

    if state.select then
        gfx.setColor(core.theme.color.select)
    else
        gfx.setColor(core.theme.color.hover)
    end

    gfx.rectangle("fill", shape:expand(4, 4):unpack())
end

function menu.update(core, id, dt)
    local state, opt = core:args(id)

    for _, kp in pairs(state.key_repeater) do kp:update(dt) end
end

function menu.exit(core, id, elements)
    local state, opt = core:args(id)

    local index = state.index
    if index then
        if index < 1 then
            index = index + #elements
        elseif index > #elements then
            index = index - #elements
        end
        state.index = index
    end

    local tabs = {}
    for _, e in ipairs(elements) do
        local s = core:shape(e)
        if s then table.insert(tabs, s) end
    end

    local inner_border = rectangle.join(tabs)
    local border = opt.border or core.theme.margin.menu_border

    local slider = menu.should_draw_slider(state, opt, #elements) and menu.slider_shape(inner_border) or nil
    local shape = rectangle.join{inner_border, slider}:expand(border * 2, border * 2)
    id.slider = slider
    core:set_shape(id, shape)
    core.layout:set(shape)

    if id.selected then
        local e = elements[id.selected]
        if e and not core:has_focus(e) then
            state.select = nil
        end
    end
end

return menu
