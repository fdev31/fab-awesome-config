local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

netctl_menu = {}
netctl = io.popen('netctl list')

local refresh_nic = timer({ timeout = 1 })

function nic_display()
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
    refresh_nic:stop()
    refresh_nic:start()
end
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
nic_display()

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
    { "Ssh tow",  texec('tow')  },
    { "Telnet target",    texec('telnet $(cat ~/tmp/TARGET_IP.txt)') },
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
    { "configure", sexec('gnome-tweak-tool')},
    { "quit", sexec('pkill gnome-session')},
}

mymainmenu = awful.menu({ items = menu_items })

