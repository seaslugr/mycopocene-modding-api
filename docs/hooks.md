[Index](../README.md) | Previous: [Players and worlds](players-and-worlds.md) | Next: [Console](console.md)

# Hooks and callbacks

A hook is a game event a mod can listen to. Register a listener at the top level of `mod.lua`.

```lua
myco.on_level_up(function(level, world, player)
    player:heal(player:get_max_health())
end)
```

More than one mod can listen to the same hook. Listeners run in load order. A listener stays active until the next mod load, or until [`remove_hook`](#mycoremove_hook) removes it.

For the `world` and `player` arguments, see [Players and worlds](players-and-worlds.md).

## Hook list

| Hook | Callback arguments | When |
|---|---|---|
| `myco.on_room_enter(fn)` | `world, player` | A player arrives in a room. Also fires one time when a session starts. |
| `myco.on_run_start(fn)` | `world, player` | A player enters a run. Fires before `on_room_enter`. |
| `myco.on_run_end(fn)` | `world, player` | A player leaves a run. Fires before `on_room_enter`. |
| `myco.on_enemy_killed(fn)` | `info, world` | Any enemy dies. `info` is the [`on_death`](#on_death) table. |
| `myco.on_level_up(fn)` | `level, world, player` | A player gets a level. `level` is the new level. |
| `myco.on_player_damaged(fn)` | `damage, new_health, world, player` | A player loses health to an enemy, a projectile or a hazard. `damage` is the health lost. |
| `myco.on_player_death(fn)` | `world, player` | A player dies. |
| `myco.on_craft(fn)` | `item_id, qty, world, player` | A player crafts at a bench. The result is in the inventory already. |

### Rules

- The player hooks run for each local player. In splitscreen, `player` says which one.
- Two players that walk into a room together cause two `on_room_enter` calls, one for each.
- `on_room_enter` fires when the player is in the room. A room that the player only sees across the edge of the next room does not fire it.
- `on_enemy_killed` has no player argument. Use `world:get_player(i)` there.
- Online, `on_enemy_killed` and [`on_death`](#on_death) run on the host only. A guest does not get them.
- Damage a mod deals with `damage`, `damage_raw` or `damage_player` does not fire `on_player_damaged`. The damage of a status, such as Poison, does not fire it either.

### Examples

Run a thing one time for each run:

```lua
local kills = 0

myco.on_run_start(function(world, player)
    kills = 0
end)

myco.on_enemy_killed(function(info, world)
    kills = kills + 1
end)

myco.on_run_end(function(world, player)
    myco.log("kills in this run: " .. kills)
end)
```

Give an item at low health:

```lua
myco.on_player_damaged(function(damage, new_health, world, player)
    if new_health > 0 and new_health < 20 and player:count_item("health_vial") == 0 then
        player:give_item("health_vial", 1)
    end
end)
```

## myco.remove_hook

```lua
local removed = myco.remove_hook(handle)
```

Each hook function returns a handle. `remove_hook` removes that listener. It returns `true` if the handle was active.

```lua
local first_kill
first_kill = myco.on_enemy_killed(function(info, world)
    myco.log("first kill of this session")
    myco.remove_hook(first_kill)
end)
```

It works for each hook in the list above, for [`on_sfx` and `on_music`](audio.md) and for [`on_draw_ui`](ui.md#mycoon_draw_ui). A listener can remove itself.

A mod can remove its own listeners only. With the handle of a listener of a different mod, `remove_hook` does nothing and returns `false`. The same rule applies to `remove_passive` and `clear_interval`.

## myco.add_passive

```lua
local handle = myco.add_passive(fn)
```

Calls `fn(world, player)` on each simulation tick, one time for each local player. Returns a handle. The game does not call it during a pause or in a menu.

A passive runs 60 times each second for each player. Keep it short. Do the cheap test first.

This one heals 1 health each second while the room has no enemies. `heal` is host only, so on a guest it raises an error. See [Online play](online.md).

```lua
local timer = 0

myco.add_passive(function(world, player)
    if world:get_enemy_count() > 0 then
        return
    end
    timer = timer + 1
    if timer >= 60 then
        timer = 0
        player:heal(1)
    end
end)
```

## myco.remove_passive

```lua
local removed = myco.remove_passive(handle)
```

Stops a passive of your mod. Returns `true` if the handle was active. A passive can remove itself.

## myco.set_interval

```lua
local handle = myco.set_interval(fn, seconds)
```

Calls `fn(world, player)` each `seconds` of game time, one time for each local player. Returns a handle. The timer stops during a pause.

```lua
myco.set_interval(function(world, player)
    if player:get_index() ~= 0 then
        return
    end
    local x, y = player:get_pos()
    world:spawn_entity("primitive", x + 300, y)
end, 5.0)
```

The test of `get_index` makes the callback do its work one time in splitscreen.

## myco.clear_interval

```lua
local removed = myco.clear_interval(handle)
```

Stops an interval of your mod. Returns `true` if the handle was active.

```lua
local countdown = 3
local handle

handle = myco.set_interval(function(world, player)
    myco.log(tostring(countdown))
    countdown = countdown - 1
    if countdown == 0 then
        myco.clear_interval(handle)
    end
end, 1.0)
```

## on_use

`on_use` is a field of an item definition. See [Items](items.md).

```lua
on_use = function(player, world)
    if player:get_health() >= player:get_max_health() then
        return false
    end
    player:heal(40)
end
```

The game calls it when a player uses the item. `player` is the player that used it.

| Return value | Result |
|---|---|
| `false` | The item stays in the inventory. |
| anything else, or nothing | The game removes one item. |
| an error | The item stays in the inventory. The error goes to the console. |

An `on_use` that raises an error did not do its work, so the player keeps the item. This includes a `host only` error on a guest. See [Item use](online.md#item-use).

Set `usable = true` on the item, so the player can use it.

## on_death

`on_death` is a field of an entity definition. See [Entities](entities.md).

```lua
on_death = function(info, world)
    world:spawn_item("gold", 5, info.x, info.y)
end
```

The game calls it when an enemy of this type dies. `world` is the world the enemy was in.

| `info` field | Type | Description |
|---|---|---|
| `entity_id` | integer | Id of the entity type. |
| `x`, `y` | number | Middle of the enemy, in room pixels. See [Positions](players-and-worlds.md#positions). |
| `room` | string | Name of the room. |

`on_death` runs before the `on_enemy_killed` listeners.

## Which callback to use

| Goal | Use |
|---|---|
| React to an event | A hook |
| Check a condition all the time | `add_passive` |
| Do a thing on a timer | `set_interval` |
| Make an item do a thing | `on_use` |
| React to the death of one enemy type | `on_death` |
| React to the death of any enemy | `on_enemy_killed` |
| Draw on the screen | [`on_draw_ui`](ui.md) |
| Make a key act on a player | [`add_keybind`](keybinds.md) |
| Add a console command | [`add_command`](console.md) |
