local tag = require('awful.tag')

local function do_exp_loaded_h(p)
    local wa = p.workarea
    local cls = p.clients
    local limit = tag.getncol(p.tag or tag.selected(p.screen)) + 1

    local horiz = wa.width > wa.height

    if #cls > 0 then
        local nb_big = math.min( #cls , limit)
        local nb_small = #cls - nb_big + 1
        local tot_cols = nb_small
        local cur_offset = 0

        local width_n = (horiz and 'height' or 'width')
        local height_n = (horiz and 'width' or 'height')
        local x_n = (horiz and 'y' or 'x')
        local y_n = (horiz and 'x' or 'y')

        local height = math.floor( wa[height_n] * tag.getmwfact(p.tag) )
        local remains = wa[height_n] - height

        for k, c in ipairs(cls) do
            local g = {}
            local bw = c.border_width*2

            if nb_big > 1 then
                g[width_n] = wa[width_n] - bw
                g[height_n] = height - bw
                g[y_n] = wa[y_n] + cur_offset
                g[x_n] = wa[x_n]
                nb_big = nb_big - 1
                cur_offset = cur_offset + height
                height = (remains or height) / 2
                remains = nil
            else
                g[width_n] = wa[width_n] / tot_cols - bw
                g[height_n] = (2*height) - bw
                g[x_n] = wa[x_n] + g[width_n] * (tot_cols - nb_small)
                g[y_n] = wa[y_n] + cur_offset
                nb_small = nb_small - 1
            end
            c:geometry(g)
        end
    end
end

local function do_exp_loaded(p)
    local wa = p.workarea
    local cls = p.clients
    local limit = tag.getncol(p.tag or tag.selected(p.screen))

    if #cls > 0 then
        local nb_big = math.min( #cls , limit)
        local nb_small = #cls - nb_big + 1

        local tot_cols = nb_small
        local height = wa.height / 2
        local cur_offset = 0

        for k, c in ipairs(cls) do
            local g = {}
            local bw = c.border_width*2

            if nb_big > 1 then
                g.width = wa.width - bw
                g.height = height - bw
                g.y = wa.y + cur_offset
                g.x = wa.x
                nb_big = nb_big - 1
                cur_offset = cur_offset + height
                height = height / 2
            else
                g.width = wa.width / tot_cols - bw
                g.height = (2*height) - bw
                g.x = wa.x + g.width * (tot_cols - nb_small)
                g.y = wa.y + cur_offset
                nb_small = nb_small - 1
            end

            c:geometry(g)
        end
    end
end

local function do_loaded(p)
    local wa = p.workarea
    local cls = p.clients

    if #cls > 0 then
        local nb_big = math.min( #cls , 3 )
        local nb_small = #cls - nb_big + 1

        local tot_cols = nb_small
        local height = wa.height / nb_big

        for k, c in ipairs(cls) do
            local g = {}
            local bw = c.border_width*2

            if nb_big > 1 then
                g.width = wa.width - bw
                g.height = height - bw
                g.y = wa.y + g.height * (k-1) 
                g.x = wa.x
                nb_big = nb_big - 1
            else
                g.width = wa.width / tot_cols - bw
                g.height = height- bw
                g.x = wa.x + g.width * (tot_cols - nb_small)
                g.y = wa.y + wa.height - height
                nb_small = nb_small - 1
            end

            c:geometry(g)
        end
    end
end

return {
    fun = {
        name = "mag",
        arrange = do_loaded
    },
    exp = {
        name = "gradient",
        arrange = do_exp_loaded_h
    }
}

