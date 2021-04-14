local add_ramp = {}

function add_ramp.keypressed(core, id, key)
    if key == "+" then
        id.activated = true
    end
end

function add_ramp.exit(core, id) return id.activated end

local remove_ramp = {}

function remove_ramp.keypressed(core, id, key)
    if key == "-" or key == "backspace" then
        id.activated = true
    end
end

function remove_ramp.exit(core, id) return id.activated end

local save_ramp = {}

function save_ramp.keypressed(core, id, key)
    if key == "s" and love.keyboard.isDown("lctrl") then
        id.activated = true
    end
end

function save_ramp.exit(core, id) return id.activated end

local export_ramp = {}

function export_ramp.keypressed(core, id, key)
    if key == "e" and love.keyboard.isDown("lctrl") then
        id.activated = true
    end
end

function export_ramp.exit(core, id) return id.activated end

return {
    add_ramp=add_ramp,
    remove_ramp=remove_ramp,
    save_ramp=save_ramp,
    export_ramp=export_ramp
}
