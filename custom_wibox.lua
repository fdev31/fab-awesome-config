local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
-- Setup mixer object
--
--local mixer = require('amixer')
local mixer = require('ponymix')

local FM_BUTTON = awful.util.table.join( awful.button({ }, 1, sexec(FILE_MANAGER) ))
local PROCESS_MON_BUTTON = awful.util.table.join( awful.button({ }, 1, texec(PROCESS_MONITOR) ))
local NETWORK_MON_BUTTON = awful.util.table.join( awful.button({ }, 1, texec(NETWORK_MONITOR) ))
local MIXER_BUTTON = awful.util.table.join(
   awful.button({ }, 1, sexec("pavucontrol") ),
   awful.button({ }, 4, function() mixer.up() vicious.force({volwidget, volbar}) end ),
   awful.button({ }, 5, function() mixer.down() vicious.force({volwidget, volbar}) end )
)


mywibox = {}

separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)

require('custom_widgets')

-- {{{ CPU usage and temperature
-- Initialize widgets
-- }}}

if IS_LAPTOP then -- Battery
    local batname = io.popen("ls -d /sys/class/power_supply/BAT* | sed 's/.*\\///'"):read()
    -- {{{ Battery state
    baticon = wibox.widget.imagebox()
    baticon:set_image(beautiful.widget_bat)
    -- Initialize widget
    batwidget = wibox.widget.textbox()
    -- Register widget
    vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, batname)
    -- }}}
end

-- {{{ Memory usage
local memicon = wibox.widget.imagebox()
memicon:buttons(PROCESS_MON_BUTTON)
memicon:set_image(beautiful.widget_mem)
-- Initialize widget
--

-- {{{ File system usage
local fsicon = wibox.widget.imagebox()
-- Initialize widgets
fsicon:set_image(beautiful.widget_fs)
fsicon:buttons(FM_BUTTON)
-- }}}

-- {{{ Network usage
local dnicon = wibox.widget.imagebox()
local upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
dnicon:buttons(NETWORK_MON_BUTTON)
upicon:buttons(NETWORK_MON_BUTTON)
-- Initialize widget


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
-- CUSTO
    if not ENABLE_TITLEBARS then
        right_layout:add(separator)
    end

    if ENABLE_NET_WID then
        right_layout:add(dnicon)
        right_layout:add(netwidget)
        right_layout:add(upicon)
        right_layout:add(separator)
    end

    if ENABLE_CPURAM_WID then
        right_layout:add(membar)
        right_layout:add(cpugraph)
        if IS_LAPTOP then
            right_layout:add(baticon)
            right_layout:add(batwidget)
        end
        right_layout:add(separator)
    end


    if ENABLE_HDD_WID then
        right_layout:add(fsicon)
        right_layout:add(fs.r)
--        right_layout:add(fs.h)
--        right_layout:add(fs.t)
        right_layout:add(separator)
    end

    if ENABLE_DATE_WID then
        right_layout:add(mytextclock)
        right_layout:add(separator)
    end

    if s == S_MAIN then right_layout:add(wibox.widget.systray()) end

-- END OF CUSTO
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    if not ENABLE_TITLEBARS then
        layout:set_middle(mytasklist[s])
    end
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
