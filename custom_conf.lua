local awful = require("awful")
local clay = require('custom_layouts')

-- all used layouts should be defined ONCE here:
--
local LN = {
    title  = awful.layout.suit.tile        , 
    titlet = awful.layout.suit.tile.top    , 
    fair   = awful.layout.suit.fair        , 
    max    = awful.layout.suit.max         , 
    mag    = awful.layout.suit.magnifier   , 
    float  = awful.layout.suit.floating    , 
}

-- Available layouts (override defaults)
layouts = {
    LN.title,
    LN.titlet,
    clay.exp,
    LN.mag,
}

-- Tags --

local _dflt = LN.title

-- user-customizable tags: (name, layout)
local tags = {
    {"term"  , LN.titlet , nil } ,
    {"edit"  , _dflt           , nil } ,
    {"web"   , _dflt           , nil } ,
    {"im"    , clay.exp        , {ncol=2} } ,
    {"fm"    , _dflt           , nil } ,
    {"gfx"   , LN.mag    , nil } ,
    {"rss"   , LN.mag    , nil } ,
    {"media" , _dflt           , nil } ,
    {"toto" , _dflt            , {hide=true} } ,
}
_dflt = nil
LN = nil


WEB_BROWSER = 'firefox'

UT_FOLDER = '/home/fab/grosdisk/home/fab/games/UrbanTerror42'
UT_OPTIONS = ''
UT_POSTRUN = ''

WEB_BROWSER = 'firefox'

IS_LAPTOP = os.execute('laptop-detect')
zic_prompt = true

vicious = require("vicious")
drop = require("drop")
color = {red="#FF5555", green="#55FF55", blue="#5555FF", yellow="#FFFF00"}
nic = io.popen("netstat -rn |grep ^0.0.0.0 |awk '{print $8}'"):read()
home   = os.getenv("HOME")
screen_switched = false

-- see compose in /usr/share/X11/xkb/rules/base.lst
 if IS_LAPTOP then
     awful.util.spawn_with_shell('setxkbmap -option compose:prsc')
 else
     awful.util.spawn_with_shell('setxkbmap -option compose:menu')
 end

local _cmds = io.open(home.."/.config/awesome/commands.txt", "r")
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

editor = os.getenv("EDITOR") or "nano"
terminal = "terminator"
terminal_run = "terminator -x "
fancy_terminal = "terminology"
editor_cmd = 'gvim -reverse '

exec   = awful.util.spawn
_sexec  = awful.util.spawn_with_shell
scount = screen.count()

if (scount == 1) then
    S_MAIN = 1
    S_SEC = 1
else
    S_SEC = 2
    S_MAIN = 1
end

-- handy functions --

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
function eexec(w)
    local t = function()
        exec(editor_cmd .. " " .. w)
    end
    return t
end
function sexec(cmd)
    local t = function()
        _sexec(cmd)
    end
    return t
end

function progress_maker()
    local bar    = awful.widget.progressbar()
    -- Progressbar properties
    bar:set_vertical(true):set_ticks(true)
    bar:set_height(10):set_width(8):set_ticks_size(1)
    bar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = { { 0, color.red }, { 0.5, color.green }, { 1, color.yellow }} })
    return bar
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

