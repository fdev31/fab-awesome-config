local increment=4

return {
    up = function() os.execute('ponymix increase ' .. increment) end,
    down = function() os.execute('ponymix decrease ' .. increment) end,
    mute = function() os.execute('ponymix mute') end,
    unmute = function() os.execute('ponymix unmute') end,
    toggle = function() os.execute('ponymix toggle') end,
    card_no = -1
}
