WEB_BROWSER = 'chromium'
FILE_MANAGER = 'thunar'
NETWORK_MONITOR = 'sudo iptraf-ng'
PROCESS_MONITOR = 'top'
ENABLE_TITLEBARS = false

-- misc settings
IS_LAPTOP = os.execute('laptop-detect')
zic_prompt = true
editor = os.getenv("EDITOR") or "nano"
terminal = "terminator"
terminal_run = "terminator -x "
fancy_terminal = "terminator -x"
editor_cmd = 'gvim -reverse '

-- Tags --
local awful = require("awful")

-- shortcut for layouts

local _ = {
    DEFAULT = awful.layout.suit.tile      ,
    titlet  = awful.layout.suit.tile.top  ,
    titleb  = awful.layout.suit.tile.bottom,
    fair    = awful.layout.suit.fair      ,
    max     = awful.layout.suit.max       ,
    mag     = awful.layout.suit.magnifier ,
    float   = awful.layout.suit.floating  ,
    spir    = awful.layout.suit.spir      ,
}

-- all used layouts should be defined ONCE here:
-- Available layouts (override defaults)
awful.layout.layouts = {
    _.DEFAULT,
    _.titlet,
    _.mag,
    _.float,
    _.spir,
}
-- user-customizable tags: (name, layout, options)
tags = {
    {"term"  , _.titleb  , nil        },
    {"edit"  , _.DEFAULT , nil        },
    {"web"   , _.DEFAULT , nil        },
    {"im"    , _.fair, {ncol=2}   },
    {"logs"  , _.DEFAULT , {ncol=1, mwfact=0.5}   },
    {"fm"    , _.DEFAULT , nil        },
    {"gfx"   , _.mag     , nil        },
    {"media" , _.DEFAULT , nil        },
    {"toto"  , _.DEFAULT , {hide=true}}
}
_ = nil

-- wibox widgets
ENABLE_NET_WID    = true
ENABLE_CPURAM_WID = true
ENABLE_VOL_WID    = true
ENABLE_HDD_WID    = true
ENABLE_DATE_WID   = true

return _ENV
