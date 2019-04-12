--
-- Shortcuts for Window clients
--

require('custom_conf')


function c_grabnext(c)
    local r = c_viewnext()
    c:tags({awful.screen.focused().selected_tag})
    return r
end

function c_grabprev(c)
    local r = c_viewprev()
    c:tags({awful.screen.focused().selected_tag})
    return r
end

local awful = require("awful")
local k = {
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey , "Shift"   } , "Right" , c_grabnext, {description = "move to next tag", group = "client"})         ,
    awful.key({ modkey , "Shift"   } , "Left"  , c_grabprev ,{description = "move to previous tag", group = "client"})         ,
}
return {keys = k}
