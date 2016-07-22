local xrandr = {}

xrandr.screensreen_states = {}
xrandr.screens = {}

xrandr.scan_screens = function()
    for k,v in pairs(xrandr.screens) do xrandr.screens[k]=nil end
    local x = io.popen("xrandr")
    local idx = nil
    for line in x:lines() do
        idx = string.find(line, " connected ")
        if idx then
            local status = not (string.find(line, "[(]") <= idx+15)
            local sc = string.sub(line, 0, idx-1)
            xrandr.screensreen_states[sc] = {active=status}
            table.insert(xrandr.screens, sc)
        end
    end
end

xrandr.set_order = function(screen_config)
    xrandr.screens = screen_config
end

xrandr.is_defined = function(screen)
    return xrandr.screensreen_states[screen].active ~= nil
end

xrandr.is_on = function(screen)
    return xrandr.screensreen_states[screen].active
end

xrandr.is_primary = function(screen)
    return xrandr.screensreen_states.master == screen
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
    xrandr.screensreen_states[screen].active = onoff
end

xrandr.set_master = function(screen)
    xrandr.screensreen_states.master = screen
end

local naughty = require('naughty')

xrandr.apply_config = function()
    local xrandr_opts = {'xrandr'}
    local last_on = false

    -- build xrandr options
    for i, disp in ipairs(xrandr.screens) do
        if xrandr.is_defined(disp) then
            xrandr_opts[#xrandr_opts+1] = '--output ' .. disp

            if xrandr.is_on(disp) then
                if not last_on then
                    last_on = i
                else
                    xrandr_opts[#xrandr_opts+1] = '--right-of ' .. xrandr.screens[last_on]
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
    exec(table.concat(xrandr_opts, ' '))
    -- run=function on click
    if primary then
        set_wacom_screen(primary)
    end
    naughty.notify({title=table.concat(xrandr_opts, ' '), timeout=0, screen=1, position="top_left", ontop=true})
end

xrandr.scan_screens()
return xrandr