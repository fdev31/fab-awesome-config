local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local menubar = require("menubar")
local mixer = require('ponymix')
require('custom_conf')

function c_grabnext(screen)
    local c = client.focus
    local r = c_viewnext()
    c:tags({awful.screen.focused().selected_tag})
    return r
end

function c_grabprev(screen)
    local c = client.focus
    local r = c_viewprev()
    c:tags({awful.screen.focused().selected_tag})
    return r
end

function c_viewnext(screen)
    return awful.tag.viewnext(awful.screen.focused())
end

function c_viewprev()
    return awful.tag.viewprev(awful.screen.focused())
end

local k = {
    awful.key({ }, "XF86AudioLowerVolume", function() mixer.down() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioRaiseVolume", function() mixer.up() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioMute", mixer.toggle),
-- CUSTO
    awful.key({ }, "XF86MonBrightnessUp", backlight.up),
    awful.key({ }, "XF86MonBrightnessDown", backlight.down),

    awful.key({ modkey ,           } , "Left"  , c_viewprev ,{description = "view previous", group = "tag"})         ,
    awful.key({ modkey ,           } , "Right" , c_viewnext ,{description = "view next", group = "tag"})         ,
    awful.key({ modkey , "Shift"   } , "Right" , c_grabnext, {description = "move to next tag", group = "client"})         ,
    awful.key({ modkey , "Shift"   } , "Left"  , c_grabprev ,{description = "move to previous tag", group = "client"})         ,
    awful.key({ modkey , "Shift"   } , "l"     , sexec('screenlocker.sh'), {description="lock", group="screen"}) ,
    awful.key({ modkey             } , "t"     , sexec(FILE_MANAGER), {description="open file manager", group="launcher"} )    ,
    awful.key({ modkey             } , "w"     , sexec(WEB_BROWSER) , {description="open Web browser", group="launcher"}) ,
    awful.key({ modkey             } , "Up"    , function() client.focus.opacity = math.min(1, client.focus.opacity + 0.05) end, {description="more opacity", group="client"})    ,
    awful.key({ modkey             } , "Down"  , function() client.focus.opacity = math.max(0.1, client.focus.opacity - 0.05) end, {description="less opacity", group="client"} ) ,

    awful.key({ modkey } , "p", function ()
        screen_switched = true awful.screen.focus_relative( 1)
    end, {description="Switch screen", group="client"}),
    awful.key({ modkey }, "F2", function()
        menubar.show()
    end, {description="Launch app", group="launcher"}),
    awful.key({ modkey }, "q", function ()
        mymainmenu:show({keygrabber=true})
    end, {description="Show menu", group="awesome"}),
    awful.key({ modkey }, "z", function ()
        if( not zic_prompt) then zicmenu:show({keygrabber=true}) end
    end),
    awful.key({ modkey }, "e", function()
        awful.menu.clients({ width=250 })
    end, {description="list", group="client"}),
    awful.key({ modkey }, "a", function ()
        drop(fancy_terminal, "bottom", "center", 0.9, 0.9, false)
    end, {description="Popup term", group="launcher"}),
}
return {keys = k}
