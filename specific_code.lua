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
