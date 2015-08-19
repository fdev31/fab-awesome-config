local awful = require("awful")

-- all used layouts should be defined ONCE here:
local _ = {
    DEFAULT = awful.layout.suit.tile      ,
    titlet  = awful.layout.suit.tile.top  ,
    titleb  = awful.layout.suit.tile.bottom,
    fair    = awful.layout.suit.fair      ,
    max     = awful.layout.suit.max       ,
    mag     = awful.layout.suit.magnifier ,
    float   = awful.layout.suit.floating  ,
    gradied = require('custom_layouts').exp
}

-- Available layouts (override defaults)
layouts = {
    _.DEFAULT,
    _.gradied,
    _.titlet,
    _.titleb,
    _.mag,
}

-- Tags --

-- user-customizable tags: (name, layout, options)
local tags = {
    {"term"  , _.titleb  , nil        },
    {"edit"  , _.DEFAULT , nil        },
    {"web"   , _.DEFAULT , nil        },
    {"im"    , _.gradied , {ncol=2}   },
    {"fm"    , _.DEFAULT , nil        },
    {"gfx"   , _.mag     , nil        },
    {"media" , _.DEFAULT , nil        },
    {"toto"  , _.DEFAULT , {hide=true}}
}
_ = nil


UT_FOLDER = '/home/fab/grosdisk/home/fab/games/UrbanTerror42'
UT_OPTIONS = ''
UT_POSTRUN = ''

WEB_BROWSER = 'firefox'

IS_LAPTOP = os.execute('laptop-detect')
zic_prompt = true
editor = os.getenv("EDITOR") or "nano"
terminal = "terminator"
terminal_run = "terminator -x "
fancy_terminal = "terminology"
editor_cmd = 'gvim -reverse '
color = {red="#FF5555", green="#55FF55", blue="#5555FF", yellow="#FFFF00"}

-- END OF CUSTOM DEFINITIONS

vicious = require("vicious")
drop = require("drop")

nic = io.popen("netstat -rn |grep ^0.0.0.0 |awk '{print $8}'"):read()
home   = os.getenv("HOME")
screen_switched = false

scount = screen.count()

if (scount == 1) then
    S_MAIN = 1
    S_SEC = 1
else
    S_SEC = 2
    S_MAIN = 1
end

-- see compose in /usr/share/X11/xkb/rules/base.lst
 if IS_LAPTOP then
     awful.util.spawn_with_shell('setxkbmap -option compose:prsc')
 else
     awful.util.spawn_with_shell('setxkbmap -option compose:menu')
 end

local _cmds = io.open(home.."/.config/awesome/commands.txt", "r")
-- TODO: manage PIDs to handle restart
if _cmds then
    while true do
        line = _cmds:read()
        if line == nil then
            break
        end
        awful.util.spawn_with_shell(line .. " &")
    end
    _cmds = nil
end

-- handy functions --
--
 -- shell exec
exec  = awful.util.spawn_with_shell

-- following returns pointer to functions, to use in menus/keys
--
 -- terminal exec
function texec(cmd, opts)
    local args = ' '
    if (opts) then
        local res = {}
        for k, v in pairs(opts) do
            table.insert(res, '-'..k..' '..v)
        end
        args = ' ' .. table.concat(res, ' ')
    end
    local t = function()
        exec(terminal_run .. cmd .. " " .. args)
    end
    return t
end

 -- editor exec
function eexec(w)
    local t = function()
        exec(editor_cmd .. " " .. w)
    end
    return t
end

 -- standard exec
function sexec(cmd)
    local t = function()
        exec(cmd)
    end
    return t
end

-- END OF CUSTO &  definitions
--
-- rtagnums.tag_name == <index of the given tag>
--
rtagnums = {}
local _tags = {
    names={},
    layout={},
    props={}
}

for i,t in ipairs(tags) do
    rtagnums[t[1]] = i
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
              props(t)
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

