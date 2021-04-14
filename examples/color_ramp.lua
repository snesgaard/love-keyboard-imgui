local congui = require "congui"
local theme = require "theme"
local hv_picker = require "hue_value_picker"
local sat_slider = require "saturation_slider"
local textbox = require "textbox"
local ramp_sphere = require "ramp_sphere"
local colorbox = require "colorbox"
local misc = require "misc"
local log = require "log"
local rectangle = require "rectangle"

local lume = require "lume"

local palette_path = "test.lua"
local png_path = palette_path .. ".png"

function hsv(h, s, v)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return r, g, b, a
end

local function serialize_color_ramps(color_ramps)
    local str = "{\n"

    for _, ramp in ipairs(color_ramps) do
        str = str .. "    {\n"
        for _, color in ipairs(ramp) do
            local row = string.format(
                "        {%i, %i, %i},\n",
                color[1] * 360, color[2] * 100, color[3] * 100
            )
            str = str .. row
        end
        str = str .. "    },\n"
    end

    str = str .. "}\n"
    return str
end

local function deserialize_color_ramps(str)
    local color_ramps = lume.deserialize(str)

    for _, ramp in ipairs(color_ramps) do
        for index, color in ipairs(ramp) do
            ramp[index] = normalize_hsv(color)
        end
    end

    return color_ramps
end

local function read_color_ramps(path)
    local str, msg = love.filesystem.read(path)

    if not str then
        print("error while reading", path)
        print(msg)
        return
    end

    return deserialize_color_ramps(str)
end

local function write_color_ramps(path, ramps)
    local str = serialize_color_ramps(ramps)

    local success, msg = love.filesystem.write(path, str)

    if not success then
        print("Error while writing ramps", path)
        print(msg)
    end

    return success
end

local function export_ramps(path, ramps)
    local all_colors = {}
    for _, ramp in ipairs(ramps) do
        for _, color in ipairs(ramp) do
            table.insert(all_colors, color)
        end
    end

    local im = love.image.newImageData(#all_colors, 1)

    for index, color in ipairs(all_colors) do
        local r, g, b = hsv(unpack(color))
        im:setPixel(index - 1, 0, r, g, b, a)
    end

    im:encode("png", path)
end

local function neutral_ramp()
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

local function default_ramp()
    local color_ramps = {
        neutral_ramp()
    }

    return color_ramps
end

local function create_state(state)
    local state = {
        saturation_slider={saturation=0.5},
        hv_picker={hue=0.75, value=0.25},
        ramp = 1,
        color = 1,
        color_ramps = read_color_ramps(palette_path) or default_ramp(),
        log = {}
    }

    return state
end

local function do_gui(events, state, user_theme)
    state = state or create_state(state)

    local log_messages = {}

    local gui = congui.create(events, theme(user_theme))

    state.ramp = math.clamp(1, #state.color_ramps, state.ramp)
    local ramp = state.color_ramps[state.ramp]

    state.color = math.clamp(1, #ramp, state.color)
    local color = ramp[state.color]

    local sub_colors = {}

    for index, color in ipairs(ramp) do
        if index ~= state.color then
            table.insert(sub_colors, color)
        end
    end

    local h = gui:widget(
        hv_picker,
        {
            hue=color[1], saturation=color[2], value=color[3],
            others=sub_colors
        },
        state.hv_picker,
        gui.layout:down(300, 300):get()
    )
    color[1], color[3] = unpack(h)

    gui.layout:push()
    color[2] = gui:widget(
        sat_slider,
        {hue=color[1], saturation=color[2], value=color[3]},
        state.saturation_slider,
        gui.layout:move(0, 5):down(nil, 20):get()
    )

    gui.layout:move(0, 5):down(0, 0)


    for index, color in ipairs(ramp) do
        local pressed = gui:widget(
            colorbox, {color=color, selected=state.color == index},
            gui.layout:right(60, 30):get()
        )
        if pressed then
            state.color = index
        end
    end


    gui.layout:pop()
    gui.layout:move(30, 0)

    gui.layout:push()

    for index, ramp in ipairs(state.color_ramps) do
        local shape = gui.layout:right(150, 150):get()

        local ux = gui.layout:get().x + gui.layout:get().w
        if ux > gfx.getWidth() then
            gui.layout:pop()
            gui.layout:move(0, 150)
            gui.layout:push()
            shape = gui.layout:right(150, 150):get()
        end

        local pressed = gui:widget(
            ramp_sphere,
            {ramp=ramp, selected=index==state.ramp},
            shape
        )

        if pressed then
            state.ramp = index
        end
    end

    gui.layout:pop()

    if gui:widget(misc.add_ramp) then
        table.insert(state.color_ramps, neutral_ramp())
        table.insert(log_messages, "adding sphere...")
    end

    if gui:widget(misc.remove_ramp) then
        table.remove(state.color_ramps, state.ramp)
        if #state.color_ramps == 0 then
            table.insert(state.color_ramps, neutral_ramp())
        end
        table.insert(log_messages, "Removing sphere...")
    end

    if gui:widget(misc.save_ramp) then
        local save_path = palette_path
        write_color_ramps(save_path, state.color_ramps)
        local msg = string.format("Saving ramps to %s", save_path)
        table.insert(log_messages, msg)
    end

    if gui:widget(misc.export_ramp) then
        export_ramps(png_path, state.color_ramps)
        local msg = string.format("Exporting ramps to %s", png_path)
        table.insert(log_messages, msg)
    end

    gui:widget(
        log, {messages = log_messages}, state.log,
        rectangle.create(gfx.getWidth(), gfx.getHeight(), 400, 200)
            :move(-400, -200)
    )


    return gui, state
end

return do_gui
