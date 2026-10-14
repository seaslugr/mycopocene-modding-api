[Index](../README.md) | Previous: [Code objects](objects.md) | Next: [Hooks and callbacks](hooks.md)

# Players and worlds

Callbacks get two kinds of object: a World and a Player.

Do not keep a World or a Player after the callback returns. The game uses them again for other rooms and players. Get a new one in each callback.

## What a world is

A `world` is one loaded room with the players, enemies and items in it.

- Players in the same room share one world.
- Players in different rooms have different worlds.
- Each callback gets the world its event happened in.

In splitscreen, player one can be in the camp while player two is in a cave. That is two worlds. A hook for player two gets the cave.

## The two player numbers

A player has two numbers. They are different things.

| Number | Read it with | Meaning | Changes |
|---|---|---|---|
| Session index | `player:get_index()` | Which player this is. `0` is player one, `1` is player two. | Never, during a session. |
| Room index | `player:get_room_index()` | The place of the player in the list of players in its room. | When a player enters or leaves the room. |

The `player_idx` argument of the world methods is the room index.

Example with two players in splitscreen:

| Situation | Player one | Player two |
|---|---|---|
| Both in the camp | session `0`, room `0` | session `1`, room `1` |
| Player two goes to a cave alone | session `0`, room `0` | session `1`, room `0` |

In the second row, player two is alone in its world, so its room index is `0`. `world:get_player_pos(1)` on the cave is out of range.

### Rules

1. If the callback gives you a `player`, use it and ignore the numbers. `player:get_pos()`, `player:damage(10)` and `player:teleport(x, y)` always act on the correct player.
2. To act on each player in a room, loop the room index from `0` to `world:get_player_count() - 1`.
3. To do something one time in splitscreen, test `player:get_index() == 0`.
4. Do not pass `player:get_index()` as `player_idx`. Pass `player:get_room_index()`.

Use the player object:

```lua
caffeine.on_player_damaged(function(damage, new_health, world, player)
    local x, y = player:get_pos()
    world:spawn_item("gold", 1, x, y)
end)
```

Loop over the players of a room:

```lua
caffeine.on_enemy_killed(function(info, world)
    for i = 0, world:get_player_count() - 1 do
        world:get_player(i):add_xp(5)
    end
end)
```

Do a thing one time, with two local players:

```lua
caffeine.set_interval(function(world, player)
    if player:get_index() ~= 0 then
        return
    end
    caffeine.log("one minute passed")
end, 60)
```

## Player methods

### Read

| Method | Returns | Description |
|---|---|---|
| `player:get_index()` | integer | Session index. `0` is player one. `-1` for a remote player. |
| `player:get_room_index()` | integer | Room index. This is the `player_idx` of the world methods. |
| `player:get_pos()` | number, number | Position in pixels. |
| `player:get_health()` | integer | Health. |
| `player:get_max_health()` | integer | Maximum health. |
| `player:get_level()` | integer | Level. |
| `player:get_xp()` | integer | XP. |
| `player:get_attack_damage()` | integer | Attack damage stat. |
| `player:get_defense()` | integer | Defense stat. |
| `player:get_move_speed()` | number | Move speed stat. |
| `player:get_atk_speed()` | number | Attack rate multiplier. |
| `player:get_stat(name)` | number or nil | `"attack_damage"`, `"spell_damage"`, `"defense"`, `"move_speed"`, `"atk_speed"`, `"max_health"`, `"health"`, `"hit_count"`, `"level"`, `"xp"`. `nil` for an unknown name. |
| `player:count_item(item)` | integer | Quantity in the inventory. |
| `player:get_status(status)` | number, integer or nil | Seconds left and magnitude of a status. See [Status effects](statuses.md#player-methods). |

### Change

| Method | Returns | Description |
|---|---|---|
| `player:give_item(item, qty)` | boolean | Adds items and shows the pickup notice. `qty` defaults to `1`. `false` when the items did not fit. |
| `player:remove_item(item, qty)` | boolean | Removes items. `qty` defaults to `1`. |
| `player:add_xp(amount)` | nothing | Adds XP, as an enemy kill does. The player gets each level the XP pays for, and `on_level_up` fires. `amount` must be `0` or more. |
| `player:heal(amount)` | nothing | Adds health up to the maximum. Host only. |
| `player:damage(amount)` | nothing | Damage through defense, with no knockback. Host only. |
| `player:damage_raw(amount)` | boolean | Damage that ignores defense. Host only. |
| `player:teleport(x, y)` | nothing | Moves the player in its room and stops it. `x` and `y` must be finite numbers. Host only. |
| `player:apply_status(status, duration, magnitude)` | nothing | Gives a status. Host only. |
| `player:clear_status(status)` | boolean | Takes a status off. Host only. |

`damage_raw` is scaled to a 100 health pool. `damage_raw(50)` removes half of the health of any player. It returns `false` for a dead player and in godmode.

The inventory methods work on the inventory of that player. For a remote player they return `false` or `0`.

"Host only" is about online play. See [Online play](online.md).

## World methods

Each world method that uses a player takes an optional `player_idx`. It is a room index, starts at `0`, and defaults to `0`. An index out of range becomes `0`.

### Read

| Method | Returns | Description |
|---|---|---|
| `world:get_room_name()` | string | Name of the room. It is the name of the `.room` file with no extension. |
| `world:get_room_id()` | string | The same value as `get_room_name`. |
| `world:get_player_count()` | integer | Players in this room. |
| `world:get_player(player_idx)` | Player or nil | Player object. `nil` when the index is out of range. |
| `world:get_player_pos(player_idx)` | number, number | Position in pixels. |
| `world:get_player_health(player_idx)` | integer | Health. |
| `world:get_player_level(player_idx)` | integer | Level. |
| `world:get_gold(player_idx)` | integer | Gold in the inventory of that player. |
| `world:get_enemy_count()` | integer | Live enemies in the room. |
| `world:get_nearest_enemy_pos(player_idx)` | number, number or nil | Center of the nearest live enemy. `nil` when the room has none. |
| `world:get_chest_count()` | integer | Loot chests the first player in the room has not emptied. |
| `world:get_expedition_time()` | number | Seconds of the current run. |
| `world:get_expedition_active()` | boolean | A timed run is in progress. |
| `world:get_fluid(x, y)` | string, number or nil | The fluid key and amount at a place. See [Fluids](fluids.md#worldget_fluid). |

### Change

| Method | Returns | Description |
|---|---|---|
| `world:damage_player(amount, player_idx)` | nothing | Damage through defense, with no knockback. Host only. |
| `world:teleport_player(x, y, player_idx)` | nothing | Moves the player in the room. `x` and `y` must be finite numbers. Host only. |
| `world:teleport_player_to_room(room_name)` | boolean | Sends each player in this world to the room. The move happens at the end of the tick, as a portal crossing does, so the callback ends in the old room. A remote player moves too. `true` if the room exists. Host only. |
| `world:spawn_item(item, qty, x, y, player_idx)` | nothing | Drops an item. `qty` defaults to `1`. The position defaults to the player. Host only. |
| `world:spawn_entity(entity, x, y)` | boolean | Spawns an entity. `true` if it spawned. Host only. |
| `world:spawn_projectile(projectile, x, y, vx, vy, damage, friendly)` | boolean | Spawns a projectile. See [Enemy AI and projectiles](enemy-ai.md#worldspawn_projectile). Host only. |
| `world:add_fluid(fluid, x, y, amount)` | nothing | Pours a fluid into a cell. See [Fluids](fluids.md#worldadd_fluid). Host only. |

Positions are in pixels. One tile is 48 pixels.
