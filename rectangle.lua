local math = require "math"

local rectangle = {}
rectangle.__index = rectangle

function rectangle.__tostring(rec)
    return string.format("[x=%f, y=%f, w=%f h=%f]", rec.x, rec.y, rec.w, rec.h)
end

function rectangle.create(x, y, w, h)
    local this = {x=x or 0, y=y or 0, w=w or 0, h=h or 0}
    return setmetatable(this, rectangle)
end

function rectangle:move(dx, dy)
    dx = dx or 0
    dy = dy or 0
    return rectangle.create(self.x + dx, self.y + dy, self.w, self.h)
end

function rectangle:up(w, h)
    w = w or self.w
    h = h or self.h
    return rectangle.create(self.x, self.y - h, w, h)
end

function rectangle:right(w, h)
    w = w or self.w
    h = h or self.h
    return rectangle.create(self.x + self.w, self.y, w, h)
end

function rectangle:left(w, h)
    w = w or self.w
    h = h or self.h
    return rectangle.create(self.x - w, self.y, w, h)
end

function rectangle:down(w, h)
    w = w or self.w
    h = h or self.h
    return rectangle.create(self.x, self.y + self.h, w, h)
end

function rectangle:center()
    return self.x + self.w / 2, self.y + self.h / 2
end

function rectangle:is_outside(x, y)
    return x < self.x or self.x + self.w < x or y < self.y or self.y + self.h < y
end

function rectangle:expand(dw, dh, align, valign)
    dw = dw or 0
    dh = dh or 0

    local function dx()
        if align == "left" then
            return 0
        elseif align == "right" then
            return -dw
        else
            return -dw * 0.5
        end
    end

    local function dy()
        if valign == "top" then
            return 0
        elseif valign == "bottom" then
            return -dh
        else
            return -dh * 0.5
        end
    end

    return rectangle.create(
        self.x + dx(), self.y + dy(), self.w + dw, self.h + dh
    )
end

function rectangle:unpack()
    return self.x, self.y, self.w, self.h
end

function rectangle:shape(w, h)
    return rectangle.create(self.x, self.y, w or self.w, h or self.h)
end

function rectangle:uv(x, y)
    return (x - self.x) / self.w, (y - self.y) / self.h
end

function rectangle:print()
    return self
end

function rectangle.join(rects)
    if #rects == 0 then return nil end

    local r = rectangle.create()

    local function agg(a, b, ...)
        if not b then return a end

        local x0 = math.min(a.x, b.x)
        local x1 = math.max(a.x + a.w, b.x + b.w)
        local y0 = math.min(a.y, b.y)
        local y1 = math.max(a.y + a.h, b.y + b.h)
        local next = rectangle.create(x0, y0, x1 - x0, y1 - y0)

        return agg(next, ...)
    end

    return agg(unpack(rects))
end

return rectangle
