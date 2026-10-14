[Index](../README.md) | Previous: [Mod data](data.md) | Next: [Rooms and Workshop](rooms-and-workshop.md)

# Online play

In online co-op, the host owns the simulation. Enemies, health, positions and dropped items come from the host. Each player owns its own inventory and XP.

Each machine runs its own mods. A callback runs for the local players of that machine.

## Tiers

Each API function has a tier. The tier says what the function does on a guest.

| Tier | Functions | On a guest |
|---|---|---|
| View | Lookups, getters, hook registration, UI, sound and music, `log`, `add_command`, `replace_asset`, `save_data`, `load_data`, `delete_data` | Works. Mod data is on each machine. |
| Owner | `player:give_item`, `player:remove_item`, `player:add_xp` | Works. Each player owns its inventory and XP. |
| Authority | `player:heal`, `player:damage`, `player:damage_raw`, `player:teleport`, `world:damage_player`, `world:teleport_player`, `world:teleport_player_to_room`, `world:spawn_item`, `world:spawn_entity`, `world:spawn_projectile`, `world:add_fluid`, `player:apply_status`, `player:clear_status`, `caffeine.spawn_entity`, the enemy handle methods that change the enemy | Raises a `host only` error. |
| Content | `add_item`, `add_entity`, `add_recipe`, `add_shop_entry`, `edit_item`, `edit_entity`, `edit_shop_entry`, `remove_shop_entry`, `add_fluid`, `edit_fluid`, `add_status`, `edit_status`, `add_object`, `add_projectile` | Works at load. Host and guest must match. On each machine, a call after the load raises an error. |

An Authority error in a callback is a normal callback error. It goes to the console, and 8 errors in a row disable the callback. See [Errors](environment.md#errors).

## Write a mod that works online

Guard the Authority calls. `pcall` is the simple way.

```lua
caffeine.set_interval(function(world, player)
    local x, y = player:get_pos()
    pcall(world.spawn_entity, world, "primitive", x + 300, y)
end, 10.0)
```

On the host the enemy spawns, and each guest sees it. On a guest the call fails and nothing more happens.

A guest cannot ask the host to do an Authority action yet.

## Content mods

A mod that calls a Content function at load is a content mod. The game finds this out by itself. A mod does not declare it.

When a guest joins, the game compares the content mods of both sides by `name`, `version` and load order.

| Difference | Result |
|---|---|
| The host has a content mod the guest does not have | The guest cannot join. |
| The guest has a content mod the host does not have | The guest cannot join. |
| Same mod, different `version` | The guest cannot join. |
| Same mods, different load order | The guest cannot join. |

The guest sees which mods differ. For a load order difference, the guest sees the order of the host. Change the order in the Mods menu to match it.

The load order matters because a mod item, entity, status or fluid gets its id in load order. With a different order, the same id names a different thing on each side. Only the order of the content mods counts. A HUD mod can be anywhere in the list.

A content mod registers all of its content at load. A Content function in a callback raises an error, because the change would happen on one machine only. See [Content functions after the load](environment.md#content-functions-after-the-load).

A mod with only View and Owner calls, such as a HUD mod, does not need to match. A guest can use it in any session.

Change `version` each time you change the content of a released mod.

## Item use

`on_use` runs on the machine of the player that used the item. Set `host_use = true` on the item when `on_use` calls an Authority function such as `player:heal`.

| `host_use` | On the host | On a guest |
|---|---|---|
| `true` | The host runs `on_use` too. The heal comes from the host. | Authority calls in `on_use` do nothing and return `false`. No error. |
| `false` | The host does not run it. | Authority calls raise `host only`. The player keeps the item. |

With `host_use = true`, the same `on_use` works for the host and for a guest with no `pcall`.

When a guest uses a `host_use` item, `on_use` runs two times: one time on the guest and one time on the host. Each side does its own part.

| Call in `on_use` | On the guest | On the host, for the guest's player |
|---|---|---|
| `heal`, `damage`, spawn, teleport | Does nothing, returns `false` | Works |
| `give_item`, `remove_item` | Works | Does nothing, returns `false` |
| `count_item` | Correct | Returns `0` |

Do not make the heal depend on `count_item`, because the host sees `0`. The return value of `on_use` counts on the guest only.

```lua
caffeine.add_item({
    name = "Big Vial",
    icon = "sprites/big_vial.png",
    category = "Consumable",
    usable = true,
    host_use = true,
    on_use = function(player, world)
        player:heal(80)
    end,
})
```
