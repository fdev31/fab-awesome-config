local xrandr = {}

xrandr.screen_states = {}

xrandr.init_screens = function(screen_config)
    xrandr.sc = screen_config
    for i, sc in pairs(screen_config) do
        xrandr.screen_states[sc] = {}
    end
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

    -- build xrandr options
    for i, disp in ipairs(xrandr.sc) do
        if xrandr.is_defined(disp) then
            xrandr_opts[#xrandr_opts+1] = '--output ' .. disp
            if i ~= 1 then
                xrandr_opts[#xrandr_opts+1] = '--right-of ' .. xrandr.sc[i-1]
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
