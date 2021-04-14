local canvas = gfx.newCanvas(1, 1)

local shader_code = [[

uniform float saturation;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    return vec4(hsv2rgb(vec3(texture_coords.x, saturation, 1.0 - texture_coords.y)), 1.0);
}

]]

local shader = gfx.newShader(shader_code)

local hv_picker = {}

function hv_picker.enter(core, id)
    local opt, state, shape = core:args(id)
    if shape then core:set_shape(id, shape) end
    id.hue = opt.hue
    id.value = opt.value
end

function hv_picker.update_hue_value(core, id, x, y)
    local shape = core:shape(id)
    local opt, state = core:args(id)
    local u, v = shape:uv(x, y)
    id.hue = math.max(0, math.min(u, 1.0))
    id.value = math.max(0, math.min(1 - v, 1.0))
    return opt, state
end

function hv_picker.mousepressed(core, id, x, y, button)
    if button ~= 1 then return end

    local shape = core:shape(id)

    if shape:is_outside(x, y) then return end

    local opt, state = hv_picker.update_hue_value(core, id, x, y)
    state.dragging = true
end

function hv_picker.mousemoved(core, id, x, y)
    local opt, state = core:args(id)
    if not state.dragging then return end
    hv_picker.update_hue_value(core, id, x, y)
end

function hv_picker.mousereleased(core, id, x, y, button)
    if button ~= 1 then return end
    local opt, state = core:args(id)
    if not state.dragging then return end
    state.dragging = false
    hv_picker.update_hue_value(core, id, x, y)
end

function hv_picker.exit(core, id)
    return {id.hue, id.value}
end

function hv_picker.draw(core, id)
    local opt = core:args(id)

    gfx.push("all")

    local shape = core:shape(id)
    gfx.setColor(0.75, 0.75, 0.75)
    gfx.rectangle("fill", shape:expand(2, 2):unpack())
    gfx.setShader(shader)
    shader:send("saturation", opt.saturation or 0.5)
    gfx.draw(canvas, shape.x, shape.y, 0, shape.w, shape.h)

    local r = 5

    local x = lerp(shape.x, shape.x + shape.w, id.hue)
    local y = lerp(shape.y + shape.h, shape.y, id.value)

    gfx.setShader()
    local v = id.value > 0.5 and 0.0 or 1.0
    gfx.setColor(v, v, v)

    gfx.circle("line", x, y, r)

    for _, color in ipairs(opt.others or {}) do
        local v = color[3] > 0.5 and 0.0 or 1.0
        gfx.setColor(v, v, v)
        local x = lerp(shape.x, shape.x + shape.w, color[1])
        local y = lerp(shape.y + shape.h, shape.y, color[3])
        gfx.rectangle("line", x - r, y - r, r* 2, r * 2)
    end

    gfx.pop()
end

return hv_picker
