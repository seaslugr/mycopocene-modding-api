[Index](../README.md) | Next: [Environment](environment.md)

# Getting started

## Mod folder

Each mod is one folder in `mods/`, next to the game executable.

```
mods/
  my_mod/
    mod.toml
    mod.lua
    items.lua
    hud.png
    rooms/
      my_room.room
```

| File | Required | Use |
|---|---|---|
| `mod.toml` | yes | Name, version, author, description and dependencies. See [mod.toml](#modtoml). |
| `mod.lua` | yes | Entry file. The game runs it one time for each load. |
| other `.lua` files | no | Load them with `dofile(MOD_DIR .. "/items.lua")`. |
| images | no | Item icons ([Items](items.md#icons)), entity sprites ([Entities](entities.md#sprites)) and HUD images ([Custom UI](ui.md)). |
| `rooms/*.room` | no | Rooms. See [Rooms and Workshop](rooms-and-workshop.md). |
| `tilesets/*.png` | no | Tilesets for the rooms of the mod. See [Tilesets and texture packs](tilesets.md). |

A folder with no `mod.lua` and no `mod.toml` is ignored. A folder with only one of the two fails with an error in the Mods menu.

## mod.toml

`mod.toml` describes the mod. The game reads it before any Lua runs, so it knows the name and the load order of each mod first.

```toml
name = "My Mod"
version = "1.0.0"
author = "your_name"
icon = "icon.png"
description = "Adds spiders and the things they drop."
requires = ["Spider Lib >= 1.2"]
load_after = ["Cave Sounds"]
```

| Key | Required | Use |
|---|---|---|
| `name` | yes | Name in the Mods menu. It is also the identity of the mod, so two mods cannot have the same name. `My Mod` and `My_Mod` count as the same name. At most 62 characters. |
| `version` | yes | Version text. It must start with a number, such as `"1.0.0"`. Online play and `requires` compare it. |
| `author` | yes | Author text in the Mods menu. |
| `icon` | no | Image of the mod in the Mods menu and on the Steam Workshop. See [icon](#icon). |
| `description` | no | Text in the Mods menu, shown when the mod is selected. |
| `requires` | no | Mods that must load first. See [Dependencies](#dependencies). |
| `load_after` | no | Mods that load first when they are on. |
| `load_before` | no | Mods that load after this one when they are on. |

Do not change `name` after release. Saves and room files store a mod item as `name:item name`, so a new name breaks them.

### File format

`mod.toml` uses a small part of [TOML](https://toml.io):

- Each line is `key = value`. A `#` starts a comment.
- A value is text in quotes, or a list of texts in `[ ]`. A list can go over more than one line.
- Text in `"double quotes"` takes escapes: `\n` for a new line, `\"` for a quote, `\\` for a backslash, `é` for a character.
- Text in `'single quotes'` takes no escapes.
- Text in `"""three quotes"""` can go over more than one line. A line end right after the opening quotes is dropped.

A key the game does not know, a key two times, a number with no quotes and a `[table]` are errors. The error gives the line.

### icon

`icon` is the path of an image in the mod folder. The Mods menu of the game shows it next to the mod, and the Workshop Uploader sends it to Steam as the preview image of the item.

| | Value |
|---|---|
| Size | 512 x 512 pixels. |
| Shape | Square. An image that is not square is stretched to a square in the game, in the uploader and on the Workshop. |
| File types | `.png`, `.jpg`, `.jpeg` or `.gif`. Use PNG. |
| File size | 1024 KB at most. Steam does not take a larger preview. |
| Place | A path in the mod folder, such as `"icon.png"` or `"art/icon.png"`. |

Pixel art can be smaller. An icon of 64 x 64 pixels or less shows with hard edges, with no smoothing. A larger icon shows smooth when the game makes it smaller.

A mod with no `icon` shows an empty square, and its Workshop item has no preview. An `icon` that names a file that is not there stops the upload, and the uploader shows why.

### description

`description` is plain text. The Mods menu wraps it to the width of its column.

- A new line in the text starts a new line in the menu. An empty line makes a gap between paragraphs.
- The game keeps the first 1024 bytes.
- The menu shows the lines that fit in the column. Put the important part first.
- A mod that failed to load shows its error in place of the description.

```toml
description = """
Adds spiders and the things they drop.

Needs no other mod. Safe to add to a save in progress."""
```

### Dependencies

`requires` lists mods that this mod needs. Each entry is a mod `name`, with an optional version check.

```toml
requires = [
    "Spider Lib >= 1.2",
    "Core Lib",
]
```

| Check | Meaning |
|---|---|
| `"Core Lib"` | Any version. |
| `"Core Lib >= 1.2"` | 1.2 or later. |
| `"Core Lib > 1.2"` | Later than 1.2. |
| `"Core Lib = 1.2"` or `"Core Lib == 1.2"` | Exactly 1.2. |
| `"Core Lib < 2"` | Before 2. |
| `"Core Lib <= 1.9"` | 1.9 or before. |

The game compares versions number by number, so `1.10` is later than `1.9`. A missing part is 0, so `1.2` is the same as `1.2.0`. Text after the numbers, such as `-beta`, is ignored.

A required mod always loads before the mod that requires it, whatever the order in the Mods menu.

The mod fails with an error in the Mods menu when a required mod:

| Problem | Error |
|---|---|
| Is not installed | `needs 'Core Lib', which is not installed` |
| Is off | `needs 'Core Lib', which is off. Turn it on in the Mods menu` |
| Failed to load | `needs 'Core Lib', which did not load` |
| Has a version that does not match | `needs 'Core Lib >= 1.2', but 'Core Lib' is version 1.0.0` |

A failure goes on: a mod that requires a failed mod fails too.

`load_after` and `load_before` set the order only. Use them for a mod that works alone but must run after another mod when both are on, for example to edit the items of that mod. A name that is not installed or is off does nothing.

```toml
load_after = ["Cave Sounds"]
load_before = ["Late Mod"]
```

Rules that make a loop, such as A after B and B after A, fail each mod in the loop. The error names the other mods of the loop.

### Globals from mod.toml

The game gives each mod three globals:

| Global | Value |
|---|---|
| `MOD_DIR` | Path of the folder of this mod. |
| `MOD_NAME` | The `name` from `mod.toml`. |
| `MOD_VERSION` | The `version` from `mod.toml`. |

## Split a mod into files

```lua
dofile(MOD_DIR .. "/items.lua")
dofile(MOD_DIR .. "/enemies.lua")
```

All files of one mod share the globals of that mod. A global that `items.lua` sets is visible in `enemies.lua`. `dofile` also returns what the file returns.

`dofile("items.lua")` works too: a relative path starts at the folder of the mod. A file outside the mod folder cannot be loaded. See [Sandbox](environment.md#sandbox).

Register all items, entities, recipes and other content in these files, while the mod loads. A content function in a callback raises an error.

## When mods load

Mods load at three times:

- when the game starts
- each time a game session starts (Play from the main menu)
- when you close the Mods menu after a change

The top level of `mod.lua` runs at each load. It registers content and callbacks. The callbacks run later, during play.

Functions that need a game session, such as `spawn_entity`, do nothing at the top level. Call them from a callback.

## The Mods menu

The Mods menu has two columns. The left column lists each mod in load order. The right column shows the mod that is selected: its author, version, source, type, folder, requires, status and description.

| Action | Result |
|---|---|
| Click the checkbox of a mod | Enables or disables it. |
| Drag a mod | Changes the load order. A move that breaks a `requires` or a `load_after` rule is put back when the mods load again. |
| Left and Right, or LB and RB on a pad | Move the selected mod up and down in the load order. |
| Close the menu | Applies the changes. The game loads all mods again, with no restart. |

A mod that failed to load shows `Failed to load` in the list. Select it to read the full error in the right column. See [Errors](environment.md#errors).

## Tools

| Tool | Use |
|---|---|
| Picker | Shows an image as a grid of tiles and gives you the numbers of a tile. See [Picker](#picker). |
| Room Builder | Makes `.room` files. |
| Workshop Uploader | Uploads a mod folder to the Steam Workshop. |

## Picker

The Picker shows each image of a folder as a grid of 16 pixel tiles. Use it to find `icon_index` for an item and `x`, `y` and `frames` for an animation clip.

1. Start the Picker. Open your mod folder with `File > Open Folder...` (Ctrl+O). The dialog lists each mod in `mods/` under Places. You can also start it as `picker <folder>`.
2. Click an image in the list at the right.
3. Click a tile. Drag across tiles to select a run of animation frames. The sidebar plays a selected run as an animation.
4. Copy what you need.

| Copy | Key | Clipboard text for tile 4, a run of 2 tiles in `sprites/items.png` |
|---|---|---|
| Index | `C` | `4` |
| x and y | `X` | `x = 1, y = 1` |
| Lua icon fields | `L` | `icon = "sprites/items.png", icon_index = 4, anim_frames = 2, anim_speed = 0.2,` |
| Lua animation clip | `K` | `{ x = 1, y = 1, frames = 2, speed = 0.12, loop = true },` |

The file path in the Lua icon text is relative to the folder you opened. Open the mod folder itself, and the text is correct for `mod.lua` as it is.

A left click also copies the index. `F1` shows all keys. The Picker remembers the last folder.

`File > Game Assets` shows the sheets of the base game, for `icon_tile_id` and `sprite_tile_id`.

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
