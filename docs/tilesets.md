[Index](../README.md) | Previous: [Recipes and shops](recipes-and-shops.md) | Next: [Fluids](fluids.md)

# Tilesets and texture packs

A mod can do two things with the art of the game:

- add a tileset that its rooms use
- replace an art, sound or font file of the base game

## Add a tileset

A tileset is an image of 16 pixel tiles. Put it in the `tilesets/` folder of the mod.

```
mods/
  my_mod/
    mod.lua
    tilesets/
      cave.png
      cave.prop
    rooms/
      mymod_cave_1.room
```

No Lua code is necessary. The Room Builder lists each image in `tilesets/` of each loaded mod, after the tilesets of the game. The list shows a mod tileset as `Mod Name: cave.png`.

To use it:

1. Start the Room Builder.
2. Open or make a room in the `rooms/` folder of the mod.
3. Select the tileset of the mod in the tileset list.
4. Paint and save.

Rules:

- The width and the height of the image must be a multiple of 16.
- A room uses one tileset. A tile id is the index of the tile in the image, row by row from 0.
- Do not move a tile to a different place in the image after rooms use it. The rooms store the index.
- To add tiles, add new rows at the bottom of the image. Keep the width the same. A wider image moves each tile to a new index.

### How a room stores the tileset

A room file stores the tileset of a mod as a portable reference:

```
tileset=mod:My_Mod/tilesets/cave.png
```

The form is `mod:` then the `name` of the mod with `_` for each space, then the file from the folder of the mod. The Room Builder writes this line. The room loads on each machine, in each folder the mod is installed to.

If the mod of the tileset is not loaded, the tiles of the room do not draw. The room keeps the reference, so nothing is lost when the mod is on again.

### Tile types

The Room Builder can give a tile a type (solid, platform, ladder, hazard, skylight, water). A type is a default for the flags of a tile when you paint it. `Tools > Set Tile Type from Flags` saves the types in a `.prop` file next to the image, here `tilesets/cave.prop`. Ship that file with the mod.

The game does not read the types. The flags of each cell are in the room file.

## Replace a file of the game

### myco.replace_asset

```lua
myco.replace_asset(asset, file)
```

Makes the game load `file` of the mod in place of the game file `asset`.

| Argument | Description |
|---|---|
| `asset` | Path of the game file, from the game folder. It starts with `assets/`. |
| `file` | Path of the replacement, from the mod folder. |

`mod.toml`:

```toml
name = "Autumn Pack"
version = "1.0.0"
author = "your_name"
description = "Autumn colors for the main tileset and the item icons."
```

`mod.lua`:

```lua
myco.replace_asset("assets/tileset.png", "art/tileset.png")
myco.replace_asset("assets/items/itemlist1.png", "art/items.png")
```

Rules:

- Only an image, a sound or a font can be replaced: `.png`, `.bmp`, `.jpg`, `.jpeg`, `.wav`, `.ogg`, `.mp3`, `.flac`, `.ttf`, `.otf`. A shader, a room and a script cannot.
- The replacement must have the same file type as the original.
- Keep the size and the layout of the original. The game finds each sprite by its position in the image. A sheet with a different width shows wrong sprites.
- When two mods replace the same file, the mod lower in the load order wins.
- A missing file, or a file that cannot be replaced, is a load error.
- All mods together can replace 256 files.

Use the Picker with `File > Game Assets` to see the sheets of the game and their layout.

Common files:

| File | Contents |
|---|---|
| `assets/tileset.png` | The main room tileset |
| `assets/items/itemlist1.png` | Item icons, 44 tiles in each row |
| `assets/objects.png` | World objects |
| `assets/enemies.png` | Enemy sprites |
| `assets/char.png` | The player, 32 pixel frames |
| `assets/particles.png` | Particles |
| `assets/ui/hud.png` | HUD frames |
| `assets/ui/status_effects.png` | Status effect icons |

### When a replacement shows

The game loads most art when a session starts, so a pack that you turn on in the Mods menu shows in the next session. A few files load one time when the game starts: fonts, the HUD sheet, the cursor and the button glyphs. Restart the game to see a change of those.

Music that the game streams from the disk is not replaced.

### Online

`replace_asset` changes only what this machine shows and plays. A mod that only replaces assets is not a content mod. A guest can use a texture pack that the host does not have.

## Which one to use

| Goal | Use |
|---|---|
| New rooms with new tile art | A tileset in `tilesets/` |
| A new look for the rooms of the base game | `replace_asset` on `assets/tileset.png` |
| A new icon for one item | [`icon`](items.md#icons) in `edit_item` |
| New art for one enemy | [`sheet`](entities.md#sprites) in `edit_entity` |
| New art for all items or all enemies | `replace_asset` on the sheet |
