module = {}
local awful = require('awful')
local globalkeys = {}

local screen_flipped = false

if io.open('/etc/hostname'):read() == 'xps' then

    local toggle_screen_orientation = function()
        if screen_flipped then
            screen_flipped = false
            os.execute('xrandr --output eDP1 --rotate normal')
        else
            screen_flipped = true
            os.execute('xrandr --output eDP1 --rotate inverted')
        end
    end

    globalkeys = awful.util.table.join(
        awful.key({ modkey,           }, "u", toggle_screen_orientation)
        )

end

module.keys = globalkeys
return module
