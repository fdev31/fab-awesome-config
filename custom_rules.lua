local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
require('custom_conf')

local TRANS_LEVEL = 0.8

local S_MAIN = 1
local S_SEC = 2

function getScreen(sym)
    if sym == S_MAIN then
        return screen.primary
    end
    return awful.screen.focused()
end


--returns a rule for the given:
--class(c)
--name(n)
--set properties(prop)
function ru(c,n,prop)
    local p = {
        rule = {class=c, name=n},
        properties=prop,
    }
    -- if there is a tag, get it dynamically to get the correct screen
    if prop.tag ~= nil then
        local screenidx = prop.tag[1]
        local tagname = prop.tag[2]
        p.callback = function(c)
            local tag = getScreen(screenidx).tags[tagidx[tagname]]
            c:tags({tag})
        end
        prop.tag = nil
    end
    return p
end

local rules = {
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Arandr",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer"},
                name = {
                    "Event Tester",  -- xev.
                },
                role = {
                    "AlarmWindow",  -- Thunderbird's calendar.
                    "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
                }
            },
            properties = { floating = true }
        }, 
        {
            rule_any = {type = { "normal", "dialog" } },
            properties = { titlebars_enabled = ENABLE_TITLEBARS} 
        },

    ru(nil,nil,{ -- defaults
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = clientkeys,
          buttons = clientbuttons,
          screen = awful.screen.preferred,
          placement = awful.placement.no_overlap+awful.placement.no_offscreen
    }),
    ru(nil, "CGM-rc-Heli-Simulator", {floating=false, fullscreen=false}),
    -- standard rules --
    -- volume properties
    ru("[pP]avucontrol", ".* volume.*",         { floating=true, fullscreen=false}),
    ru("Steam", "Steam - News",         { floating=true, fullscreen=false, ontop=true}),
    ru(nil, "alsamixer",           { width=100, floating=true}, awful.placement.under_mouse),
    -- term
--    ru("terminology", nil,         { opacity=TRANS_LEVEL, fixed_trans=true }),
    ru("code-oss", nil,            { tag={S_MAIN, 'edit'} }),

    ru("Chromium", nil,            { tag={S_MAIN, 'web'} }),
    ru("Chromium", "Skype - .*", { tag={S_MAIN, 'im'} } ),
    ru("Chromium", ".*- chat -.*", { tag={S_MAIN, 'im'} }),
    ru("Chromium", ".*- Flowdock",            { tag={S_SEC, 'im'}, floating=false }),
    ru("Chromium", ".*- Outlook Web App -.*",  { tag={S_SEC, 'im'}, floating=false }),
    ru("Chromium", "Floating YouTube.*", { opacity=1.0, fixed_trans=true, floating=true, sticky=true }),

    ru("Google-chrome", nil,            { tag={S_MAIN, 'web'} }),
    ru("Google-chrome", "Skype - .*", { tag={S_MAIN, 'im'} } ),
    ru("Google-chrome", ".*- chat -.*", { tag={S_MAIN, 'im'} }),
    ru("Google-chrome", ".*- Flowdock",            { tag={S_SEC, 'im'}, floating=false }),
    ru("Google-chrome", ".*- Outlook Web App -.*",  { tag={S_SEC, 'im'}, floating=false }),
    ru("Google-chrome", "Floating YouTube.*", { opacity=1.0, fixed_trans=true, floating=true, sticky=true }),

    ru("Firefox", nil,            { tag={S_MAIN, 'web'} }),
    ru("Firefox", "Skype - .*", { tag={S_MAIN, 'im'} } ),
    ru("Firefox", ".*- chat -.*", { tag={S_MAIN, 'im'} }),
    ru("Firefox", ".*- Flowdock",            { tag={S_SEC, 'im'}, floating=false }),
    ru("Firefox", ".*- Outlook Web App -.*",  { tag={S_SEC, 'im'}, floating=false }),
    ru("Firefox", "Floating YouTube.*", { opacity=1.0, fixed_trans=true, floating=true, sticky=true }),

    ru("Midori", nil,              { tag={S_MAIN, 'web'} }),
    ru("Pale moon", nil,           { tag={S_MAIN, 'web'} }),


    ru("Skype", nil,            { tag={S_SEC, 'im'}, floating=false }),
    ru("Franz", "Franz",            { tag={S_MAIN, 'im'} }),
    -- chat
    ru("Xchat", nil,               { tag={S_SEC, 'im'} } ),
    ru("Thunderbird", nil,         { tag={S_SEC, 'im'} } ),
    -- medias
    ru("Audacious", nil,           { tag={S_SEC, 'media'} } ),
    ru("Midori", ".* – Rdio",      { tag={S_SEC, 'web'} } ),

    -- edit
    ru("Gvim", nil,                { tag={S_MAIN, 'edit'} } ),
    ru("jetbrains-pycharm-ce", nil,{ tag={S_MAIN, 'edit'} } ),
    ru("Snaked", nil,              { tag={S_MAIN, 'edit'} } ),
    -- gfx
    ru("Blender", nil,             { tag={S_MAIN, 'gfx'} } ),
    ru("Inkscape", nil,            { tag={S_MAIN, 'gfx'} } ),
    ru("Gimp", nil,                { tag={S_MAIN, 'gfx'} } ),
    -- fs
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } ),
    -- logging xterm
    ru('TermLog', nil, {tag={S_SEC, 'logs'}, opacity=0.7 } ),
    ru("Pcmanfm","Execute File", { floating = true, sticky = true, ontop = true, above = true }, awful.placement.centered),
    ru("Kupfer.py","Kupfer", { floating = true, sticky = true, ontop = true, above = true }, awful.placement.centered),
    {
        rule = {class=nil, role="GtkFileChooserDialog"},
        properties={floating=true, sticky=true},
        callback = function (c)
            awful.placement.centered(c, nil)
            awful.client.movetotag(selected(mouse.screen), c)
        end
    },
    -- geeqie
    { match = { "Full screen...Geeqie"              },  intrusive = true, border_width = 0, fullscreen = 1, ontop=true },
    { match = { "Tools...Geeqie"                    },
      keys = gears.table.join(awful.key({}, "Escape", function(c)  getclient("id", c.group_id + 2):kill() end))   },
}

--client.connect_signal("unfocus", function (c) c.opacity = TRANS_LEVEL end)
--client.connect_signal("focus", function (c) if not c.fixed_trans then c.opacity = 1.0 end end)

-- arrange handler

for s = 1, scount do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   c.floating or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end


return {
    rules = rules
}
