module = {}
local awful = require('awful')
local mykeys = {}

local light_levels = {
    { "Low",  sexec('xbacklight -set 2')  },
    { "Avg",  sexec('xbacklight -set 20')  },
    { "Mid",  sexec('xbacklight -set 50')  },
    { "High",  sexec('xbacklight -set 100')  },
}

local screen_flipped = false

function set_wacom_screen(screen_nr)
    local offset = (screen_nr - 1) * 1920
    for i=10,13 do
        exec("xsetwacom --set " .. i .. "MapToOutput 1920x1080+" .. offset .. "+0")
    end
end

local screen_config = {"DVI-I-1", "DP-1", "HDMI-0"}

function set_active_screen(config) 
    local xrandr_opts = {'xrandr'}
    local primary = 1
    if config[2] then
        primary = 2
    elseif not config[1] then
        primary = 3
    end

    for i, x in ipairs(config) do
        xrandr_opts[#xrandr_opts+1] = '--output ' .. screen_config[i]
        if config[i-1] then
            xrandr_opts[#xrandr_opts+1] = '--right-of ' .. screen_config[i-1]
        end

        if x then
            xrandr_opts[#xrandr_opts+1] = '--auto'
        else
            xrandr_opts[#xrandr_opts+1] = '--off'
        end

        if i == primary then
            xrandr_opts[#xrandr_opts+1] = '--primary'
        end
    end

    local set_mode = function()
        exec(table.concat(xrandr_opts, ' '))
        set_wacom_screen(primary)
    end
    return set_mode
end

--set_active_screen({true, true, false})

local reset_default_scr = function() 
    screen_flipped = false
    exec('xinput set-prop 10 "Evdev Axes Swap" 0')
    exec('xinput set-prop 10 "Evdev Axis Inversion" 0 0')
    exec('xinput enable 11')
    exec('synclient TouchpadOff=0')
    exec('xrandr --output eDP1 --rotate normal')
end

--if io.open('/etc/hostname'):read() == 'xps' then

local screensitems = {
    {"Layouts", {
        {"Single", set_active_screen({false, true, false})},
        {"Dual", set_active_screen({true, true, false})},
        {"Triple", set_active_screen({true, true, true})},
        {"Cinema", set_active_screen({false, false, true})},
    }},
    {"Tablet" ,{
        {"Sculpt", sexec("~/wacom_sculpt.sh")},
        {"Grease", sexec("~/wacom_grease.sh")},
        {"Krita", sexec("~/wacom_krita.sh")},
        {"Left screen", sexec("~/wacom_left_screen.sh")},
        {"Rightscreen", sexec("~/wacom_right_screen.sh")},
    }},
    {"Touchpad" ,{
        {"On",function()
            exec('synclient TouchpadOff=0') 
            exec('xinput enable 11') end
        },
        {"Off", function()
            exec('synclient TouchpadOff=1')
            exec('xinput disable 11')
        end
        }
    }},
    {"Blank", {
        {"ON", sexec('xset s on +dpms')},
        {"OFF", sexec('xset s off -dpms')}
    }},
    {"Light", light_levels},
    {"Orientation", {
        {"Normal", reset_default_scr},
        {"Book", function() 
            exec('xinput set-prop 10 "Evdev Axes Swap" 1')
            exec('xinput set-prop 10 "Evdev Axis Inversion" 1 0')
            exec('synclient TouchpadOff=1')
            exec('xinput disable 11')
            exec('xrandr --output eDP1 --rotate left')
            screen_flipped = true
        end},
        {"Flipped", function() 
            exec('xrandr --output eDP1 --rotate inverted --auto')
            exec('xinput set-prop 10 "Evdev Axes Swap" 0')
            exec('xinput set-prop 10 "Evdev Axis Inversion" 1 1')
            exec('synclient TouchpadOff=1')
            exec('xinput disable 11')
            screen_flipped = true
        end}
    }},
    {"Switch", {
        {"Compositing", sexec('comp-switch')},
        {"Daylight", sexec('shift-switch')},
    }},
    {"WinInfo", texec("xproptitle")},
}

local screensmenu = awful.menu({items = screensitems})

mykeys = {
    awful.key({ modkey,           }, "g", 
    function ()
        if screen_flipped then reset_default_scr() else screensmenu:show({keygrabber=true}) end
    end)
}

--end

module.keys = mykeys
return module
