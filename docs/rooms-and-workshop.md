[Index](../README.md) | Previous: [Online play](online.md)

# Rooms and Workshop

## Room files

The game loads each `.room` file in the `rooms/` folder of an enabled mod, with the base game rooms.

```
mods/
  my_mod/
    mod.lua
    rooms/
      spider_den.room
```

Make rooms with the Room Builder tool. A room can use the items and entities of its mod.

| In a room file | Stored as |
|---|---|
| Base game item | Its key |
| Mod item | `mod name:item name` |
| Mod entity | `mod name:entity name` |

The room resolves these at any load order. When the mod of an item is off, the game shows a placeholder item and keeps the reference.

A room name must be unique. Use a prefix for your rooms, for example `mymod_spider_den`.

To send a player to a room of your mod:

```lua
caffeine.add_command("den", "den - go to the spider den", function(args, world, player)
    world:teleport_player_to_room("mymod_spider_den")
end)
```

The room script API (script nodes in Room Builder) is a different API. It is not in this reference.

## Steam Workshop

Upload a mod folder with the Workshop Uploader tool. The tool writes two files into the mod folder. Keep them, so the next upload updates the same Workshop item.

| File | Contents |
|---|---|
| `workshop_id.txt` | The id of the Workshop item. |
| `workshop_meta.txt` | Upload data of the tool. |

For players:

- A subscribed mod shows in the Mods menu with a `[Workshop]` tag.
- A Workshop mod is off until the player enables it.
- The game reads the `name`, `version` and `author` of a mod that is off. It runs `mod.lua` for that in a separate Lua state where each API function does nothing.

Because of that last point, keep the top level of `mod.lua` free of work that needs real API results.
