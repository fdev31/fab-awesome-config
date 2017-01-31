local awful = require("awful")
local wibox = require("wibox")

local gears = require('gears')

local progress_maker = function(col, width, height, ticks)
    return wibox.widget {
        {
            shape         = gears.shape.rounded_bar,
            color = "#5599FF",
            background_color = "#020202",
            widget        = wibox.widget.progressbar,
        },
        forced_width  = 5,
        direction = "east",
        layout        = wibox.container.rotate,
    }
end

--- CPU
cpugraph  = awful.widget.graph()

local w=20
cpugraph:set_width(w)
cpugraph:set_background_color("#222222")
cpugraph:set_color({ type = "linear", from = { 0, -w/8 }, to = { w*0.2, w/2 }, stops = { {1, "#7799DD"}, {0, "#ff3333" }}})
cpugraph:buttons(PROCESS_MON_BUTTON)
 -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")


--- MEMORY
--
membar = progress_maker()
membar:buttons(PROCESS_MON_BUTTON)
vicious.register(membar:get_widget(wibox.widget.progressbar), vicious.widgets.mem, "$1", 10)

---- FILESYSTEM
--
fs = {
  r = progress_maker(nil, 6),
  h = progress_maker(nil, 6),
  t = progress_maker(nil, 6),
}

-- Progressbar properties
for _, w in pairs(fs) do
  -- Register buttons
--  w:set_border_color('#333333')
  w:buttons(awful.util.table.join(
    awful.button({ }, 1, sexec(FILE_MANAGER) )
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r:get_widget(wibox.widget.progressbar), vicious.widgets.fs, "${/ used_p}",     30)
--vicious.register(fs.h, vicious.widgets.fs, "${/tmp used_p}", 30)
--vicious.register(fs.t, vicious.widgets.fs, "${/home used_p}", 30)
--
----- NETWORK


netwidget = wibox.widget.textbox()
netwidget:buttons(NETWORK_MON_BUTTON)
-- Register widget
if ENABLE_NET_WID then
    vicious.register(netwidget, vicious.widgets.net, function(wid, args) 
        if nic then
            return'<span color="'
              .. color.yellow .. '">'..args['{'..nic..' down_kb}']..'</span>  ' .. nic .. '  <span color="'
              .. color.green ..'">'..args['{'..nic..' up_kb}']..'</span>'
          end
          return 'N/A'
      end
      , 3)
end

