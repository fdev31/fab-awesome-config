-- use awful.util.spawn instead ?
local id="0"
local increment=4

local xb_fn = function(arg)
    local rarg = 'xbacklight ' .. arg
    local fn = function()
        os.execute(rarg)
    end
    return fn
end

return {
    up = xb_fn('+'..increment),
    down = xb_fn('-'..increment)
}
