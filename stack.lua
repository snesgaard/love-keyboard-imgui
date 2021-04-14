local stack = {}
stack.__index = stack

function stack.create()
    return setmetatable({}, stack)
end

function stack:push(item)
    table.insert(self, item)
    return self
end

function stack:pop()
    local e = self:peek()
    table.remove(self, #self)
    return e
end

function stack:is_empty()
    return #self <= 0
end

function stack:peek()
    return self[#self]
end

return stack
