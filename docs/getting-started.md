[Index](../README.md) | Next: [Environment](environment.md)

# Getting started

## Mod folder

Each mod is one folder in `mods/`, next to the game executable.

```
mods/
  my_mod/
    mod.lua
    items.lua
    hud.png
    rooms/
      my_room.room
```

| File | Required | Use |
|---|---|---|
| `mod.lua` | yes | Entry file. The game runs it one time for each load. |
| other `.lua` files | no | Load them with `dofile(MOD_DIR .. "/items.lua")`. |
| images | no | Draw them with `caffeine.ui_image`. See [Custom UI](ui.md). |
| `rooms/*.room` | no | Rooms. See [Rooms and Workshop](rooms-and-workshop.md). |

A folder with no `mod.lua` is ignored.

## mod.lua

`mod.lua` must set three globals. Set them first, before any `caffeine.add_*` call.

```lua
name = "My Mod"
version = "1.0.0"
author = "your_name"
```

| Global | Use |
|---|---|
| `name` | Name in the Mods menu. It is also the identity of the mod. |
| `version` | Version text. Online play compares it. |
| `author` | Author text in the Mods menu. |

Do not change `name` after release. Saves and room files store a mod item as `name:item name`, so a new name breaks them.

The game gives each mod one more global:

| Global | Value |
|---|---|
| `MOD_DIR` | Path of the folder of this mod. |

## Split a mod into files

```lua
name = "Big Mod"
version = "1.0.0"
author = "your_name"

dofile(MOD_DIR .. "/items.lua")
dofile(MOD_DIR .. "/enemies.lua")
```

All files of one mod share the globals of that mod. A global that `items.lua` sets is visible in `enemies.lua`. `dofile` also returns what the file returns.

## When mods load

Mods load at three times:

- when the game starts
- each time a game session starts (Play from the main menu)
- when you close the Mods menu after a change

The top level of `mod.lua` runs at each load. It registers content and callbacks. The callbacks run later, during play.

Functions that need a game session, such as `spawn_entity`, do nothing at the top level. Call them from a callback.

## The Mods menu

The Mods menu lists each mod, in load order.

| Action | Result |
|---|---|
| Drag a mod | Changes the load order. |
| Select a mod | Enables or disables it. |
| Close the menu | Applies the changes. The game loads all mods again, with no restart. |

A mod that failed to load shows as `[Failed]` with the error text. See [Errors](environment.md#errors).

## Tools

| Tool | Use |
|---|---|
| Picker | Shows a spritesheet as a grid. Click a tile to get its index for `icon_tile_id` or `sprite_tile_id`. Items and entities use different sheets. |
| Room Builder | Makes `.room` files. |
| Workshop Uploader | Uploads a mod folder to the Steam Workshop. |

## Debugging

Open the in-game console with `~`.

| Console line | Meaning |
|---|---|
| `[MOD OK] name version by author` | The mod loaded. |
| `[MOD FAIL] folder: error` | The mod failed at load. It registered nothing. |
| `[MOD ERROR] name: callback: error` | A callback raised an error during play. |

`caffeine.log(msg)` writes a line to the console.

Useful console commands:

| Command | Use |
|---|---|
| `list items` | Prints each item with its key. |
| `list enemies` | Prints each entity type. |
| `additem <item> [qty]` | Gives an item. |
| `help` | Lists each command, with the commands of mods. |

A fast work loop: edit the file, go to the main menu, press Play, read the console. Each new session loads the mods again, so the game does not need a restart.
