[Index](../README.md) | Previous: [Mod data](data.md) | Next: [Online play](online.md)

# Achievements

A mod can add its own achievements. They show in Stats > Achievements, below the achievements of the game. Each mod has its own header with the name of the mod and its count, for example `My Mod (2 / 5)`. An unlock shows the same toast as an achievement of the game, with the name of the mod in the caption.

```lua
myco.add_achievement({
    id = "crafter",
    name = "Busy Hands",
    description = "Craft 20 items.",
    icon = "icons/hammer.png",
    target = 20,
})

myco.on_craft(function(item_id, qty, world, player)
    player:add_achievement_progress("crafter", qty)
end)
```

## myco.add_achievement

```lua
myco.add_achievement(def)
```

Adds one achievement. Call it only while the mod loads, at the top of `mod.lua` or a file it runs. A later call raises an error.

| Field | Type | Description |
|---|---|---|
| `id` | string | Required. 1 to 31 letters, digits or `_`. Unique in the mod. Two mods can use the same `id`. The achievements file stores it, so do not change it. |
| `name` | string | Required. Shown when unlocked. A locked achievement shows `???`. |
| `description` | string | Required. What the player must do. |
| `locked_description` | string | Shown in place of `description` while it is locked. Use `"???"` for a secret achievement. Defaults to `description`. |
| `icon` | string | An image in the folder of the mod, a grid of 16 pixel tiles, as the [icon of an item](items.md). Defaults to the icon of the game. |
| `icon_index` | integer | The tile of `icon`, row by row from `0`. Defaults to `0`. |
| `target` | integer | The count that unlocks it, `1` to `1000000000`. Defaults to `1`. With a target above `1`, the Stats tab shows `count / target` while it is locked. |

A bad field raises an error. All mods together can have at most 256 achievements.

## Unlock and progress

| Method | Returns | Description |
|---|---|---|
| `player:unlock_achievement(id)` | boolean | Unlocks it. `true` when this call unlocked it. `false` when it was unlocked already. |
| `player:add_achievement_progress(id, amount)` | boolean | Adds `amount` to the count. At `target`, it unlocks. `true` when this call unlocked it. `amount` must be `0` or more. |
| `myco.has_achievement(id)` | boolean | `true` when it is unlocked. |
| `myco.get_achievement_progress(id)` | integer, integer | The count and the target. The count of an unlocked achievement is the target. |

`id` is an achievement of the mod that makes the call. An unknown `id` raises an error.

The toast shows in the view of the `player` of the call.

## Where it is saved

The game keeps the state in the [data folder of the mod](data.md#where-the-files-are), in `achievements.txt`. A `save_data` name never collides with it, because those files end in `.json`.

- The state is on this machine only. It is the same for each save slot and each player of this machine.
- An unlock writes the file at once. A change of the count writes it 2 seconds later. Thus a call on each frame does not write on each frame.
- `savewipe` deletes the file with the other data of the mod. All the achievements of the mod lock again.
- An achievement that the mod does not add any more drops from the file on the next write.
- When a new version of the mod lowers `target` below a saved count, the achievement unlocks, with no toast.

## Online

The state is per machine, so only a player of this machine can change it. A call for a remote player does nothing and returns `false`. The machine of that player runs its own copy of the mod.

Thus call these methods with a player of this machine. These callbacks get one:

- The player hooks, as `on_craft`, `on_level_up` and `on_player_death`. They run for each local player. See [Hooks](hooks.md#hook-list).
- [`add_passive`](hooks.md#mycoadd_passive) and [`set_interval`](hooks.md#mycoset_interval).
- The callbacks of a [keybind](keybinds.md).

`on_enemy_killed` runs on the host only, so it can unlock achievements for the players of the host only. See [Where callbacks run](online.md#where-callbacks-run).

## Test with the console

| Command | Description |
|---|---|
| `achievement list` | Lists each achievement. A mod achievement shows as `Mod Name:id`. |
| `achievement Mod Name:id` | Unlocks one, with its toast. |
| `achievement all` | Unlocks each achievement, of the game and of the mods. |
| `achievement reset` | Locks the achievements of the game for player one and each mod achievement, and writes the files. |

If the game cannot write the file, the console shows one error. The game tries again every 2 seconds and keeps the state in memory.
