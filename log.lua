local text = require "text"

local log = {}

local function handle_new_messages(opt, state, ...)

end

log.default_duration=4.0

function log.enter(core, id)
    local opt, state, shape = core:args(id)
    state.messages = state.messages or {}

    for _, msg in ipairs(opt.messages or {}) do
        table.insert(state.messages, {msg=msg, duration=log.default_duration})
    end

    local max_messages = opt.max_messages or 30
    local to_delete = math.max(0, #state.messages - max_messages)

    for i = 1, to_delete do
        table.erase(state.messages, 1)
    end

    if shape then core:set_shape(id, shape) end
end

function log.update(core, id, dt)
    local opt, state = core:args(id)
    for _, msg in ipairs(state.messages) do
        msg.duration = msg.duration - dt
    end

    for i = #state.messages, 1, -1 do
        if state.messages[i].duration <= 0 then
            table.remove(state.messages, i)
        end
    end
end

function log.draw(core, id)
    local shape = core:shape(id)
    local opt, state = core:args(id)

    gfx.stencil(function()
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", shape:unpack())
    end, "replace", 1)
    gfx.setStencilTest("equal", 1)

    local text_height = 20
    local text_margin = 2
    local text_shape = shape:move(0, text_margin):down(nil, text_height)

    for i = #state.messages, 1, -1 do
        text_shape = text_shape:move(0, -text_margin):up()
        local msg = state.messages[i]
        local v = msg.duration
        gfx.setColor(1, 1, 1, v)
        text.draw(msg.msg, nil, text_shape)
    end

    gfx.setStencilTest()
end

function log.exit()

end

return log
