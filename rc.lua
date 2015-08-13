local UT_FOLDER = '/home/fab/grosdisk/home/fab/games/UrbanTerror42'
local UT_OPTIONS = ''
local UT_POSTRUN = ''

local WEB_BROWSER = 'firefox'
local IS_LAPTOP = os.execute('laptop-detect')
local zic_prompt = true
-- This is used later as the default terminal and editor to run.
--terminal = "xterm"
--terminal_run = "xterm -e "
terminal = "terminator"
terminal_run = "terminator -x "

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- fab31
local vicious = require("vicious")
local drop = require("drop")
local beautiful = require("beautiful")
require('theme')
local color = {red="#FF5555", green="#55FF55", blue="#5555FF", yellow="#FFFF00"}
local nic = io.popen("ip addr|grep UP|cut -d: -f2| sed 's/^ *//g' | grep -Ev '^(lo|tun|tap)'"):read()
local awesome_pid = io.popen('echo $PPID', 'r'):read()
local home   = os.getenv("HOME")

globalkeys = {}
modkey = "Mod4"

local screen_switched = false

-- /fab31

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end



-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- see compose in /usr/share/X11/xkb/rules/base.lst
 if IS_LAPTOP then
     awful.util.spawn_with_shell('setxkbmap -option compose:prsc')
 else
     awful.util.spawn_with_shell('setxkbmap -option compose:menu')
 end

local _cmds = io.open(home.."/.config/awesome/commands.txt", "r")
if _cmds then
    while true do
        line = _cmds:read()
        if line == nil then
            break
        end
        awful.util.spawn_with_shell(line .. " &")
    end
    _cmds = nil
end

modules = require('specific_code')
if modules.keys then
    globalkeys = awful.util.table.join(globalkeys, modules.keys)
end


--awful.util.spawn_with_shell("comp-switch on &")
--awful.util.spawn_with_shell("shift-switch &")
--awful.util.spawn_with_shell("procs start &")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--

editor = os.getenv("EDITOR") or "nano"
ieditor_cmd = terminal .. " -e " .. editor

-- fab31
terminal = "terminator"
--editor = os.getenv("EDITOR") or "nano"
editor_cmd = 'gvim -reverse '

local exec   = awful.util.spawn
local _sexec  = awful.util.spawn_with_shell
local scount = screen.count()

if (scount == 1) then
    S_MAIN = 1
    S_SEC = 1
else
    S_SEC = 2
    S_MAIN = 1
end

-- handy functions --

function texec(cmd, opts)
    local args = ' '
    if (opts) then
        local res = {}
        for k, v in pairs(opts) do
            table.insert(res, '-'..k..' '..v)
        end
        args = ' ' .. table.concat(res, ' ')
    end
    local t = function()
        exec(terminal_run .. cmd .. " " .. args)
    end
    return t
end
function eexec(w)
    local t = function()
        exec(editor_cmd .. " " .. w)
    end
    return t
end
function sexec(cmd)
    local t = function()
        _sexec(cmd)
    end
    return t
end
-- Menus definition --

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
    { "Gimp", sexec('gimp') },
    { "UrbanTerror", sexec('cd ' .. UT_FOLDER .. ' ; comp-switch off ; ./Quake3-UrT.x86_64 ' .. UT_OPTIONS .. ' ; comp-switch on ; ' .. UT_POSTRUN) },
    { "Midori", sexec('midori') },
    { "Firefox", sexec('firefox') },
    { "Chromium", sexec(WEB_BROWSER) },
    { "Thunar", sexec('thunar') },
    { "WeeChat", texec('weechat-curses') },
}
connect_items = {
    { "OpenVPN@Wyplay",  texec('systemctl restart openvpn@wy')  },
    { "Ssh tow",  texec('ssh tow')  },
    { "Ssh wy",  texec('ssh wy')  },
    { "Serial @38.4",  texec('sudo screen /dev/ttyUSB0 38400')  },
    { "Serial @115.2", texec('sudo screen /dev/ttyUSB0 115200') },
}
light_levels = {
    { "Low",  sexec('xbacklight -set 2')  },
    { "Avg",  sexec('xbacklight -set 20')  },
    { "Mid",  sexec('xbacklight -set 50')  },
    { "High",  sexec('xbacklight -set 100')  },
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
        { "light", light_levels},
        { "zic", zmitems},
        { "net", netctl_menu },
--        { "manual", texec("man awesome") },
--        { "edit config", eexec(awesome.conffile) },
--        { "show logs", texec("tail -n 30 -f /proc/" .. awesome_pid .. "/fd/1 /proc/" .. awesome_pid .. "/fd/2") },
--        { "restart", awesome.restart },
        { "quit", awesome.quit },
        { "suspend now", sexec('sudo pm-suspend') },
        { 'screen', screen_items},
    }
})

function progress_maker()
    local bar    = awful.widget.progressbar()
    -- Progressbar properties
    bar:set_vertical(true):set_ticks(true)
    bar:set_height(10):set_width(8):set_ticks_size(1)
    bar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, color.red }, { 0.5, color.green }, { 1, color.yellow }} })
    return bar
end

-- /fab31


-- Table of layouts to cover with awful.layout.inc, order matters.

-- fab31
-- all used layouts should be defined ONCE here:
rlayouts = {
    title  = awful.layout.suit.tile        , 
    titlet = awful.layout.suit.tile.top    , 
    fair   = awful.layout.suit.fair        , 
    max    = awful.layout.suit.max         , 
    mag    = awful.layout.suit.magnifier   , 
    float  = awful.layout.suit.floating    , 
}

-- build layouts from rlayouts
layouts = {
    rlayouts.title,
    rlayouts.titlet,
    rlayouts.mag,
    rlayouts.max,
--    rlayouts.float,
}

-- Tags --
tags = {
    names={},
    layout={}
}

_dflt = rlayouts.title

-- user-customizable tags: (name, layout)
_tags = {
    {"term"  , rlayouts.titlet} , 
    {"edit"  , _dflt}           , 
    {"web"   , _dflt}           , 
    {"im"    , _dflt}           , 
    {"fm"    , rlayouts.max}    , 
    {"gfx"    , rlayouts.max}    , 
--    {nil     , rlayouts.float}  , 
--    {nil     , rlayouts.float}  , 
    {"rss"   , rlayouts.mag}    , 
    {"media" , _dflt}
}

-- rtagnums.tag_name == <index of the given tag>
rtagnums = {}

for i,t in ipairs(_tags) do
    if t[1] then
        rtagnums[t[1]] = i
    end
    tags.names[i] = t[1] or i
    tags.layout[i] = t[2]
end

_tags = nil
_dflt = nil
-- /fab31

-- stop describing, set tags for real now

for s = 1, scount do -- for each screen
  tags[s] = awful.tag(tags.names, s, tags.layout) -- create tags
  for i, t in ipairs(tags[s]) do -- set some properties
      awful.tag.setproperty(t , "mwfact" , 0.5)
      awful.tag.setproperty(t , "hide"   , (i==7 or i==8) and true)
  end
end

-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", texec( "man awesome") },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

-- fab31
-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                    { "open terminal", terminal }
--                                  }
--                        })
-- /fab31

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- fab31
-- Wibox --

-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
--cpuicon = wibox.widget.imagebox()
--cpuicon:set_image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
--tzswidget = wibox.widget.textbox()
-- Graph properties
cpugraph:set_width(40)
--cpugraph:set_background_color(beautiful.fg_off_widget)
--cpugraph:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, color.red }, { 0.5, color.green }, { 1, color.blue }}, angle=0}) -- still not working FIXME !
cpugraph:set_background_color("#494B4F")
cpugraph:set_color({ type = "linear", from = { 0, 0 }, to = { 0,10 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                    {1, "#AECF96" }}})

 -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
--vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, "thermal_zone0")
-- }}}
if IS_LAPTOP then

    -- {{{ Battery state
    baticon = wibox.widget.imagebox()
    baticon:set_image(beautiful.widget_bat)
    -- Initialize widget
    batwidget = wibox.widget.textbox()
    -- Register widget
    vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
    -- }}}
end

-- {{{ Memory usage
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
-- Initialize widget
local membar = progress_maker()
vicious.register(membar, vicious.widgets.mem, "$1", 13)

-- {{{ File system usage
fsicon = wibox.widget.imagebox()
fsicon:set_image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  b = awful.widget.progressbar(), r = awful.widget.progressbar(),
  h = awful.widget.progressbar(), s = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(14):set_width(5):set_ticks_size(2)
--  w:set_border_color(beautiful.border_widget)
--  w:set_background_color(beautiful.fg_off_widget)
  w:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, color.red }, { 0.5, color.green }, { 1, color.yellow }} })
  -- Register buttons
  w:buttons(awful.util.table.join(
    awful.button({ }, 1, sexec("rox") )
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.b, vicious.widgets.fs, "${/boot used_p}", 599)
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",     599)
vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}", 599)
vicious.register(fs.s, vicious.widgets.fs, "${/mnt/storage used_p}", 599)
-- }}}

-- {{{ Network usage
local dnicon = wibox.widget.imagebox()
local upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
-- Initialize widget
local netwidget = wibox.widget.textbox()
-- Register widget
if nic then
    vicious.register(netwidget, vicious.widgets.net, '<span color="'
      .. color.yellow .. '">${'..nic..' down_kb}</span> <span color="'
      .. color.green ..'">${'..nic..' up_kb}</span>', 3)
end
-- }}}

-- {{{ Volume level
local volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
-- Initialize widgets
local volbar    = progress_maker()
local volwidget = wibox.widget.textbox()
-- Progressbar properties
-- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")

-- Setup mixer object
--
local mixer = require('amixer')

-- Setup backlight object

local backlight = nil
if IS_LAPTOP then
    backlight = require('backlight')
else
    backlight = { up = nil, down = nil }
end

-- Register buttons

volbar:buttons(awful.util.table.join(
   awful.button({ }, 1, sexec("pavucontrol") ),
   awful.button({ }, 4, function() mixer.up() vicious.force(vicious.widgets.volume) end ),
   awful.button({ }, 5, function() mixer.down() vicious.force(vicious.widgets.volume) end )
)) -- Register assigned buttons
volwidget:buttons(volbar:buttons())
-- }}}

-- {{{ Date and time
local dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
-- Initialize widget
local datewidget = wibox.widget.textbox()
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%R", 61)
-- /fab31
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Widgets that are aligned to the left
    --
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
--    left_layout:add(mylayoutbox[s])
    left_layout:add(separator)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
--    right_layout:add(tzswidget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end

    right_layout:add(mytextclock)
    right_layout:add(memicon)
    right_layout:add(membar)
    right_layout:add(separator)
    right_layout:add(volicon)
    right_layout:add(volwidget)
    right_layout:add(volbar)
    right_layout:add(separator)
    right_layout:add(dnicon)
    right_layout:add(netwidget)
    right_layout:add(upicon)
    right_layout:add(separator)
    right_layout:add(fsicon)
    right_layout:add(fs.s)
    right_layout:add(fs.h)
    right_layout:add(fs.r)
    right_layout:add(separator)
    right_layout:add(fs.b)
--    right_layout:add(separator)
    right_layout:add(separator)
    right_layout:add(cpugraph)
--

    if IS_LAPTOP then
        right_layout:add(baticon)
    end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(globalkeys,
    awful.key({ }, "XF86AudioLowerVolume", function() mixer.down() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioRaiseVolume", function() mixer.up() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioMute", mixer.toggle),

    awful.key({ }, "XF86MonBrightnessUp", backlight.up),
    awful.key({ }, "XF86MonBrightnessDown", backlight.down),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
-- fab31
    awful.key({ modkey, "Shift" }, "Right",   function()
        local i = nil
        if ( #tags[client.focus.screen] == awful.tag.getidx() ) then
            i = 1
        else
            i = awful.tag.getidx()+1
        end
        awful.client.movetotag(tags[client.focus.screen][i])
        awful.tag.viewnext()
        client.focus:raise()
    end),
    awful.key({ modkey, "Shift" }, "Left",   function()
        local i = nil
        if ( 1 == awful.tag.getidx() ) then
            i = #tags[client.focus.screen]
        else
            i = awful.tag.getidx()-1
        end
            awful.client.movetotag(tags[client.focus.screen][i])
            awful.tag.viewprev()
            client.focus:raise()
        end
    ),
-- /fab31
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
-- fab31   awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "p", function () screen_switched = true awful.screen.focus_relative( 1) end),
--    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    --[[
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    --]]
    -- Menubar
    awful.key({ modkey }, "F2", function() menubar.show() end),
    awful.key({ modkey }, "y", sexec('synapse')),
    awful.key({ "Control", "Shift"}, "l", sexec('slock')),
    -- fab31

--    ,awful.key({modkey, "Alt"}, "l", sexec("xlock", false) ),
    awful.key({ modkey}, "q", function () mymainmenu:show({keygrabber=true}) end),
    awful.key({ modkey}, "z", function () if( not zic_prompt) then zicmenu:show({keygrabber=true}) end end),
    awful.key({ modkey }, "t", sexec("thunar") ),
    awful.key({ modkey }, "w", sexec(WEB_BROWSER) ),
    awful.key({ modkey }, "e", function() awful.menu.clients({ width=250 }) end ),
--    awful.key({ modkey }, "x", function() awful.client.movetotag( tags[client.focus.screen][7] ) end ),
    awful.key({ modkey }, "a", function () drop(terminal, "bottom", "center", 0.9, 0.9, false) end),

    awful.key({ modkey }, "z", function ()
        if ( zic_prompt ) then
            awful.prompt.run({ prompt = "Wasp: " }, mypromptbox[mouse.screen].widget,
                function (...)
                    p = io.popen('wasp '.. arg[1])
                    txt = p:read()
                    p:close()
                    naughty.notify({title=txt})
                end,
                awful.completion.shell, awful.util.getdir("cache") .. "/wasp_history")
            end
    end),
    awful.key({ modkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, mypromptbox[mouse.screen].widget,
            function (words)
                exec("gnome-dictionary --look-up='"..words.."'")
            end)
    end),
    awful.key({ modkey }, "F4", function ()
        awful.prompt.run({ prompt = "Task: " }, mypromptbox[mouse.screen].widget,
            function (command)
                if(command:len() > 2) then
                    exec("task add "..command)
                else
                    local f = "/tmp/tasks.txt"
                    _sexec("task > "..f)
                    texec("less "..f)()
                end
            end)
    end),
    awful.key({ modkey }, "F5", function ()
        awful.prompt.run({ prompt = "Lua: " }, mypromptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end)
    
    -- }}}

-- /fab31
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    -- fab31
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    -- /fab31
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
        
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.


-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- fab31
function ru(c,n,prop)
        return {
            rule = {class=c, name=n},
            properties=prop,
        }
end
awful.rules.rules = {
    -- default rules --
    ru(nil,nil,{
        focus            = true,
        size_hints_honor = false,
        keys             = clientkeys,
        buttons          = clientbuttons,
        border_width     = beautiful.border_width,
        border_color     = beautiful.border_normal
    }),
    -- long rules --
    {
        { name = "alsamixer" },
        properties = {
            floating = true,
            width = 100
        },
        callback = awful.placement.under_mouse
    },

    -- standard rules --
    -- volume properties
    ru(nil, ".* volume.*",         { floating=true, fullscreen=false}),
    ru(nil, "alsamixer",           { floating=true, fullscreen=false}),
    -- www 
    ru("Chromium", nil,            { tag=tags[S_MAIN][rtagnums.web] }),
    ru("Chromium", ".*- chat -.*", { tag=tags[S_MAIN][rtagnums.im] }),
    ru("Firefox", nil,         { tag=tags[S_MAIN][rtagnums.web] }),
    -- chat
    ru("Xchat", nil,               { tag=tags[S_SEC][rtagnums.im] } ),
    -- medias
    ru("Audacious", nil,           { tag=tags[S_SEC][rtagnums.media] } ),
    -- edit
    ru("Gvim", nil,                { tag=tags[S_MAIN][rtagnums.edit] } ),
    ru("jetbrains-pycharm-ce", nil,{ tag=tags[S_MAIN][rtagnums.edit] } ),
    ru("Snaked", nil,              { tag=tags[S_MAIN][rtagnums.edit] } ),
    -- gfx
    ru("Blender", nil,             { tag=tags[S_MAIN][rtagnums.gfx], floating=true, fullscreen=true } ),
    ru("Blender", "Blender",       { floating=true, fullscreen=true}),
    ru("Gimp", nil,                { tag=tags[S_MAIN][rtagnums.gfx] } ),
    -- sound
    ru("Rdio", nil,                { tag=tags[S_SEC][rtagnums.media] } ),
    -- fs
    ru("Geeqie", nil,              { floating=true } ),
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } ),
}

-- /fab31
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- Focus signal handlers --
client.connect_signal("focus",   function (c)
    c.border_color = beautiful.border_focus
    c.opacity = 1
end)
client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
    if screen_switched then
        screen_switched = false
    else
        c.opacity = 0.85
    end
end)

-- }}}


-- {{{ Arrange signal handler
for s = 1, scount do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
--
