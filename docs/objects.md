[Index](../README.md) | Previous: [Status effects](statuses.md) | Next: [Players and worlds](players-and-worlds.md)

# Code objects

A code object is a thing a room places on a tile: a checkpoint, a steam vent, a heal station. A mod can add its own code objects with Lua callbacks. A room places them with the Room Builder, as it places the objects of the game.

## caffeine.add_object

```lua
local index = caffeine.add_object(def)
```

Adds a code object and returns its index.

| Field | Type | Default | Description |
|---|---|---|---|
| `key` | string | required | Unique name, with no spaces. Use a prefix of your mod, for example `"mymod_pad"`. Rooms store the object by this key. |
| `name` | string | the key | Display name in the Room Builder. |
| `icon` | string | none | An image of 16 pixel tiles in the mod folder. The game draws the tile on the object's tile. |
| `icon_index` | integer | `0` | The first tile of `icon`, row by row from 0. |
| `frames` | integer | `1` | Tiles from `icon_index` that `obj:set_frame` can show. |
| `hidden` | boolean | `false` | Draws nothing in the game. Use it for a trigger. |
| `width` | integer | `1` | Width of the trigger area in tiles, centered on the tile. |
| `height` | integer | `1` | Height of the trigger area in tiles, from the tile up. |
| `on_spawn` | function | none | `on_spawn(obj, world)`. Runs one time when the room loads. |
| `on_tick` | function | none | `on_tick(obj, world, dt)`. Runs each tick. `dt` is in seconds. |
| `on_enter` | function | none | `on_enter(obj, world, player)`. A player's body center came into the area. |
| `on_leave` | function | none | `on_leave(obj, world, player)`. A player's body center went out of the area. |
| `on_interact` | function | none | `on_interact(obj, world, player)`. A player pressed Interact near the object. The game shows the Interact prompt only for an object with this callback. |

```lua
caffeine.add_object({
    key = "mymod_bounce_pad",
    name = "Bounce Pad",
    icon = "objects/pad.png",
    frames = 2,
    width = 1,
    height = 2,
    on_enter = function(obj, world, player)
        obj:set_frame(1)
        -- Value A from the room is the jump boost in percent. Set it in the Room Builder.
        local strength = obj:get_values()
        player:apply_status("jump", 2, strength)
    end,
    on_leave = function(obj, world, player)
        obj:set_frame(0)
    end,
})
```

## Place an object in a room

1. Start the Room Builder. It loads the enabled mods.
2. Open the Code Obj panel and select `Mod Object`.
3. Press `[` and `]`, or click the arrows, to pick the object. The arrows step through each object of each loaded mod.
4. Set Value A and Value B. The object reads them with `obj:get_values()`.
5. `R` turns the object. The game turns its sprite, and the object reads it with `obj:get_rotation()`.
6. Paint the object on a tile. The Edit tool changes a placed object.

The room file stores the key, the two values and the rotation. When the mod is not loaded, the room keeps the object, and the object does nothing. The Room Builder then shows `M?` on it.

## The object handle

Each callback gets `obj`, a handle to one placed object.

| Method | Returns | Description |
|---|---|---|
| `obj:get_key()` | string | The key of the object. |
| `obj:get_pos()` | number, number | The middle of its tile, in pixels. |
| `obj:get_tile()` | integer, integer | Its column and row. |
| `obj:get_values()` | integer, integer | Value A and Value B from the room. |
| `obj:get_rotation()` | integer | Quarter turns clockwise, 0 to 3. |
| `obj:get_area()` | number, number, number, number | The trigger area: x, y, width, height in pixels. |
| `obj:get_frame()` | integer | The tile it shows now, from 0. |
| `obj:set_frame(n)` | nothing | Shows tile `n` of its frames. |
| `obj:set_visible(on)` | nothing | Shows or hides its sprite. |
| `obj:get_data()` | table | A table that stays with this object while its room is loaded. Keep the state of the object here. |

Do not keep `obj` after the callback returns. When its room unloads, the handle raises an error.

```lua
caffeine.add_object({
    key = "mymod_timer_door",
    name = "Timer Door",
    icon = "objects/door.png",
    frames = 2,
    on_tick = function(obj, world, dt)
        local data = obj:get_data()
        data.t = (data.t or 0) + dt
        local a = obj:get_values()
        obj:set_frame(math.floor(data.t / math.max(a, 1)) % 2)
    end,
})
```

## When an object runs

An object runs while its room is the room of a world, so while a player is in that room. A room seen through a seam from the next room does not run or draw its mod objects.

Each world slot that has the room runs its own copy. In splitscreen, two players in the same room share one copy.

When the room unloads, the copy goes away with its `get_data` table. When the room loads again, `on_spawn` runs again.

## Online

`add_object` is a Content function: a host and a guest must have the same mods.

| Callback | Where it runs |
|---|---|
| `on_spawn`, `on_tick`, `on_enter`, `on_leave` | On each machine. On a guest the Authority calls in them do nothing and return `false`, as in a room script. |
| `on_interact` | On the host only, for each player. A guest's press goes to the host. |

`set_frame`, `set_visible` and `get_data` act on this machine only. Change the frame in `on_tick`, `on_enter` or `on_leave` so each machine shows the same thing.

## Limits

| Thing | Limit |
|---|---|
| Mod objects, across all mods | 64 |
| Placed objects that run at one time, in all worlds | 256 |
| Trigger area | 64 by 64 tiles |
