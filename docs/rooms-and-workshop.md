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
| Mod tileset | `mod:Mod_Name/tilesets/file.png`. See [Tilesets](tilesets.md). |
| Mod code object | Its key. See [Code objects](objects.md). |

The room resolves these at any load order. When the mod of an item is off, the game shows a placeholder item and keeps the reference. A code object of a mod that is off stays in the room and does nothing.

A room name must be unique. Use a prefix for your rooms, for example `mymod_spider_den`.

To send a player to a room of your mod:

```lua
myco.add_command("den", "den - go to the spider den", function(args, world, player)
    world:teleport_player_to_room("mymod_spider_den")
end)
```

The room script API (script nodes in Room Builder) is a different API. It is not in this reference.

## Steam Workshop

Upload a mod folder with the Workshop Uploader tool. The tool writes two files into the mod folder. Keep them, so the next upload updates the same Workshop item.

| File | Contents |
|---|---|
| `workshop_id.txt` | The id of the Workshop item. |
| `workshop_meta.txt` | Upload data of the tool: the visibility, the tags and the description. |

The first upload takes the title and the description from `mod.toml`.

The preview image of the item is the [`icon`](getting-started.md#icon) of `mod.toml`. The uploader shows it, with its file, its size in pixels and its size in KB, so you can see that it is the right image. You cannot pick a different preview in the uploader. Change `icon` in `mod.toml` and select the mod again.

An icon that is not square goes to Steam as a copy stretched to a square, the same as the game shows it. Your icon file does not change. The copy is at most 1024 x 1024 pixels. A copy over 1024 KB is made again at 512 x 512.

### Tags

The uploader gives each item one type tag. It picks the tag from what the mod does. You cannot change it, so a player can trust it when they filter the Workshop.

| Type tag | When | Who needs the mod online |
|---|---|---|
| `server/client-side` | The mod calls a Content function, such as `add_item` or `edit_entity`. | The host and each player, in the same version. |
| `server-side` | The mod adds no content, but calls a host-only function, such as `player:heal` or `world:spawn_entity`. | Only the host. |
| `client-side` | The mod adds no content and calls no host-only function: HUD, sound, texture packs. | Each player can use it alone. |

The uploader finds Content calls when it runs the top level of `mod.lua`. It finds host-only calls when it reads the `.lua` files of the mod, because those calls are in callbacks. A call in a `--` comment does not count. See [Online play](online.md#tiers) for each tier.

The other tags are checkboxes. The uploader turns a tag on the first time it finds a reason in the mod. After that it keeps your choice.

| Tag | Turned on when |
|---|---|
| `Room/Zone` | `rooms/` has a `.room` file. |
| `Tile pack` | `tilesets/` has an image, or the mod calls `replace_asset`. |

Hover the type tag in the uploader to see why the mod got it.

`workshop_uploader --tags` prints the tags of each mod in the mods folder and opens no window.

For players:

- A subscribed mod shows in the Mods menu with a `[Workshop]` tag.
- A Workshop mod is off until the player enables it.
- The Mods menu takes the `name`, `version`, `author` and `description` of each mod from its `mod.toml`.
- To show if a mod that is off adds content, the game runs its `mod.lua` one time in a separate Lua state where each API function does nothing.
- A Workshop mod and a local mod share one load order. The `requires` rules of `mod.toml` work across both.

Keep the top level of `mod.lua` free of work that needs real API results. A mod that is off runs it with API functions that do nothing.
