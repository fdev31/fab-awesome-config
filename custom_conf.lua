local awful = require("awful")
local io = require('io')

-- some global modules:
vicious = require("vicious")
drop = require("drop")

home   = os.getenv("HOME")
screen_switched = false

proc = io.popen('~/.screenlayout/default.sh')
io.close(proc)

scount = screen.count()

if (scount == 1) then
    S_MAIN = 1
    S_SEC = 1
else
    S_MAIN = 1
    S_SEC = 2
end

awful.screen.preferred = S_MAIN

color = {red="#ec3780", green="#80ecac", blue="#80b5ec", yellow="#eaec80"}

-- SETUP COMPOSE KEY. see compose in /usr/share/X11/xkb/rules/base.lst
 if IS_LAPTOP then
     awful.util.spawn_with_shell('setxkbmap -option compose:prsc')
 else
     awful.util.spawn_with_shell('setxkbmap -option compose:menu')
 end

-- handy functions --
--

-- END OF CUSTO &  definitions
--
-- remove formerly defined tags
for s = 1, scount do -- for each screen
    local etags = awful.tag.gettags(s)
    for tag in pairs(etags) do
        etags[tag]:delete()
    end
end

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

-- Create tags:
for s = 1, scount do -- for each screen
  local tag = awful.tag(_tags.names, s, _tags.layout) -- create tags
  for i, t in ipairs(tag) do -- set some properties
      awful.tag.setproperty(t , "mwfact" , 0.5)
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

_tags = nil
tags = nil

awful.tag.viewidx(tagidx.web-1, 1) -- default tag

if scount > 1 then
    awful.tag.viewidx(tagidx.im-1, 2)
end
