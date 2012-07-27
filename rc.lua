-- {{{ License
--
-- Awesome configuration, using awesome 3.4.12 on Arch GNU/Linux
--   * Adrian C. <anrxc@sysphere.org>

-- Screenshot: http://sysphere.org/gallery/snapshots

-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- Libraries --

require("awful")
require("awful.rules")
require("awful.autofocus")
require("naughty") -- notification
-- User libraries
local vicious = require("vicious")
local scratch = require("scratch")
require("revelation")


-- Variable definitions --

local altkey = "Mod1"
local modkey = "Mod4"
local nic = os.execute('ip addr|grep wlan0') == 0 and 'wlan0' or 'eth0'
local term = "sakura"
local edit = "gvim -reverse"

local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local _sexec  = awful.util.spawn_with_shell
local scount = screen.count()

-- handy functions --

function texec(cmd)
    local t = function()
        exec(term .. " -e " .. cmd)
    end
    return t
end
function eexec(w)
    local t = function()
        exec(edit .. " " .. w)
    end
    return t
end
function sexec(cmd)
    local t = function()
        _sexec(cmd)
    end
    return t
end

-- Beautiful theme --

beautiful.init(home .. "/.config/awesome/zenburn.lua")

-- Menus definition --

app_items = {
    { "Inkscape", sexec('inkscape') },
    { "Gimp", sexec('gimp') },
    { "Chromium (mod w)", sexec('chromium') },
    { "Thunar (mod t)", sexec('thunar') },
    { "WeeChat", texec('weechat-curses') },
}
connect_items = {
    { "Ssh ui",  texec('ssh ui.static.wyplay.int')  },
    { "Ssh wopr",  texec('ssh wopr')  },
    { "Ssh wyoli",  texec('ssh wyoli.wyplay.com')  },
    { "Serial @38.4",  texec('sudo screen /dev/ttyUSB0 38400')  },
    { "Serial @115.2", texec('sudo screen /dev/ttyUSB0 115200') },
}
zmitems ={
        {'toggle pause', sexec('wasp pause')},
        {'zap', sexec('wasp next')},
    }

zicmenu = awful.menu({items = zmitems})
mymainmenu = awful.menu({
    items = {
        { "applications", app_items, beautiful.sun},
        { "targets", connect_items},
        { "zic", zmitems},
        { "manual", texec("man awesome") },
        { "edit config", eexec(awesome.conffile) },
        { "restart", awesome.restart },
        { "quit", awesome.quit },
    }
})

-- launcher for clickable icon
mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })

-- Window management layouts --
-- all used layouts should be defined ONCE here:
rlayouts = {
    title  = awful.layout.suit.tile        , 
    titleb = awful.layout.suit.tile.bottom , 
    fair   = awful.layout.suit.fair        , 
    max    = awful.layout.suit.max         , 
    mag    = awful.layout.suit.magnifier   , 
    float  = awful.layout.suit.floating    , 
}

-- build layouts from rlayouts
layouts = {}
n=1
for i, o in pairs(rlayouts) do
    layouts[n] = o
    n=n+1
end
n=nil

-- Tags --
tags = {
    names={},
    layout={}
}

_dflt = rlayouts.title

-- user-customizable tags: (name, layout)
_tags = {
    {"term"  , rlayouts.titleb} , 
    {"edit"  , _dflt}           , 
    {"web"   , _dflt}           , 
    {"im"    , _dflt}           , 
    {"mail"  , rlayouts.max}    , 
    {nil     , rlayouts.float}  , 
    {nil     , rlayouts.float}  , 
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

-- stop describing, set tags for real now

for s = 1, scount do -- for each screen
  tags[s] = awful.tag(tags.names, s, tags.layout) -- create tags
  for i, t in ipairs(tags[s]) do -- set some properties
      awful.tag.setproperty(t , "mwfact" , i==5 and 0.13 or 0.5)
      awful.tag.setproperty(t , "hide"   , (i==6 or i==7) and true)
  end
end

-- Wibox --

-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
tzswidget = widget({ type = "textbox" })
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
}) -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, "thermal_zone0")
-- }}}

-- {{{ Battery state
baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_height(12):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  b = awful.widget.progressbar(), r = awful.widget.progressbar(),
  h = awful.widget.progressbar(), s = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(14):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
     beautiful.fg_center_widget, beautiful.fg_end_widget
  }) -- Register buttons
  w.widget:buttons(awful.util.table.join(
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
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${'..nic..' down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${'..nic..' up_kb}</span>', 3)
-- }}}

-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, texec("alsamixer") ),
   awful.button({ }, 4, sexec("amixer -q sset Master 3%+", false)),
   awful.button({ }, 5, sexec("amixer -q sset Master 3%-", false))
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%R", 61)

-- {{{ System tray
systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewnext),
    awful.button({ },        5, awful.tag.viewprev
))

for s = 1, scount do
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 12,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width
    })
    -- Add widgets to the wibox
    wibox[s].widgets = {
        {   mylauncher, separator,
            taglist[s], layoutbox[s], separator, promptbox[s],
            ["layout"] = awful.widget.layout.horizontal.leftright
        },
        s == 1 and systray or nil,
        separator, datewidget, dateicon,
        separator, volwidget,  volbar.widget, volicon,
        separator, upicon,     netwidget, dnicon,
        separator, fs.s.widget, fs.h.widget, fs.r.widget, fs.b.widget, fsicon,
        separator, membar.widget, memicon,
        separator, batwidget, baticon,
        separator, tzswidget, cpugraph.widget,-- cpuicon,
        separator, ["layout"] = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- // wibox end



-- Mouse bindings --
-- on root
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- on client
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)


-- Key bindings {{{ --

-- {{{ Global keys
globalkeys = awful.util.table.join(
    -- {{{ Applications
--    awful.key({ modkey }, "e", function () exec("emacsclient -n -c") end),
    awful.key({"Control", altkey}, "l", sexec("xlock", false) ),
    awful.key({ modkey}, "q", function () mymainmenu:show({keygrabber=true}) end),
    awful.key({ modkey}, "z", function () zicmenu:show({keygrabber=true}) end),
    awful.key({ modkey }, "t", sexec("thunar") ),
    awful.key({ modkey }, "w", sexec("chromium") ),
    awful.key({ modkey }, "Return",  sexec(term)),
    awful.key({ modkey }, "a", function () scratch.drop(term, "bottom", nil, nil, 0.30) end),
    --awful.key({ modkey }, "a", function () exec("urxvt -T Alpine -e alpine.exp") end),
    awful.key({ modkey }, "g", sexec("GTK2_RC_FILES=~/.gtkrc-gajim gajim")),
 --   awful.key({ modkey }, "q", function () exec("emacsclient --eval '(make-remember-frame)'") end),
    --awful.key({ altkey }, "#51", function () if boosk then osk(nil, mouse.screen)
--        else boosk, osk = pcall(require, "osk") end
--    end),
    -- }}}

    -- {{{ Multimedia keys
    -- awful.key({}, "#235", function () exec("kscreenlocker --forcelock") end),
    -- awful.key({}, "#121", function () exec("pvol.py -m") end),
    -- awful.key({}, "#122", function () exec("pvol.py -p -c -2") end),
    -- awful.key({}, "#123", function () exec("pvol.py -p -c  2") end),
    -- awful.key({}, "#232", function () exec("plight.py -c -10") end),
    -- awful.key({}, "#233", function () exec("plight.py -c  10") end),
    -- awful.key({}, "#165", function () exec("sudo /usr/sbin/pm-hibernate") end),
    -- awful.key({}, "#150", function () exec("sudo /usr/sbin/pm-suspend")   end),
    -- awful.key({}, "#163", function () exec("pypres.py") end),
    -- }}}
    -- ssh mgmt
 awful.key({ modkey}, "F1", function ()
	  awful.prompt.run({ prompt = "ssh: " },
	  promptbox[mouse.screen].widget,
	  function(h) texec("ssh "..h)() end,
	  function(cmd, cur_pos, ncomp)
		  -- get hosts and hostnames
		  local hosts = {}


            f = io.open(os.getenv('HOME') .. '/.ssh/config')
            while true
                do
                    line = f:read()
                    if (line == nil) then
                        break
                    end
                    for match in line:gmatch("host%s+(%S+)") do
                        if (match ~= '*') then
                            table.insert(hosts, match)
                        end
                    end
                end

		  f:close()
		  -- abort completion under certain circumstances
		  if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
		      return cmd, cur_pos
		  end
		  -- match
		  local matches = {}
		  table.foreach(hosts, function(x)
		      if hosts[x]:find("^" .. cmd:sub(1, cur_pos):gsub('[-]', '[-]')) then
		          table.insert(matches, hosts[x])
		      end
		  end)
		  -- if there are no matches
		  if #matches == 0 then
		      return cmd, cur_pos
		  end
		  -- cycle
		  while ncomp > #matches do
		      ncomp = ncomp - #matches
		  end
		  -- return match and position
		  return matches[ncomp], #matches[ncomp] + 1
	  end,
	  awful.util.getdir("cache") .. "/ssh_history")
	end),
    -- {{{ Prompt menus
    
    awful.key({ modkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
            function (...) promptbox[mouse.screen].text = exec(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ modkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, promptbox[mouse.screen].widget,
            function (words)
                exec("gnome-dictionary --look-up='"..words.."'")
            end)
    end),
    awful.key({ modkey }, "F4", function ()
        awful.prompt.run({ prompt = "Task: " }, promptbox[mouse.screen].widget,
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
        awful.prompt.run({ prompt = "Lua: " }, promptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end),
    -- }}}

    -- {{{ Awesome controls
    awful.key({ modkey }, "b", function ()
        wibox[mouse.screen].visible = not wibox[mouse.screen].visible
    end),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "r", function ()
        promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
    end),
    -- }}}

    -- {{{ Tag browsing
    awful.key({ modkey }, "Right",   awful.tag.viewnext),
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
    awful.key({ modkey }, "Left",   awful.tag.viewprev),
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
    awful.key({ altkey }, "Tab", awful.tag.history.restore),
    awful.key({modkey}, "e", revelation),
    -- }}}


    -- {{{ Layout manipulation
    awful.key({ modkey }, "l",          function () awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey }, "h",          function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "l", function () awful.client.incwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "h", function () awful.client.incwfact( 0.05) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey },          "space", function () awful.layout.inc(layouts,  1) end),
    -- }}}

    -- {{{ Focus controls
    awful.key({ modkey }, "p", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey }, "s", function () scratch.pad.toggle() end),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey }, "j", function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "k", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "Tab", function ()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    awful.key({ altkey }, "Escape", function ()
        awful.menu.menu_keys.down = { "Down", "Alt_L" }
        local cmenu = awful.menu.clients({width=230}, { keygrabber=true, coords={x=525, y=330} })
    end),
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1)  end),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end)
    )
    -- }}})
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "c", function (c) c:kill() end),
    awful.key({ modkey }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),
    awful.key({ modkey }, "o",     awful.client.movetoscreen),
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
    awful.key({ modkey, "Control"},"r", function (c) c:redraw() end),
    awful.key({ modkey, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift" }, "m", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift" }, "c", function (c) exec("kill -CONT " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "s", function (c) exec("kill -STOP " .. c.pid) end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey, "Shift" }, "f", function (c) if awful.client.floating.get(c)
        then awful.client.floating.delete(c);    awful.titlebar.remove(c)
        else awful.client.floating.set(c, true); awful.titlebar.add(c) end
    end)
)
-- }}}

-- {{{ Keyboard digits
local keynumber = 0
for s = 1, scount do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
    globalkeys = awful.util.table.join( globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end
        end),
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            local screen = mouse.screen
            if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end
        end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
function ru(c,n,prop)
        return {
            rule = {class=c, name=n},
            properties=prop,
        }
end

-- Automatic rules --

awful.rules.rules = {
    -- default rules --
    ru(nil,nil,{
        focus=true,
        size_hints_honor=false,
        keys=clientkeys,
        buttons=clientbuttons,
        border_width=beautiful.border_width,
        border_color=beautiful.border_normal
    }),
    -- standard rules --
    ru("chromium", nil, { tag = tags[1][rtagnums.web] }),
    ru("Chromium", ".*- chat -.*", { tag = tags[1][rtagnums.im] }),
    -- chat
    ru("Xchat",nil, { tag = tags[scount > 1 and 2 or 1][rtagnums.im] } ),
    -- medias
    ru("Audacious",nil, { tag = tags[scount > 1 and 2 or 1][rtagnums.media] } ),
    -- edit      
    ru("Gvim", nil, { tag = tags[1][rtagnums.edit] } ),
    ru("Snaked",nil, { tag = tags[1][rtagnums.edit] } ),
      -- fs
    ru("Geeqie",nil,{ floating = true } ),
    ru("ROX-Filer",nil,{ floating = true }),
    -- hacks --
    -- arte+7
    ru("Exe", "exe", { floating=true, fullscreen=true } ),
}

-- Manage signal handler --
client.add_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

-- Focus signal handlers --
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus  end)
client.add_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)


-- Arrange signal handler --
for s = 1, scount do screen[s]:add_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end

-- INIT some state --

awful.tag.viewonly(tags[1][3])
if (scount > 1) then
    awful.tag.viewonly(tags[2][5])
end

