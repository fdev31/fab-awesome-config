local beautiful = require("beautiful")
local awful = require("awful")

beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- THEME DEFINITION

beautiful.confdir       = awful.util.getdir("config")
beautiful.wallpaper = '/home/fab/Images/awesome_bg.jpg'
-- }}}


-- {{{ Styles
beautiful.font      = "Profont 8"

-- {{{ Colors
beautiful.fg_normal = "#DCDCCC"
beautiful.fg_focus  = "#F0DFAF"
beautiful.fg_urgent = "#CC9392"
beautiful.bg_normal = "#3F3F3F"
beautiful.bg_focus  = "#1E2320"
beautiful.bg_urgent = beautiful.bg_normal
-- }}}

-- {{{ Borders
beautiful.border_width  = 1
beautiful.border_white  = "#6F6F6F"
beautiful.border_focus = "#CD0000"
beautiful.border_normal = beautiful.bg_normal
beautiful.border_marked = beautiful.fg_urgent
-- }}}

-- {{{ Titlebars
beautiful.titlebar_bg_focus  = beautiful.bg_normal
beautiful.titlebar_bg_normal = beautiful.bg_normal
-- beautiful.titlebar_[normal|focus]
-- }}}

-- {{{ Widgets
beautiful.fg_widget        = "#AECF96"
beautiful.fg_center_widget = "#88A175"
beautiful.fg_end_widget    = "#FF5656"
beautiful.fg_off_widget    = "#494B4F"
beautiful.fg_netup_widget  = "#7F9F7F"
beautiful.fg_netdn_widget  = beautiful.fg_urgent
beautiful.bg_widget        = beautiful.bg_normal
beautiful.border_widget    = beautiful.bg_normal
-- }}}

-- {{{ Mouse finder
beautiful.mouse_finder_color = beautiful.fg_urgent
-- beautiful.mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Tooltips
-- beautiful.tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- }}}

-- {{{ Taglist and Tasklist
-- beautiful.[taglist|tasklist]_[bg|fg]_[focus|urgent]
-- }}}

-- {{{ Menu
-- beautiful.menu_[bg|fg]_[normal|focus]
-- beautiful.menu_[height|width|border_color|border_width]
-- }}}
-- }}}


-- {{{ Icons
--
-- {{{ Taglist icons
beautiful.taglist_squares_sel   = beautiful.confdir .. "/icons/taglist/sel.png"
beautiful.taglist_squares_unsel = beautiful.confdir .. "/icons/taglist/unsel.png"
--beautiful.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc icons
--beautiful.awesome_icon           = beautiful.confdir .. "/icons/awesome.png"
--beautiful.menu_submenu_icon      = "/usr/share/awesome/themes/default/submenu.png"
--beautiful.tasklist_floating_icon = "/usr/share/awesome/themes/default/tasklist/floatingw.png"
-- }}}

-- {{{ Layout icons
beautiful.layout_tile       = beautiful.confdir .. "/icons/layouts/tile.png"
beautiful.layout_tileleft   = beautiful.confdir .. "/icons/layouts/tileleft.png"
beautiful.layout_tilebottom = beautiful.confdir .. "/icons/layouts/tilebottom.png"
beautiful.layout_tiletop    = beautiful.confdir .. "/icons/layouts/tiletop.png"
beautiful.layout_fairv      = beautiful.confdir .. "/icons/layouts/fairv.png"
beautiful.layout_fairh      = beautiful.confdir .. "/icons/layouts/fairh.png"
beautiful.layout_spiral     = beautiful.confdir .. "/icons/layouts/spiral.png"
beautiful.layout_dwindle    = beautiful.confdir .. "/icons/layouts/dwindle.png"
beautiful.layout_max        = beautiful.confdir .. "/icons/layouts/max.png"
beautiful.layout_fullscreen = beautiful.confdir .. "/icons/layouts/fullscreen.png"
beautiful.layout_magnifier  = beautiful.confdir .. "/icons/layouts/magnifier.png"
beautiful.layout_floating   = beautiful.confdir .. "/icons/layouts/floating.png"
-- }}}

-- {{{ Widget icons
beautiful.widget_cpu    = beautiful.confdir .. "/icons/cpu.png"
beautiful.widget_bat    = beautiful.confdir .. "/icons/bat.png"
beautiful.widget_mem    = beautiful.confdir .. "/icons/mem.png"
beautiful.widget_fs     = beautiful.confdir .. "/icons/disk.png"
beautiful.widget_net    = beautiful.confdir .. "/icons/down.png"
beautiful.widget_netup  = beautiful.confdir .. "/icons/up.png"
beautiful.widget_wifi   = beautiful.confdir .. "/icons/wifi.png"
beautiful.widget_mail   = beautiful.confdir .. "/icons/mail.png"
beautiful.widget_vol    = beautiful.confdir .. "/icons/vol.png"
beautiful.widget_org    = beautiful.confdir .. "/icons/cal.png"
beautiful.widget_date   = beautiful.confdir .. "/icons/time.png"
beautiful.widget_crypto = beautiful.confdir .. "/icons/crypto.png"
beautiful.widget_sep    = beautiful.confdir .. "/icons/separator.png"
beautiful.widget_temp   = beautiful.confdir .. "/icons/temp.png"
-- }}}

-- {{{ Titlebar icons
beautiful.titlebar_close_button_focus  = beautiful.confdir .. "/icons/titlebar/close_focus.png"
beautiful.titlebar_close_button_normal = beautiful.confdir .. "/icons/titlebar/close_normal.png"

beautiful.titlebar_ontop_button_focus_active    = beautiful.confdir .. "/icons/titlebar/ontop_focus_active.png"
beautiful.titlebar_ontop_button_normal_active   = beautiful.confdir .. "/icons/titlebar/ontop_normal_active.png"
beautiful.titlebar_ontop_button_focus_inactive  = beautiful.confdir .. "/icons/titlebar/ontop_focus_inactive.png"
beautiful.titlebar_ontop_button_normal_inactive = beautiful.confdir .. "/icons/titlebar/ontop_normal_inactive.png"

beautiful.titlebar_sticky_button_focus_active    = beautiful.confdir .. "/icons/titlebar/sticky_focus_active.png"
beautiful.titlebar_sticky_button_normal_active   = beautiful.confdir .. "/icons/titlebar/sticky_normal_active.png"
beautiful.titlebar_sticky_button_focus_inactive  = beautiful.confdir .. "/icons/titlebar/sticky_focus_inactive.png"
beautiful.titlebar_sticky_button_normal_inactive = beautiful.confdir .. "/icons/titlebar/sticky_normal_inactive.png"

beautiful.titlebar_floating_button_focus_active    = beautiful.confdir .. "/icons/titlebar/floating_focus_active.png"
beautiful.titlebar_floating_button_normal_active   = beautiful.confdir .. "/icons/titlebar/floating_normal_active.png"
beautiful.titlebar_floating_button_focus_inactive  = beautiful.confdir .. "/icons/titlebar/floating_focus_inactive.png"
beautiful.titlebar_floating_button_normal_inactive = beautiful.confdir .. "/icons/titlebar/floating_normal_inactive.png"

beautiful.titlebar_maximized_button_focus_active    = beautiful.confdir .. "/icons/titlebar/maximized_focus_active.png"
beautiful.titlebar_maximized_button_normal_active   = beautiful.confdir .. "/icons/titlebar/maximized_normal_active.png"
beautiful.titlebar_maximized_button_focus_inactive  = beautiful.confdir .. "/icons/titlebar/maximized_focus_inactive.png"
beautiful.titlebar_maximized_button_normal_inactive = beautiful.confdir .. "/icons/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}


local naughty = require("naughty")
naughty.config.presets.chat = naughty.config.presets.online
naughty.config.presets.away = {
    bg = "#eb4b1380",
    fg = "#ffffff",
}
naughty.config.presets.xa = {
    bg = "#65000080",
    fg = "#ffffff",
}
naughty.config.presets.dnd = {
    bg = "#65340080",
    fg = "#ffffff",
}
naughty.config.presets.invisible = {
    bg = "#ffffff80",
    fg = "#000000",
}
naughty.config.presets.offline = {
    bg = "#64636380",
    fg = "#ffffff",
}
naughty.config.presets.requested = naughty.config.presets.offline
naughty.config.presets.error = {
    bg = "#ff000080",
    fg = "#ffffff",
}

naughty.config.icon_dirs = { os.getenv("HOME") .. ".config/awesome/icons/",  "/usr/share/pixmaps/" }

