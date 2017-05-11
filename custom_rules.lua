local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

local TRANS_LEVEL = 0.8

function ru(c,n,prop, callback)
        local p = {
            rule = {class=c, name=n},
            properties=prop,
        }
        if callback then
            p.callback = callback
        end
        return p
end

local rules = {
{ rule_any = {
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
      }, properties = { floating = true }},

    { rule_any = {type = { "normal", "dialog" }
  }, properties = { titlebars_enabled = ENABLE_TITLEBARS}
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
    -- www
    {
        rule = {class="Chromium", role="GtkFileChooserDialog"},
        properties={floating=true, sticky=true},
        callback = function (c)
            awful.placement.centered(c, nil)
            awful.client.movetotag(awful.tag.selected(mouse.screen), c)
        end
    },
    ru("Chromium", nil,            { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Chromium", ".*- chat -.*", { tag=awful.tag.gettags(S_MAIN)[tagidx.im] }),
    ru("Franz", "Franz",            { tag=awful.tag.gettags(S_MAIN)[tagidx.im] }),
    ru("Chromium", "Floating YouTube.*", { opacity=1.0, fixed_trans=true, floating=true, sticky=true }),
    ru("Firefox", nil,             { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Midori", nil,              { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    ru("Pale moon", nil,           { tag=awful.tag.gettags(S_MAIN)[tagidx.web] }),
    -- chat
    ru("Xchat", nil,               { tag=awful.tag.gettags(S_SEC)[tagidx.im] } ),
    ru("Thunderbird", nil,         { tag=awful.tag.gettags(S_SEC)[tagidx.im] } ),
    -- medias
    ru("Audacious", nil,           { tag=awful.tag.gettags(S_SEC)[tagidx.media] } ),
    ru("Midori", ".* – Rdio",      { tag=awful.tag.gettags(S_SEC)[tagidx.web] } ),

    -- edit
    ru("Gvim", nil,                { tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    ru("jetbrains-pycharm-ce", nil,{ tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    ru("Snaked", nil,              { tag=awful.tag.gettags(S_MAIN)[tagidx.edit] } ),
    -- gfx
    ru("Blender", nil,             { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    ru("Inkscape", nil,            { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    ru("Gimp", nil,                { tag=awful.tag.gettags(S_MAIN)[tagidx.gfx] } ),
    -- sound
    ru("Rdio", nil,                { tag=awful.tag.gettags(S_SEC)[tagidx.media] } ),
    -- fs
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } ),
    -- logging xterm
    ru('TermLog', nil, {tag=awful.tag.gettags(S_SEC)[tagidx.logs], opacity=0.7 } ),
    ru("Pcmanfm","Execute File", { floating = true, sticky = true, ontop = true, above = true }, awful.placement.centered),
--    ru("Geeqie", nil,              { floating=true } ),
    -- geeqie
    { match = { "Full screen...Geeqie"              },  intrusive = true, border_width = 0, fullscreen = 1, ontop=true },
    { match = { "Tools...Geeqie"                    },
      keys = awful.util.table.join(awful.key({}, "Escape", function(c)  getclient("id", c.group_id + 2):kill() end))   },
}

--client.connect_signal("unfocus", function (c) c.opacity = TRANS_LEVEL end)
--client.connect_signal("focus", function (c) if not c.fixed_trans then c.opacity = 1.0 end end)

-- arrange handler

for s = 1, scount do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end


return {
    rules = rules
}
