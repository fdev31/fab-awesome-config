local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")

local progress_maker = function(col)
    local color = col or color
    local bar    = awful.widget.progressbar()
    -- Progressbar properties
    bar:set_vertical(true):set_ticks(true)
    bar:set_height(10):set_width(8):set_ticks_size(1)
    bar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, color.red }, { 0.5, color.green }, { 1, color.yellow }} })
    return bar
end

mywibox = {}
-- CUSTOM
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
    awful.button({ }, 1, sexec(FILE_MANAGER) )
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
local volbar    = progress_maker({yellow='#555555', green='#00AA00', red='#00FF00'})
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
-- END OF CUSTO
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
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(separator)
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
    if s == S_MAIN then right_layout:add(wibox.widget.systray()) end

-- CUSTO
    right_layout:add(volicon)
    right_layout:add(volwidget)
    right_layout:add(volbar)
    right_layout:add(separator)
    right_layout:add(mytextclock)
    right_layout:add(memicon)
    right_layout:add(membar)
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
    right_layout:add(separator)
    right_layout:add(cpugraph)

    if IS_LAPTOP then
        right_layout:add(baticon)
    end
-- END OF CUSTO
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
