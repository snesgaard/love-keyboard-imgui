local ramp_sphere = {}

function ramp_sphere.default_ramp()
    local ramp = {
        {208, 10, 36},
        {190, 16, 40},
        {182, 19, 59},
        {180, 13, 74},
        {180, 14, 83},
    }

    for index, color in ipairs(ramp) do
        ramp[index] = normalize_hsv(color)
    end

    return ramp
end

local function sub_circle(cx, cy, r, s)
    local rn = r * s
    local dr = r - rn
    local aspect = 1.0 - (1 - s) * 0.2
    local rx = rn
    local ry = rn * aspect
    local dx = 1.0
    local dy = 1.0
    local l = math.sqrt(dx * dx + dy * dy)
    dx = dr * dx / l * lerp(0.6, 1.04, s)
    dy = dr * dy / l * 1.0
    return cx - dx, cy - dy, rx, ry
end

local function sin_radius(index, max)
    local s = 1.0 - (index) / (max + 1.0)
    s = math.sin(s * math.pi * 0.5)
    return s
end

local function exp_radius(index, max)
    return math.exp(-(index - 1) * 0.2)
end

function ramp_sphere.enter(core, id, ...)
    local opt, shape = core:args(id)
    if shape then core:set_shape(id, shape) end
end

function ramp_sphere.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end
    local shape = core:shape(id)
    id.pressed = not shape:is_outside(x, y)
end

function ramp_sphere.exit(core, id)
    return id.pressed
end

function ramp_sphere.draw(core, id)
    local opt = core:args(id)
    local shape = core:shape(id)
    local r = shape.w * 0.5
    local cx, cy = shape:center()
    local tx, ty, tw, th = shape:unpack()

    local ramp = opt.ramp or ramp_sphere.default_ramp()
    if opt.selected then
        gfx.setColor(0.8, 0.4, 0.2)
        gfx.rectangle("fill", shape:unpack())
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", shape:expand(-4, -4):unpack())
    else
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", shape:unpack())
    end

    for index, color in ipairs(ramp) do
        gfx.setColor(hsv(unpack(color)))
        local s = sin_radius(index, #ramp)
        local t = (1 - s)
        local x = lerp(cx, tx + tw * 0.25, t)
        local y = lerp(cy, ty + th * 0.15, t)
        local a = 1.0
        local dy = 0
        if index > 1 and index ~= #ramp then
            a = 0.9
            dy = r * s * (1 - a) * 0.8
        end
        gfx.ellipse("fill", x, y - dy, r * s, r * s * a)
    end

    local s = sin_radius(#ramp, #ramp)
    local t = (1 - s)
    local x = lerp(cx, tx + tw * 0.25, t * 1.15)
    local y = lerp(cy, ty + th * 0.15, t * 1.15)
    local r = r * s * 0.2
    gfx.setColor(1, 1, 1)
    gfx.circle("fill", x, y, r)
end

return ramp_sphere
