local vicious = require("vicious")
local naughty = require("naughty")
local beautiful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local gears = require('gears')

function set_nic()
    nic = io.popen("netstat -rn |grep ^0.0.0.0 |awk '{print $8}'"):read()
end
local refresh_nic = gears.timer({ timeout = 1 })
function nic_display()
    local refresh_limit = 30
    refresh_nic:connect_signal("timeout", function ()
        if nic or refresh_limit == 0 then
            refresh_nic:stop()
            if refresh_limit ~= 0 then
                naughty.notify({text='Connected using '..nic})
            end
            return
        end
        set_nic()
        refresh_limit = refresh_limit - 1
    end)
    refresh_nic:stop()
    refresh_nic:start()
end
nic_display()
set_nic()

 -- shell exec
exec  = awful.spawn.with_shell

-- following returns pointer to functions, to use in menus/keys
--
 -- terminal exec
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

 -- editor exec
function eexec(w)
    local t = function()
        exec(editor_cmd .. " " .. w)
    end
    return t
end

 -- standard exec
function sexec(cmd)
    local t = function()
        exec(cmd)
    end
    return t
end

local progress_maker = function(col, width, height, ticks)
    local col = { type = "linear", from = { 0, 0}, to = { 20, 0}, stops = { {0, "#7799DD"}, {1, "#ff3333" }}}
    return wibox.widget {
        {
            shape         = gears.shape.rounded_bar,
            color = col,
            background_color = "#333",
            widget        = wibox.widget.progressbar,
        },
        forced_width  = 5,
        direction = "east",
        layout        = wibox.container.rotate,
    }
end

separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)

memicon = wibox.widget.imagebox()
memicon:buttons(PROCESS_MON_BUTTON)
memicon:set_image(beautiful.widget_mem)


--- CPU
cpugraph  = wibox.widget.graph()

local w=20
cpugraph:set_width(w)
cpugraph:set_background_color("#222222")
cpugraph:set_color({ type = "linear", from = { 0, -w/8 }, to = { w*0.7, w }, stops = { {1, "#222222"}, {0, "#ff3333" }}})
cpugraph:buttons(PROCESS_MON_BUTTON)
 -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu, "$1", 1)


--- MEMORY
--
membar = progress_maker()
membar:buttons(PROCESS_MON_BUTTON)
vicious.register(membar:get_widget(wibox.widget.progressbar), vicious.widgets.mem, "$1", 10)

---- FILESYSTEM
--
fs = {
  r = progress_maker(nil, 6),
--  h = progress_maker(nil, 6),
--  t = progress_maker(nil, 6),
}

-- Progressbar properties
for _, w in pairs(fs) do
  -- Register buttons
--  w:set_border_color('#333333')
  w:buttons(gears.table.join(
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
if true then
    vicious.register(netwidget, vicious.widgets.net, function(wid, args) 
        if nic then
            return'<span color="#FF0000">'..args['{'..nic..' down_kb}']..'</span>  ' .. nic .. '  <span color="#00FF00">'..args['{'..nic..' up_kb}']..'</span>'
          end
          return 'N/A'
      end
      , 3)
end


dnicon = wibox.widget.imagebox()
upicon = wibox.widget.imagebox()
dnicon:set_image(beautiful.widget_net)
upicon:set_image(beautiful.widget_netup)
dnicon:buttons(NETWORK_MON_BUTTON)
upicon:buttons(NETWORK_MON_BUTTON)

