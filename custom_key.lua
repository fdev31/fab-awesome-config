local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local menubar = require("menubar")
local mixer = require('ponymix')
require('custom_conf')

function c_grabnext(screen)
    return c_viewidx(1, screen, true)
end
function c_grabprev(screen)
    return c_viewidx(-1, screen, true)
end
function c_viewnext(screen)
    return c_viewidx(1, screen)
end
function c_viewprev(screen)
    return c_viewidx(-1, screen)
end

function c_viewidx(i, screen_id, grab_client)
    local screen_id = screen_id or mouse.screen
    local tags = awful.tag.gettags(screen_id)
    local current = awful.tag.getidx()

    local all_tags = {}
    local last_visible = nil

    for k, t in ipairs(tags) do
        local h = awful.tag.getproperty(t, "hide")
        table.insert(all_tags, {hidden=h, left_visible=last_visible})
        if not h then
            last_visible = k
        end
    end
    local rightmost = all_tags[#all_tags].hidden and all_tags[#all_tags].left_visible or #all_tags
    for k, t in ipairs(all_tags) do
        if t.left_visible == nil then
            t.left_visible = rightmost
        end
    end

    last_visible = nil
    for k=#all_tags, 1, -1 do
        local t = all_tags[k]
        t.right_visible = last_visible
        if not t.hidden then
            last_visible = k
        end
    end

    local leftmost = all_tags[1].hidden and all_tags[1].right_visible or 1
    for k=#all_tags, 1, -1 do
        local t = all_tags[k]
        if t.right_visible == nil then
            t.right_visible = leftmost
        end
    end

    if i > 0 then
        i = all_tags[current].right_visible
    else
        i = all_tags[current].left_visible
    end

    if grab_client then
        awful.client.movetotag(tags[i])
    end

    awful.tag.viewnone(screen_id)
    tags[i].selected = true

    screen[screen_id]:emit_signal("tag::history::update")

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
--    awful.key({ modkey             } , "y"     , sexec('synapse'))    ,
    awful.key({ "Control", "Shift" } , "l"     , sexec('screenlocker.sh'), {description="lock", group="screen"}) ,
    awful.key({ modkey             } , "t"     , sexec(FILE_MANAGER), {description="open file manager", group="launcher"} )    ,
    awful.key({ modkey             } , "w"     , sexec(WEB_BROWSER) , {description="open Web browser", group="launcher"}) ,
    awful.key({ modkey             } , "Up"    , sexec('compton-trans -c +5') , {description="more opacity", group="client"})    ,
    awful.key({ modkey             } , "Down"  , sexec('compton-trans -c -- -5'), {description="less opacity", group="client"} ) ,

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
