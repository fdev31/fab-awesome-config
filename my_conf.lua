THEME = "default"
WEB_BROWSER = 'firefox'
FILE_MANAGER = 'pcmanfm'
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

editor_cmd = terminal_run .. editor

-- Tags --
local awful = require("awful")

-- shortcut for layouts
--
-- TODO: <meta+v> = "next" layout's alternative
--
-- groups:
-- awful.layout.suit.corner.nw, awful.layout.suit.corner.ne, awful.layout.suit.corner.sw, awful.layout.suit.corner.se
--
-- awful.layout.suit.max.name, awful.layout.suit.max.fullscreen
--
-- awful.layout.suit.spiral.dwindle, awful.layout.suit.spiral.name
-- awful.layout.suit.tile.right, left, bottom, top...

local my_layouts = {
    { awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.tile.left, awful.layout.suit.tile.top},
--    { awful.layout.suit.floating},
    { awful.layout.suit.fair, awful.layout.suit.fair.horizontal, awful.layout.suit.spiral, awful.layout.suit.spiral.dwindle},
    { awful.layout.suit.max, awful.layout.suit.max.fullscreen, awful.layout.suit.magnifier},
    { awful.layout.suit.corner.nw, awful.layout.suit.corner.ne, awful.layout.suit.corner.sw, awful.layout.suit.corner.se}
}

-- TODO: adapt to real screen count
local selected_layout = {
    {1, 1},
    {1, 1},
    {1, 1},
    {1, 1}
}
local selected_layout = {1,1}

local function _set_layout(x, y)
    awful.layout.set(my_layouts[x][y])
end

local function get_cur_layout()
    local cur_t = awful.tag.selected()
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
--    lay[2] = 1
    _set_layout(table.unpack(lay))
end

function next_layout_group() 
    local lay = get_cur_layout()
    if lay[1] >= #my_layouts then
        lay[1] = 1
    else
        lay[1] = lay[1] + 1
    end
--    lay[2] = 1
    _set_layout(table.unpack(lay))
end

function prev_layout() 
    local lay = get_cur_layout()
    if lay[2] >= 1 then
        lay[2] = #my_layouts[lay[1]]
    else
        lay[2] = lay[2] - 1
    end
    _set_layout(table.unpack(lay))
end

function next_layout() 
    local lay = get_cur_layout()
    if lay[2] == #my_layouts[lay[1]] then
        lay[2] = 1
    else
        lay[2] = lay[2] + 1
    end
    _set_layout(table.unpack(lay))
end

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
