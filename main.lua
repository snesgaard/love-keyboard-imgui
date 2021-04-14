gfx = love.graphics

blue_theme = {
    color = {
        text = {1, 1, 1},
        back = {0.1, 0.2, 0.8, 0.2},
        middle = {0.1, 0.2, 0.8, 0.2},
        front = {0.1, 0.6, 0.8, 0.2},
        hover = {0.2, 0.6, 0.6, 0.4},
        select = {0.6, 0.6, 0.2, 0.4},
    }
}

do_gui = require "examples.menu"

function lerp(min, max, s)
    return min * (1 - s) + max * s
end

function normalize_hsv(hsv)
    return {hsv[1] / 360.0, hsv[2] / 100.0, hsv[3] / 100.0}
end

function love.load()
    events = {}
end

function math.clamp(min, max, value)
    return math.max(min, math.min(max, value))
end

function love.keypressed(...)
    table.insert(events, {"keypressed", ...})
end

function love.keyreleased(...)
    table.insert(events, {"keyreleased", ...})
end

function love.mousepressed(...)
    table.insert(events, {"mousepressed", ...})
end

function love.mousemoved(...)
    table.insert(events, {"mousemoved", ...})
end

function love.mousereleased(...)
    table.insert(events, {"mousereleased", ...})
end

function love.update(dt)
    table.insert(events, {"update", dt})
    gui, states = do_gui(events, states, blue_theme)
    events = {}
end

function love.draw()
    local x, y = 0, 0
    gui:draw(x, y)
end
