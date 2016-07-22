local xrandr = {}

xrandr.screen_states = {}
xrandr.sc = {}

local x = io.popen("xrandr")
local idx = nil
for line in x:lines() do
    idx = string.find(line, " connected ")
    if idx then
        local status = not (string.find(line, "[(]") <= idx+15)
        local sc = string.sub(line, 0, idx-1)
        xrandr.screen_states[sc] = {active=status}
        table.insert(xrandr.sc, sc)
    end
end

xrandr.init_screens = function(screen_config)
    xrandr.sc = screen_config
end

xrandr.is_defined = function(screen)
    return xrandr.screen_states[screen].active ~= nil
end

xrandr.is_on = function(screen)
    return xrandr.screen_states[screen].active
end

xrandr.is_primary = function(screen)
    return xrandr.screen_states.master == screen
end

-- priv

xrandr.switch_on = function(screen)
    xrandr.switch_screen(screen, true)
    xrandr.apply_config()
end

xrandr.switch_off = function(screen)
    xrandr.switch_screen(screen, false)
    xrandr.apply_config()
end

xrandr.switch_screen = function(screen, onoff)
    xrandr.screen_states[screen].active = onoff
end

xrandr.set_master = function(screen)
    xrandr.screen_states.master = screen
end

local naughty = require('naughty')

xrandr.apply_config = function()
    local xrandr_opts = {'xrandr'}
    local last_on = false

    -- build xrandr options
    for i, disp in ipairs(xrandr.sc) do
        if xrandr.is_defined(disp) then
            xrandr_opts[#xrandr_opts+1] = '--output ' .. disp

            if xrandr.is_on(disp) then
                if not last_on then
                    last_on = i
                else
                    xrandr_opts[#xrandr_opts+1] = '--right-of ' .. xrandr.sc[last_on]
                    last_on = i
                end
            end

            xrandr_opts[#xrandr_opts+1] = xrandr.is_on(disp) and '--auto' or '--off'

            if xrandr.is_primary(disp) then
                local primary = i
                xrandr_opts[#xrandr_opts+1] = '--primary'
            end
        end
    end
    naughty.notify({title=table.concat(xrandr_opts, ' ')})
    exec(table.concat(xrandr_opts, ' '))
    if primary then
        set_wacom_screen(primary)
    end
end

return xrandr
