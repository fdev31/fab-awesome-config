local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

naughty.notify(UT_FOLDER)

netctl_menu = {}
netctl = io.popen('netctl list')
for line in netctl:lines() do
    line = line:sub(3)
    table.insert( netctl_menu, { line, sexec('sudo ifconfig w0 down ; sudo netctl stop-all && sudo netctl start '..line) } )
end
netctl:close()

-- Setup backlight object

backlight = nil

if IS_LAPTOP then
    backlight = require('backlight')
else
    backlight = { up = nil, down = nil }
end

local light_levels = {
    { "Low",  sexec('xbacklight -set 2')  },
    { "Avg",  sexec('xbacklight -set 20')  },
    { "Mid",  sexec('xbacklight -set 50')  },
    { "High",  sexec('xbacklight -set 100')  },
}


-- TODO: build menus from text files
local app_items = {
    { "Inkscape", sexec('inkscape') },
    { "Blender", sexec('blender') },
    { "Gimp", sexec('gimp') },
    { "WeeChat", texec('weechat-curses') },
    { "UrbanTerror", sexec('cd ' .. UT_FOLDER .. ' ; comp-switch off ; ./Quake3-UrT.x86_64 ' .. UT_OPTIONS .. ' ; comp-switch on ; ' .. UT_POSTRUN) },
--    { "Midori", sexec('midori') },
--    { "Firefox", sexec('firefox') },
--    { "Chromium", sexec(WEB_BROWSER) },
--    { "Thunar", sexec('thunar') },
}
local connect_items = {
    { "VPN@Wy",  texec('systemctl restart openvpn@wy')  },
    { "Ssh tow",  texec('ssh tow')  },
    { "Ssh wy",  texec('ssh wy')  },
    { "Serial @38.4",  texec('sudo screen /dev/ttyUSB0 38400')  },
    { "Serial @115.2", texec('sudo screen /dev/ttyUSB0 115200') },
}
local screen_items = {
    {"WinInfo", texec("xproptitle")},
    {"Comp switch", sexec('comp-switch')},
    {"Shift switch", sexec('shift-switch')},
    {"DPMS ON", sexec('xset s on +dpms')},
    {"DPMS OFF", sexec('xset s off -dpms')}
}
local zmitems ={
    {"Start Radio", texec("mplayer -cache 128 http://broadcast.infomaniak.net:80/radionova-high.mp3") },
    {'zb: (un)pause', sexec('wasp pause')},
    {'zb: zap', sexec('wasp next')},
}

zicmenu = awful.menu({items = zmitems})

menu_items = {
    { "applications", app_items, beautiful.sun},
    { "connect", connect_items},
    { "zic", zmitems},
    { 'screen', screen_items},
    { "net", netctl_menu },
}
if IS_LAPTOP then
    table.insert(menu_items, 3, {"light", light_levels})
end

mymainmenu = awful.menu({ items = menu_items })

