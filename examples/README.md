[Index](../README.md)

# Examples

Copy a folder into `mods/` to try it.

| Example | Shows |
|---|---|
| [simple_mod](simple_mod/mod.lua) | An item with its own icon, an enemy with its own animated sprite sheet, a recipe, a shop entry, two hooks |
| [hud_mod](hud_mod/mod.lua) | A kill counter on the HUD, a settings popup, a console command |
| [hot_potato](hot_potato/mod.lua) | Intervals, inventory checks, damage, one timer for each player |

## Add an example

Each example is one mod folder here. It needs:

- A `mod.toml` with `name`, `version`, `author`, `description` and `icon`. See [mod.toml](../docs/getting-started.md#modtoml).
- `icon.png`: the game icon, 512 x 512 pixels. Copy it from an example that is here, so all examples look the same.
- A `mod.lua` that loads with no error in the console.
- A `name` that no other example uses. Each example must load next to the others.
- A row in the table above that says what the example shows.

Keep an example small. One example shows one idea well.
