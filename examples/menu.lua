local button = require "button"
local rectangle = require "rectangle"
local menu = require "menu"
local congui = require "congui"
local slider = require "slider"
local theme = require "theme"
local checkbox = require "checkbox"

local function do_gui(events, states, spec_theme)
    states = states or {
        menu = {menu.init_state(), menu.init_state(), menu.init_state()},
        slider = {
            slider.init_state(0, 100, 50),
            slider.init_state(0, 100, 50),
            slider.init_state(0, 100, 50),
            slider.init_state(0, 100, 50),
            slider.init_state(0, 100, 50),
            slider.init_state(0, 100, 50),
        },
        checkbox = checkbox.init_state()
    }

    local button_opt = {font=gfx.newFont(18), border=3}
    local checkbox_opt = {font=gfx.newFont(18), border=3, align="left"}
    local menu_opt = {element_shape={200, 30}, max_visible=6}
    local slider_opt = {line_width=4, marker_radius=8}

    local gui = congui.create(events, theme(spec_theme))
    local base = gui.layout:get()

    gui:enter(menu, states.menu[3], menu_opt)
        gui:button("Attack", button_opt)
        gui:button("Skill", button_opt)

        if gui:enter(button, "Sliders", button_opt) then
            gui.layout:push()
            gui.layout:set(base:move(menu.right(gui, menu_opt)))
            gui.layout:right(nil, 0)
            gui:enter(menu, states.menu[2], menu_opt)
                gui:slider(states.slider[1], {})
                gui:slider(states.slider[2], {})
                gui:slider(states.slider[3], {})
            gui:exit()
            gui.layout:pop()
        end
        gui:exit()

        gui:checkbox("Consistency", checkbox_opt, states.checkbox)
        gui:button("Items1", button_opt)
        gui:button("Items2", button_opt)
        gui:button("Items3", button_opt)
        gui:button("Items4", button_opt)
        gui:button("Items5", button_opt)
    gui:exit()

    return gui, states
end

return do_gui
