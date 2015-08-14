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

-- TODO: build menus from text files
app_items = {
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
connect_items = {
    { "VPN@Wy",  texec('systemctl restart openvpn@wy')  },
    { "Ssh tow",  texec('ssh tow')  },
    { "Ssh wy",  texec('ssh wy')  },
    { "Serial @38.4",  texec('sudo screen /dev/ttyUSB0 38400')  },
    { "Serial @115.2", texec('sudo screen /dev/ttyUSB0 115200') },
}
screen_items = {
    {"WinInfo", texec("xproptitle")},
    {"Comp switch", sexec('comp-switch')},
    {"Shift switch", sexec('shift-switch')},
    {"DPMS ON", sexec('xset s on +dpms')},
    {"DPMS OFF", sexec('xset s off -dpms')}
}
zmitems ={
    {"Start Radio", texec("mplayer -cache 128 http://broadcast.infomaniak.net:80/radionova-high.mp3") },
    {'zb: (un)pause', sexec('wasp pause')},
    {'zb: zap', sexec('wasp next')},
}

zicmenu = awful.menu({items = zmitems})
mymainmenu = awful.menu({
    items = {
        { "applications", app_items, beautiful.sun},
        { "connect", connect_items},
        { "zic", zmitems},
        { 'screen', screen_items},
        { "net", netctl_menu },
    }
})
