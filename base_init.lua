-- base init module
-- second file to be loaded after widgets
-- TODO: clean me

local awful = require("awful")
local io = require('io')

-- some global modules:
vicious = require("vicious")
quake = require("quake")

home   = os.getenv("HOME")
screen_switched = false

proc = io.popen('~/.screenlayout/default.sh')
io.close(proc)

scount = screen.count()

S_MAIN = 1
S_SEC = 2

color = {red="#ec3780", green="#80ecac", blue="#80b5ec", yellow="#eaec80"}

-- SETUP COMPOSE KEY. see compose in /usr/share/X11/xkb/rules/base.lst
if IS_LAPTOP then
    awful.spawn.with_shell('setxkbmap -option compose:prsc')
else
    awful.spawn.with_shell('setxkbmap -option compose:menu')
end

-- handy functions --
--

-- END OF CUSTO &  definitions
function rmtags(s)
    local tags = s.tags
    for tag in pairs(tags) do
        tags[tag]:delete()
    end
end

 -- remove current tags, then forget
awful.screen.connect_for_each_screen (rmtags)
awful.screen.disconnect_for_each_screen (rmtags)

-- tagidx.tag_name == <index of the given tag>

tagidx = {}
local _tags = {
    names={},
    layout={},
    props={}
}

for i,t in ipairs(tags) do
    tagidx[t[1]] = i
    _tags.names[i] = t[1] or i
    _tags.layout[i] = t[2]
end

function mktags(s)
  local tag = awful.tag.new(_tags.names, s, _tags.layout) -- create tags
  for i, t in ipairs(tag) do -- set some properties
      t.master_width_factor = 0.8
      local props = tags[i][3]
      if props then
          if type(props) == 'function' then
              props = props(t)
          else -- table of properties
              for pname, pval in pairs(props) do
                  awful.tag.setproperty(t, pname, pval)
              end
          end
      end
  end
end

awful.screen.connect_for_each_screen (mktags)

_tags = nil
tags = nil

awful.tag.viewidx(tagidx.web, scount) -- default tag

local theme = require('beautiful').get()

local separator = '|'
theme.tasklist_sticky = '⚓' .. separator
theme.tasklist_ontop = '⌃' .. separator
theme.tasklist_above = '▴' .. separator
theme.tasklist_below = '▾' .. separator
theme.tasklist_floating = '✈' .. separator
theme.tasklist_maximized = '▪' .. separator
theme.tasklist_maximized_horizontal = '⬌' .. separator
theme.tasklist_maximized_vertical = '⬍' .. separator
