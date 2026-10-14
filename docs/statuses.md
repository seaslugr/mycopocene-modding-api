[Index](../README.md) | Previous: [Fluids](fluids.md) | Next: [Code objects](objects.md)

# Status effects

A status is a timed effect on a player or an enemy: Burn, Poison, a Defense buff. A mod can add statuses and change the built-in ones. A mod status works in each place that takes a status name: items, Modifications, fluids, and `player:apply_status`.

## Status names

Built-in names: `"poison"`, `"burn"`, `"ice"`, `"lightning"`, `"cure"`, `"light"`, `"magic_shield"`, `"reflect"`, `"heal"`, `"detect"`, `"invisible"`, `"jump"`, `"gravity"`, `"max_hp"`, `"defense"`, `"restore"`, `"absorb"`, `"atk_speed"`.

Case and spaces do not matter in a name: `"Magic Shield"` is `"magic_shield"`. `"none"` means no status.

## How a status acts

Each active status has a magnitude and a time left. What the magnitude does comes from the fields of the status. `damage`, `heals` and `shield` are fields of their own. The stats go in the `affects` list.

| Field or stat | What the magnitude does | Example |
|---|---|---|
| `damage` | Damage each second. | `2`: 2 damage each second. |
| `heals` | Health each second. | `3`: 3 health each second. |
| `speed`, `atk_speed` | Takes this percent off the stat. A negative magnitude adds to it. | `40`: 60% speed. `-20`: 120% speed. |
| `defense` | Takes this percent off the damage the body takes. A negative magnitude adds to it. | `25`: 25% less damage. |
| `jump`, `max_hp` | Adds this percent to the stat. A negative magnitude takes it off. | `40`: 140% max HP. |
| `gravity` | `100` turns gravity over. `-100` makes it 3 times as strong. | `50`: no gravity. |
| `shield` | Takes projectile damage until the magnitude is used up. | `20`: takes 20 damage. |

## caffeine.add_status

```lua
local id = caffeine.add_status(def)
```

Adds a status and returns its id.

| Field | Type | Default | Description |
|---|---|---|---|
| `key` | string | required | Unique name. Use a prefix of your mod, for example `"mymod_rot"`. |
| `name` | string | the key | Display name. |
| `icon` | string | none | A 16 by 16 pixel image in the mod folder, for the HUD and the enemy health bars. As the [icon of an item](items.md#icons). |
| `icon_index` | integer | `0` | The tile of `icon`, row by row from 0. |
| `magnitude` | integer | `1` | The magnitude when nothing else gives one. |
| `debuff` | boolean | `false` | Cure takes it off. |
| `stacks` | boolean | `false` | `true`: each new application is one more instance. `false`: one instance. A new application sets its magnitude and keeps the longer of the two times. |
| `damage` | boolean | `false` | Deals the magnitude as damage each second. |
| `heals` | boolean | `false` | Gives the magnitude as health each second. |
| `element` | string | `"other"` | The element of its damage: `"fire"`, `"ice"`, `"poison"`, `"lightning"`, `"steam"` or `"other"`. |
| `affects` | list | none | The stats it changes: `"speed"`, `"atk_speed"`, `"jump"`, `"gravity"`, `"defense"`, `"max_hp"`. |
| `shield` | boolean | `false` | Takes projectile damage. |
| `shield_regen` | number | `0` | Shield magnitude it gets back each second. |
| `on_tick` | function | none | `on_tick(player, world, magnitude, seconds_left)`. Runs each second while a player has the status. |
| `on_end` | function | none | `on_end(player, world)`. Runs when the time of the status runs out on a player. |

```lua
caffeine.add_status({
    key = "mymod_rot",
    name = "Rot",
    icon = "icons/rot.png",
    debuff = true,
    damage = true,
    element = "poison",
    magnitude = 2,
    affects = { "speed" },
    on_end = function(player, world)
        caffeine.log("the rot is gone")
    end,
})
```

`on_tick` and `on_end` run for players only. On an enemy the status deals its damage and changes its speed, and the callbacks do not run. Cure and `clear_status` remove a status with no `on_end`.

Use the new status anywhere a status name goes:

```lua
caffeine.add_item({
    name = "Rot Gland",
    icon = "icons/gland.png",
    category = "Modification",
    modif = { groups = { sword = 1.0 }, hook = "on_hit_dealt", chance = 0.3, status = "mymod_rot", magnitude = 3, duration = 4 },
})
```

## caffeine.edit_status

```lua
caffeine.edit_status(status, patches)
```

Changes a status. `status` is a name or an id. `patches` takes each field of `add_status` but `key`. A built-in status takes no `on_tick` or `on_end`, and its special behavior (Cure, Restore) stays.

```lua
caffeine.edit_status("burn", { magnitude = 5, icon = "icons/my_burn.png" })
```

## caffeine.get_status_id

```lua
local id = caffeine.get_status_id(key)
```

Returns the id of a status, or `nil`. A mod status id is valid for one mod load only. Store a status by its key.

## Player methods

| Method | Returns | Description |
|---|---|---|
| `player:apply_status(status, duration, magnitude)` | nothing | Gives the status for `duration` seconds. `magnitude` defaults to the magnitude of the status. Host only. |
| `player:clear_status(status)` | boolean | Takes the status off. `true` if the player had it. Host only. |
| `player:get_status(status)` | number, integer or nil | The seconds left and the magnitude, or `nil` when the player does not have it. |

## Online

`add_status` and `edit_status` are Content functions: a host and a guest must have the same mods.

The host owns the statuses of each player. Its copy deals the damage, and the health goes to the guest.

The game does not send statuses to a guest. A status that the host gives to a guest's player does not show on the guest's HUD, and the guest does not run its callbacks. The built-in statuses act the same way.

The host runs `on_tick` and `on_end` for each player. A guest runs them only for a status on its own copy of its player. There the Authority calls do nothing and return `false`, as in a room script. So a heal in `on_tick` happens one time, on the host.

## Limits

| Thing | Limit |
|---|---|
| Mod statuses, across all mods | 64 |
| Status icons on the HUD at one time | 8 |
