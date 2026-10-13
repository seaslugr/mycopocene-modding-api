name = "Hot Potato"
version = "1.0.0"
author = "example_author"

local SPAWN_SECONDS = 10.0
local FUSE_SECONDS = 2.0
local TICK_SECONDS = 0.25
local TICK_DAMAGE = 7
local BLAST_DAMAGE = 60

local potato = caffeine.add_item({
    name = "Hot Potato",
    icon_tile_id = 12,
    category = "Item",
    rarity = "Exotic",
    description = "Drop it. You have 2 seconds.",
})

local fuse = {}

caffeine.on_run_start(function(world, player)
    fuse[player:get_index()] = nil
end)

caffeine.set_interval(function(world, player)
    local who = player:get_index()
    if not world:get_expedition_active() or fuse[who] then
        return
    end
    if player:give_item(potato, 1) then
        fuse[who] = FUSE_SECONDS
        caffeine.log("Catch!")
    else
        pcall(player.damage, player, BLAST_DAMAGE)
    end
end, SPAWN_SECONDS)

caffeine.set_interval(function(world, player)
    local who = player:get_index()
    if not fuse[who] then
        return
    end
    if player:count_item(potato) == 0 then
        fuse[who] = nil
        return
    end
    fuse[who] = fuse[who] - TICK_SECONDS
    if fuse[who] <= 0 then
        fuse[who] = nil
        player:remove_item(potato, 1)
        pcall(player.damage, player, BLAST_DAMAGE)
    else
        pcall(player.damage, player, TICK_DAMAGE)
    end
end, TICK_SECONDS)
