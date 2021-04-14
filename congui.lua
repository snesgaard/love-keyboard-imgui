local layout = require "layout"
local button = require "button"
local stack = require "stack"
local theme = require "theme"

local congui = {}
congui.__index = congui

function congui.create(events, init_theme, init_layout)
    local this = setmetatable(
        {
            layout = init_layout or layout.create(),
            events = events or {},
            theme = init_theme or theme(),
            __focus = {},
            __shapes = {},
            __args = {},
            __children = {},
            __elements = {},
            __stack = stack.create()
        },
        congui
    )

    this.__children[this] = {}
    this.__stack:push(this)
    return this
end

function congui:children(id) return self.__children[id] end

function congui:has_focus(id) return self.__focus[id] end

function congui:give_focus(id)
    self.__focus[id] = true
    return self
end

function congui:release_focus(id)
    self.__focus[id] = false
    return self
end

function congui:shape(id) return self.__shapes[id] end

function congui:set_shape(id, shape) self.__shapes[id] = shape end

function congui:args(id) return unpack(self.__args[id]) end

function congui:set_args(id, ...) self.__args[id] = {...} end

function congui:set_events(events)
    self.events = events
end

function congui:element(id) return self.__elements[id] end

function congui:parent() return self.__stack[#self.__stack - 1] end

function congui:handle_events(id)
    local element = self:element(id)

    if not element then return end

    local function call_event(key, ...)
        local f = element[key]
        if f then return f(self, id, ...) end
    end

    local to_remove = {}

    for index, event in ipairs(self.events) do
        if call_event(unpack(event)) then table.insert(to_remove, index) end
    end

    for i = #to_remove, 1, -1 do
        local index = to_remove[i]
        table.remove(self.events, index)
    end
end


function congui:create_element(element, ...)
    local id = {}
    self.__args[id] = {...}
    self.__elements[id] = element
    self.__children[id] = {}
    return id
end

function congui:enter(element, ...)
    local id = self:create_element(element, ...)
    local parent = self.__stack:peek()

    self.__stack:push(id)

    local pen = self.__children[parent]
    table.insert(pen, id)


    local parent_type = parent ~=self and self.__elements[parent] or self

    if parent_type and parent_type.add_element then parent_type.add_element(self, parent, id, #pen) end

    if element.enter then return element.enter(self, id) end
end

function congui:add_element(_, id)
    self:give_focus(id)
end

function congui:exit(...)
    local id = self.__stack:peek()
    local element = self:element(id)
    local ret = nil

    self:handle_events(id)

    local pen = self.__children[id]

    if element.exit then ret = element.exit(self, id, pen, ...) end

    self.__stack:pop()

    return ret
end

function congui:draw(x, y, ...)
    x = x or 0
    y = y or 0

    local function recursive_draw(parent)
        local e = self.__elements[parent]

        if e and e.draw then
            e.draw(self, parent, x, y)
        end

        local pen = self.__children[parent]

        if not pen then return end

        for _, child in ipairs(pen) do recursive_draw(child) end
    end

    gfx.push()
    gfx.translate(x, y)
    recursive_draw(self)
    gfx.pop()
end

function congui:widget(...)
    self:enter(...)
    return self:exit()
end

function congui:button(...)
    local id = self:enter(button, ...)
    return self:exit()
end

function congui:slider(...)
    local slider = require "slider"
    local id = self:enter(slider, ...)
    return self:exit()
end

function congui:checkbox(...)
    local checkbox = require "checkbox"
    local id = self:enter(checkbox, ...)
    return self:exit()
end

return congui
