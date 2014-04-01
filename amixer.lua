local id="0"
local increment=4

os.execute('kill `cat /tmp/amixer_ctl'..id..'.pid` >/dev/null ; mkfifo /tmp/amixer_ctl'..id..' && echo $! > /tmp/amixer_ctl'..id..'.pid')
os.execute('amixer -qsM < /tmp/amixer_ctl'..id..' &')

_fd = io.open('/tmp/amixer_ctl'..id, 'a')

local _mixer_send = function(cmd)
    _fd:write(cmd)
    _fd:flush()
end

local _up_vol = function(sense)
    local _cmd = 'sset Master '..increment..'%' .. sense .. '\n'
    return function()
        _mixer_send(_cmd)
    end
end

return {
    up = _up_vol('+'),
    down = _up_vol('-'),
    mute = function() _mixer_send('sset Master mute\n') end,
    unmute = function() _mixer_send('sset Master unmute\n') end,
    toggle = function() _mixer_send('sset Master toggle\n') end
}
