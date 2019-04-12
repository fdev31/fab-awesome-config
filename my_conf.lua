THEME = "default"
WEB_BROWSER = 'firefox'
FILE_MANAGER = 'nautilus'
NETWORK_MONITOR = 'sudo iptraf-ng'
PROCESS_MONITOR = 'top'
ENABLE_TITLEBARS = false
ENABLE_WALLPAPER = false

-- misc settings
IS_LAPTOP = os.execute('laptop-detect')
zic_prompt = true
editor = os.getenv("EDITOR") or "nano"
terminal = "kitty"
terminal_run = "kitty -e "
fancy_terminal = "terminator -x"

editor_cmd = terminal_run .. editor

-- Tags --
local awful = require("awful")

-- shortcut for layouts
local _ = {
    title = awful.layout.suit.tile      ,
    titlet  = awful.layout.suit.tile.top  ,
    titleb  = awful.layout.suit.tile.bottom,
    titler  = awful.layout.suit.tile.right,
    titlel  = awful.layout.suit.tile.left,
    fair    = awful.layout.suit.fair      ,
    fairh    = awful.layout.suit.fair.horizontal      ,
    max     = awful.layout.suit.max       ,
    mag     = awful.layout.suit.magnifier ,
    float   = awful.layout.suit.floating  ,
    nw = awful.layout.suit.corner.nw,
    se = awful.layout.suit.corner.se,
    spir    = awful.layout.suit.spiral.dwindle ,
}

-- all used layouts should be defined ONCE here:
-- Available layouts (override defaults)
awful.layout.layouts = {
    _.title,
    _.titleb,
    _.titlel,
    _.titler,
    _.titlet,
    _.fair,
    _.fairh,
    _.mag,
    _.max,
    _.nw,
    _.se,
    _.spir,
}

-- export layout groups, used to switch layouts
my_layouts = {
    { _.spir, _.fair, _.fairh},
    { _.nw, _.titlet, _.titler},
    { _.mag, _.max },
}

_.DEFAULT = my_layouts[1][1]

-- user-customizable tags: (name, layout, options)
tags = {
    {"term"  , _.fair , nil        },
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
