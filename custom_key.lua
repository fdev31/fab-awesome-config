local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local menubar = require("menubar")
local mixer = require('ponymix')
require('custom_conf')

local selected_layout = { }

local function _set_layout(x, y)
    awful.layout.set(my_layouts[x][y])
end

local function get_cur_layout()
    local cur_t = awful.screen.focused().selected_tag
    local cur_l = selected_layout[cur_t]
    if cur_l == nil then
        cur_l = {1, 1}
        selected_layout[cur_t] = cur_l
    end
    return cur_l
end

function prev_layout_group() 
    local lay = get_cur_layout()
    if lay[1] <= 1 then
        lay[1] = #my_layouts
    else
        lay[1] = lay[1] - 1
    end
    lay[2] = 1
    _set_layout(table.unpack(lay))
end

function next_layout_group() 
    local lay = get_cur_layout()
    if lay[1] >= #my_layouts then
        lay[1] = 1
    else
        lay[1] = lay[1] + 1
    end
    lay[2] = 1
    _set_layout(table.unpack(lay))
end

function prev_layout() 
    local lay = get_cur_layout()
    if lay[2] <= 1 then
        lay[2] = #my_layouts[lay[1]]
    else
        lay[2] = lay[2] - 1
    end
    _set_layout(table.unpack(lay))
end

function next_layout() 
    local lay = get_cur_layout()
    if lay[2] >= #my_layouts[lay[1]] then
        lay[2] = 1
    else
        lay[2] = lay[2] + 1
    end
    _set_layout(table.unpack(lay))
end

function c_grabnext(screen)
    local c = client.focus
    if c == nil then return end
    local r = c_viewnext()
    c:tags({awful.screen.focused().selected_tag})
    return r
end

function c_grabprev(screen)
    local c = client.focus
    if c == nil then return end
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
    awful.key({ }, "XF86AudioPrev", sexec('playerctl previous')),
    awful.key({ }, "XF86AudioNext", sexec('playerctl next')),
    awful.key({ }, "XF86AudioPlay", sexec('playerctl play-pause')),

    awful.key({ }, "XF86AudioLowerVolume", function() mixer.down() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioRaiseVolume", function() mixer.up() vicious.force(vicious.widgets.volume) end),
    awful.key({ }, "XF86AudioMute", mixer.toggle),
    awful.key({ }, "XF86MonBrightnessUp", backlight.up),
    awful.key({ }, "XF86MonBrightnessDown", backlight.down),

    awful.key({ modkey ,           } , "Left"  , c_viewprev ,{description = "view previous", group = "tag"})         ,
    awful.key({ modkey ,           } , "Right" , c_viewnext ,{description = "view next", group = "tag"})         ,
    awful.key({ modkey , "Shift"   } , "Right" , c_grabnext, {description = "move to next tag", group = "client"})         ,
    awful.key({ modkey , "Shift"   } , "Left"  , c_grabprev ,{description = "move to previous tag", group = "client"})         ,
--    awful.key({ modkey , "Control+Shift"   } , "l"     , sexec('screenlocker.sh'), {description="lock", group="screen"}) ,
    awful.key({ modkey             } , "t"     , sexec(FILE_MANAGER), {description="open file manager", group="launcher"} )    ,
    awful.key({ modkey             } , "w"     , sexec(WEB_BROWSER) , {description="open Web browser", group="launcher"}) ,
    awful.key({ modkey             } , "Up"    , function() if client.focus then client.focus.opacity = math.min(1, client.focus.opacity + 0.05) end end, {description="more opacity", group="client"})    ,
    awful.key({ modkey             } , "Down"  , function() if client.focus then client.focus.opacity = math.max(0.1, client.focus.opacity - 0.05) end end, {description="less opacity", group="client"} ) ,

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
