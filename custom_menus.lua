local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

netctl_menu = {}
netctl = io.popen('netctl list')

function nic_display()
    local refresh_nic = timer({ timeout = 1 })
    local refresh_limit = 30
    refresh_nic:connect_signal("timeout", function ()
        if nic or refresh_limit == 0 then
            refresh_nic:stop()
            if refresh_limit ~= 0 then
                naughty.notify({title='Connected using '..nic})
            end
            return
        end
        set_nic()
        refresh_limit = refresh_limit - 1
    end)
    refresh_nic:start()
end
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
nic_display()

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
}
local connect_items = {
    { "VPN@Wy",  texec('systemctl restart openvpn@wy')  },
    { "Ssh tow",  texec('ssh -p 222 fdev31.ddns.net')  },
    { "Ssh wyoli",  texec('ssh wyoli')  },
    { "Ssh wy",  texec('ssh wy')  },
    { "Ssh ui",  texec('ssh ui.static.wyplay.int')  },
    { "Serial @38.4",  texec('sudo screen /dev/ttyUSB0 38400')  },
    { "Serial @115.2", texec('sudo screen /dev/ttyUSB0 115200') },
    { "Telnet STB",    texec('telnet $(cat ~/tmp/STB_IP.txt)') },
    { "WebConsole",    exec('chromium http://$(cat ~/tmp/STB_IP.txt):8080/') },
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
    { "quit", awesome.quit },
}
if IS_LAPTOP then
    table.insert(menu_items, 3, {"light", light_levels})
end

mymainmenu = awful.menu({ items = menu_items })

