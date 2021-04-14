local canvas = gfx.newCanvas(1, 1)

local shader_code = [[

uniform float hue;
uniform float value;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    return vec4(hsv2rgb(vec3(hue, texture_coords.x, value)), 1.0);
}

]]

local shader = gfx.newShader(shader_code)

local slider = {}

function slider.enter(core, id)
    local opt, state, shape = core:args(id)
    if shape then core:set_shape(id, shape) end
    id.saturation = opt.saturation
end

function slider.update_saturation(core, id, x, y)
    local shape = core:shape(id)
    local opt, state = core:args(id)
    local u = shape:uv(x, y)
    id.saturation = math.min(1.0, math.max(u, 0.0))
end

function slider.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end
    local shape = core:shape(id)
    if shape:is_outside(x, y) then return end

    local opt, state = core:args(id)
    state.dragging = true
    slider.update_saturation(core, id, x, y)
end

function slider.mousemoved(core, id, x, y)
    local opt, state = core:args(id)

    if not state.dragging then return end

    slider.update_saturation(core, id, x, y)
end

function slider.mousereleased(core, id, x, y, button)
    if button ~= 1 then return end
    local opt, state = core:args(id)
    if not state.dragging then return end

    state.dragging = false
    slider.update_saturation(core, id, x, y)
end

function slider.exit(core, id)
    return id.saturation
end

function slider.draw(core, id)
    local opt, state = core:args(id)
    local shape = core:shape(id)

    local hue = opt.hue or 0
    local value = opt.value or 0.5

    gfx.push("all")
    gfx.setColor(0.75, 0.75, 0.75)
    gfx.rectangle("fill", shape:expand(2, 2):unpack())
    gfx.setShader(shader)
    shader:send("hue", hue)
    shader:send("value", value)
    gfx.draw(canvas, shape.x, shape.y, 0, shape.w, shape.h)

    local v = value > 0.5 and 0 or 1
    gfx.setShader()
    gfx.setColor(v, v, v)
    gfx.circle(
        "line",
        lerp(shape.x, shape.x + shape.w, id.saturation or 0),
        shape.y + shape.h * 0.5,
        shape.h * 0.25
    )

    gfx.pop()
end

return slider
