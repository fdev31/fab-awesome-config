local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local menubar = require("menubar")
require('custom_conf')


local k = {
-- CUSTO
    awful.key({ modkey }, "F2", function() menubar.show() end),
    awful.key({ }, "XF86MonBrightnessUp", backlight.up),
    awful.key({ }, "XF86MonBrightnessDown", backlight.down),
-- move client to tags
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
    awful.key({ modkey,           }, "p", function () screen_switched = true awful.screen.focus_relative( 1) end),
    awful.key({ modkey }, "y", sexec('synapse')),
    awful.key({ "Control", "Shift"}, "l", sexec('slock')),

    awful.key({ modkey}, "q", function () mymainmenu:show({keygrabber=true}) end),
    awful.key({ modkey}, "z", function () if( not zic_prompt) then zicmenu:show({keygrabber=true}) end end),
    awful.key({ modkey }, "t", sexec("thunar") ),
    awful.key({ modkey }, "w", sexec(WEB_BROWSER) ),
    awful.key({ modkey }, "e", function() awful.menu.clients({ width=250 }) end ),
    awful.key({ modkey }, "a", function () drop(fancy_terminal, "bottom", "center", 0.9, 0.9, false) end),
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
    -- FUNCTION KEYS
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
}
return {keys = k}
