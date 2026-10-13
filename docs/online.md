[Index](../README.md) | Previous: [Custom UI](ui.md) | Next: [Rooms and Workshop](rooms-and-workshop.md)

# Online play

In online co-op, the host owns the simulation. Enemies, health, positions and dropped items come from the host. Each player owns its own inventory and XP.

Each machine runs its own mods. A callback runs for the local players of that machine.

## Tiers

Each API function has a tier. The tier says what the function does on a guest.

| Tier | Functions | On a guest |
|---|---|---|
| View | Lookups, getters, hook registration, UI, `log`, `add_command` | Works. |
| Owner | `player:give_item`, `player:remove_item`, `player:add_xp` | Works. Each player owns its inventory and XP. |
| Authority | `player:heal`, `player:damage`, `player:damage_raw`, `player:teleport`, `world:damage_player`, `world:teleport_player`, `world:teleport_player_to_room`, `world:spawn_item`, `world:spawn_entity`, `caffeine.spawn_entity` | Raises a `host only` error. |
| Content | `add_item`, `add_entity`, `add_recipe`, `add_shop_entry`, `edit_item`, `edit_entity`, `edit_shop_entry`, `remove_shop_entry` | Works at load. Host and guest must match. |

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

When a guest joins, the game compares the content mods of both sides by `name` and `version`.

| Difference | Result |
|---|---|
| The host has a content mod the guest does not have | The guest cannot join. |
| The guest has a content mod the host does not have | The guest cannot join. |
| Same mod, different `version` | The guest cannot join. |

The guest sees which mods differ.

A mod with only View and Owner calls, such as a HUD mod, does not need to match. A guest can use it in any session.

Change `version` each time you change the content of a released mod.

## Item use

`on_use` runs on the machine of the player that used the item. Set `host_use = true` on the item when `on_use` calls an Authority function such as `player:heal`. The host then runs `on_use` too, and the heal comes from the host.

On the guest, the same Authority call raises `host only`. Wrap it in `pcall` so the guest gets no console error.

```lua
on_use = function(player, world)
    pcall(player.heal, player, 40)
end
```
