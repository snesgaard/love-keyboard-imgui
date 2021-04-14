local rectangle = require "rectangle"
local stack = require "stack"

local layout = {}
layout.__index = layout

function layout.create(init_rectangle)
    local this = {
        __rectangle_stack = stack.create(),
        __current_rectangle = init_rectangle or rectangle.create()
    }
    return setmetatable(this, layout)
end

for _, dir in ipairs{"up", "down", "left", "right", "move", "shape"} do
    local f = rectangle[dir]

    layout[dir] = function(self, ...)
        local r = f(self.__current_rectangle, ...)
        self.__current_rectangle = r
        return self
    end
end

function layout:push()
    self.__rectangle_stack:push(self.__current_rectangle)
    return self
end

function layout:pop()
    local next_r = self.__rectangle_stack:pop()
    if next_r then self.__current_rectangle = next_r end
    return self
end

function layout:set(r)
    self.__current_rectangle = r
    return self
end

function layout:get()
    return self.__current_rectangle
end

function layout:print()
    return self
end

return layout
