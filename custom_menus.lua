-- Menus definitions
-- includes the main global menu & the graphical global menu

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

netctl_menu = {}
netctl = io.popen('netctl list')

table.insert( netctl_menu, { "reset", exec('sudo netctl stop-all && sudo netctl restore') } )
for line in netctl:lines() do
    line = line:sub(3)
    table.insert( netctl_menu, { line, function()
        exec('sudo ifconfig w0 down ; sudo netctl stop-all && sudo netctl start '..line)
        nic = false
        nic_display()
    end
    } )
end
netctl:close()

-- Setup backlight object

backlight = nil

if IS_LAPTOP then
    backlight = require('backlight')
else
    backlight = { up = nil, down = nil }
end

-- TODO: build menus from text files
local app_items = {
    { "Inkscape", sexec('inkscape') },
    { "Blender", sexec('blender') },
    { "Gimp", sexec('gimp') },
    { "WeeChat", texec('weechat-curses') },
    { "Steam", sexec("Steam") },
}
local connect_items = {
    { "Screen STB",  texec('screen /dev/ttyUSB0 115200')  },
    { "Ssh STB",    texec('$(~/utils/sstb') },
    {"remote input", function()
        texec('ssh -f -N -L 24800:localhost:24800 popo')
        texec('synergyc -f localhost')()
    end}
}
local zmitems ={
    {"Start Radio", texec("mplayer -cache 128 http://broadcast.infomaniak.net:80/radionova-high.mp3") },
    {'zb: (un)pause', sexec('wasp pause')},
    {'zb: zap', sexec('wasp next')},
}

zicmenu = awful.menu({items = zmitems})

menu_items = {
    { "applications", app_items, beautiful.sun},
    { "net", netctl_menu },
    { "connect", connect_items},
    { "zic", zmitems},
    { "configure", sexec('mate-control-center')},
    { "quit", sexec('mate-session-save --shutdown-dialog')},
}

mymainmenu = awful.menu({ items = menu_items })


local module = {}
local awful = require('awful')
local mykeys = {}

local light_levels = {
    { "Low",  sexec('xbacklight -set 2')  },
    { "Avg",  sexec('xbacklight -set 20')  },
    { "Mid",  sexec('xbacklight -set 50')  },
    { "High",  sexec('xbacklight -set 100')  },
}

local xrandr = require('xrandrlib')
xrandr.set_order({"DP-1", "HDMI-0", "DVI-D-0"})

local screen_aliases = {}
screen_aliases['eDP1'] = 'Built-in'
screen_aliases['HDMI-1'] = 'Ext-HDMI'
screen_aliases['DVI-D-0'] = 'Beamer'
screen_aliases['HDMI-0'] = 'Medion'
screen_aliases['DP-1'] = 'Iiyama'

local screen_flipped = false

function set_wacom_screen(screen_nr)
    local offset = (screen_nr - 1) * 1920
    for i=10,20 do
        exec("xsetwacom --set " .. i .. "MapToOutput 1920x1080+" .. offset .. "+0")
    end
end


local reset_default_scr = function()
    screen_flipped = false
    exec('xinput set-prop 10 "Evdev Axes Swap" 0')
    exec('xinput set-prop 10 "Evdev Axis Inversion" 0 0')
    exec('xinput enable 11')
    exec('synclient TouchpadOff=0')
    exec('xrandr --output eDP1 --rotate normal')
end

--if io.open('/etc/hostname'):read() == 'xps' then
local layouts = {
    {"Rescan", xrandr.scan_screens},
    {"Blank", {
        {"ON", sexec('xset s on +dpms')},
        {"OFF", sexec('xset s off -dpms')}
    }},
    {"Light", light_levels}
}

local naughty = require('naughty')

for i, name in pairs(xrandr.screens) do
    local screen_opts = {}
    table.insert(screen_opts, {'on', function()
        xrandr.switch_on( name )
    end})
    table.insert(screen_opts, {'off', function()
        xrandr.switch_off( name )
    end})
    table.insert(screen_opts, {'master', function()
        xrandr.set_master( name )
        set_wacom_screen(i)
        xrandr.switch_on( name )
    end})
    table.insert(layouts, {screen_aliases[name] or name, screen_opts})
end

table.insert(layouts, {"Orientations",
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
})


local screensitems = {
    {"Screens", layouts},
    {"Input" ,{
        {"Touchscreen set", function()
            exec('xinput map-to-output "ATML1000:00 03EB:842F" eDP1')
        end
        },
        {"F1-F12 std", function()
            exec('sudo k780swap')
        end
        },
        {"F1-F12 Fn", function()
            exec('sudo k780swap off')
        end
        },
        {"Wacom Sculpt", sexec("~/wacom_sculpt.sh")},
        {"Touchpad On",function()
            exec('synclient TouchpadOff=0')
            exec('synclient TapButton3=2')
            exec('synclient TapButton2=3')
            exec('synclient TapButton1=1')
            exec('xinput enable 11') end
        },
        {"Touchpad Off", function()
            exec('synclient TouchpadOff=1')
            exec('xinput disable 11')
        end
        }
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
    end,
    {description="show graphical menu", group="awesome"}
    )
}

--end

module.keys = mykeys
return module
