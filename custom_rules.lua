local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require('custom_conf')

local TRANS_LEVEL = 0.8

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

    ru("terminology", nil,         { opacity=TRANS_LEVEL, fixed_trans=true }),
    -- standard rules --
    -- volume properties
    ru(nil, ".* volume.*",         { floating=true, fullscreen=false}),
    ru(nil, "alsamixer",           { floating=true, fullscreen=false}),
    -- www 
    ru("Chromium", nil,            { tag=awful.tag.gettags(S_MAIN)[rtagnums.web] }),
    ru("Chromium", ".*- chat -.*", { tag=awful.tag.gettags(S_MAIN)[rtagnums.im] }),
    ru("Firefox", nil,         { tag=awful.tag.gettags(S_MAIN)[rtagnums.web] }),
    -- chat
    ru("Xchat", nil,               { tag=awful.tag.gettags(S_SEC)[rtagnums.im] } ),
    -- medias
    ru("Audacious", nil,           { tag=awful.tag.gettags(S_SEC)[rtagnums.media] } ),
    -- edit
    ru("Gvim", nil,                { tag=awful.tag.gettags(S_MAIN)[rtagnums.edit] } ),
    ru("jetbrains-pycharm-ce", nil,{ tag=awful.tag.gettags(S_MAIN)[rtagnums.edit] } ),
    ru("Snaked", nil,              { tag=awful.tag.gettags(S_MAIN)[rtagnums.edit] } ),
    -- gfx
    ru("Blender", nil,             { tag=awful.tag.gettags(S_MAIN)[rtagnums.gfx], floating=true, fullscreen=true } ),
    ru("Blender", "Blender",       { floating=true, fullscreen=true}),
    ru("Gimp", nil,                { tag=awful.tag.gettags(S_MAIN)[rtagnums.gfx] } ),
    -- sound
    ru("Rdio", nil,                { tag=awful.tag.gettags(S_SEC)[rtagnums.media] } ),
    -- fs
    ru("Geeqie", nil,              { floating=true } ),
    ru("ROX-Filer", nil,           { floating=true }),
    -- hacks --
    -- flashplugin
    ru("Exe", "exe",               { floating=true, fullscreen=true } ),
    ru("Plugin-container", nil,    { floating=true, fullscreen=true } )
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
