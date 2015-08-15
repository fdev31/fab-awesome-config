local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

function ru(c,n,prop)
        return {
            rule = {class=c, name=n},
            properties=prop,
        }
end

local rules = {
    ru(nil,nil,{
        focus            = true,
        size_hints_honor = false,
        keys             = clientkeys,
        buttons          = clientbuttons,
        border_width     = beautiful.border_width,
        border_color     = beautiful.border_normal
    }),
    {
        { name = "alsamixer" },
        properties = {
            floating = true,
            width = 100
        },
        callback = awful.placement.under_mouse
    },

    -- standard rules --
    -- volume properties
    ru(nil, ".* volume.*",         { floating=true, fullscreen=false}),
    ru(nil, "alsamixer",           { floating=true, fullscreen=false}),
    -- www 
    ru("Chromium", nil,            { tag=tags[S_MAIN][rtagnums.web] }),
    ru("Chromium", ".*- chat -.*", { tag=tags[S_MAIN][rtagnums.im] }),
    ru("Firefox", nil,         { tag=tags[S_MAIN][rtagnums.web] }),
    -- chat
    ru("Xchat", nil,               { tag=tags[S_SEC][rtagnums.im] } ),
    -- medias
    ru("Audacious", nil,           { tag=tags[S_SEC][rtagnums.media] } ),
    -- edit
    ru("Gvim", nil,                { tag=tags[S_MAIN][rtagnums.edit] } ),
    ru("jetbrains-pycharm-ce", nil,{ tag=tags[S_MAIN][rtagnums.edit] } ),
    ru("Snaked", nil,              { tag=tags[S_MAIN][rtagnums.edit] } ),
    -- gfx
    ru("Blender", nil,             { tag=tags[S_MAIN][rtagnums.gfx], floating=true, fullscreen=true } ),
    ru("Blender", "Blender",       { floating=true, fullscreen=true}),
    ru("Gimp", nil,                { tag=tags[S_MAIN][rtagnums.gfx] } ),
    -- sound
    ru("Rdio", nil,                { tag=tags[S_SEC][rtagnums.media] } ),
    -- fs
    ru("Geeqie", nil,              { floating=true } ),
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } )
}

-- Focus signal handlers --
client.connect_signal("focus",   function (c)
    c.opacity = 1
end)
client.connect_signal("unfocus", function (c)
    if screen_switched then
        screen_switched = false
    else
        c.opacity = 0.85
    end
end)

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
