local button = require "button"
local layout = require "layout"
local stack = require "stack"

local imgui =  {}
imgui.__index = imgui

function imgui.create(init_layout, events)
    local this = setmetatable(
        {
            layout = init_layout or layout.create(),
            events = events or {},
            __selected = nil,
            __shapes = {},
            __args = {},
            __children = {},
            __elements = {}
        },
        imgui
    )

    this.__children[this] = {}
    return this
end

function imgui:is_selected(id) return self.__selected == id end

function imgui:select(id) self.__selected = id end

function imgui:set_shape(id, shape) self.__shapes[id] = shape end

function imgui:shape(id) return self.__shapes[id] end

function imgui:set_args(id, ...) self.__args[id] = {...} end

function imgui:args(id)
    local a = self.__args[id]
    if a then return unpack(a) end
end

function imgui:set_events(events)
    self.events = events
    return self
end

function imgui:add_child(parent, child)
    local pen = self.__children[parent]
    if not pen then
        pen = {}
        self.__children[parent] = pen
    end
    table.insert(pen, child)
end

function imgui:create_element(element, ...)
    local id = {}
    self.__args[id] = {...}
    self.__children[id] = {}
    self.__elements[id] = element
    return id
end

function imgui:enter(container, ...)
    local id = self:add_element(container, ...)
    self:handle_events(c)
    self.__container_stack:push(c)
end

function imgui:handle_events(container)
    local function call_event(key, ...)
        local f = container[key]
        if f then return f(container, ...) end
    end

    local to_remove = {}

    for index, event in ipairs(self.events) do
        if call_event(unpack(event)) then table.insert(to_remove, index) end
    end
end

function imgui:add_element(element)
    local c = self.__container_stack:peek()

    if c then
        self:add_child(c, element)
        if c.add_element then
            local pen = self.__children[c]
            return c:add_element(self, element, #pen)
        end
    else
        self:add_child(self, element)
    end
end

function imgui:button(...)
    local id = self:create_element(button, ...)
    button.enter(self, id)
    table.insert(self.__children[self], id)
    return button.exit(self, id)
end

function imgui:exit()
    local c = self.__container_stack:pop()

    if not c then return end

    if c.exit then
        local children = self.__children[c] or {}
        local drawers, layout = c:exit(self, children)

        if layout then self.layout:set(layout) end
    end
end

function imgui:draw(x, y, ...)
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

    return recursive_draw(self)
end

return imgui
