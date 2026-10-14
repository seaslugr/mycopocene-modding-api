[Index](../README.md) | Previous: [Getting started](getting-started.md) | Next: [Ids, keys and refs](ids.md)

# Environment

## Globals

Each mod runs in its own global table. A global in one mod does not change a global in a different mod. All files of one mod share the table of that mod.

| Global | Value |
|---|---|
| `caffeine` | The API table. |
| `MOD_DIR` | Path of the folder of this mod. |
| `MOD_NAME`, `MOD_VERSION` | The `name` and the `version` from [mod.toml](getting-started.md#modtoml). |
| `math`, `string`, `table`, `utf8` | Standard Lua 5.4 libraries. |
| base functions | `pairs`, `ipairs`, `next`, `select`, `type`, `tostring`, `tonumber`, `pcall`, `error`, `assert`, `setmetatable`, `getmetatable`, `rawget`, `rawset`, `load`, `loadfile`, `dofile`, and the rest of the base library. |

Two mods cannot share data through globals. Each mod gets its own copy of the library tables (`caffeine`, `string`, `math`, `table`, `utf8`). A change to `string.format` or to a `caffeine` function in your mod changes your mod only.

`getmetatable` gives the text `"locked"` for a string, a Player, a World and a mod object. The game shares these metatables between all mods and the room scripts, so no mod can change them. A method call such as `("x"):upper()` uses the library of the game, and your copy of `string` does not change it.

For speed, put the API functions you call each frame in a `local`.

```lua
local ui_text = caffeine.ui_text
```

## Sandbox

These do not exist: `io`, `os`, `package`, `require`, `debug`.

`load`, `loadfile` and `dofile` accept Lua source only. Compiled bytecode is refused. A chunk you load runs in the global table of your mod.

`loadfile` and `dofile` read files from the folder of your mod only. Give the path as `MOD_DIR .. "/items.lua"` or relative to the folder, as `"items.lua"`. An absolute path, a path with `:`, or a path with `..` raises the error `the path '...' must stay in the folder of the mod`. Each other function that takes a file of your mod (`icon`, `sheet`, `ui_image`, `load_sound`, `load_music`, `replace_asset`) has the same rule.

## Time limits

A watchdog stops a script that runs too long. The script gets the error `script exceeded its execution time budget`.

| Call | Time limit |
|---|---|
| `mod.lua` at load | 5 seconds |
| Each callback | 0.25 seconds |

`pcall` cannot keep a script alive past its limit. After the limit, the error comes again on the next instruction, until it leaves the callback.

A call inside a callback cannot make the limit longer. For example, a callback that moves a player to a different room makes the room scripts run. The callback still stops at its own 0.25 seconds.

## Memory and string limits

| Thing | Limit |
|---|---|
| Lua memory of all mods together | 256 MiB |
| Lua memory of a disabled mod, while the Mods menu reads its name | 32 MiB |
| Steps of one pattern search (`string.find`, `match`, `gmatch`, `gsub`) | 20 million |

Past the memory limit, the call gets the error `not enough memory`. A pattern that needs too many steps gets the error `pattern too slow`. A normal pattern on a normal string uses far fewer steps. A pattern such as `".-.-.-.-b"` on a long string can need billions.

## Errors

### At load

An error at the top level of `mod.lua` fails the mod. A mod also fails when its `mod.toml` is missing or has an error, and when a mod it requires is not there, is off, failed, or has the wrong version. See [Dependencies](getting-started.md#dependencies).

Two mods cannot have the same `name`. The game compares names with `_` in place of each space, so `My Mod` and `My_Mod` are the same name. The mod higher in the load order loads. The other one fails with `the mod 'My Mod' has the same name. Rename one of them`.

A failed mod registers nothing. The game starts the load again without it, so half of a mod is never active. The other mods load as usual.

- The Mods menu shows `Failed to load` for the mod. Select it to read the full error text.
- The console shows `[MOD FAIL] folder: error`.

### In a callback

An error in a callback goes to the console as `[MOD ERROR] mod name: callback: message`. The game continues.

A callback that fails 8 times in a row is disabled until the next reload. One success resets the count.

### In a definition

The game checks each definition table.

| Problem | Example error |
|---|---|
| Wrong type | `'max_stack' must be a number` |
| Unknown enum text | `'gear_group' has unknown value 'axe'` |
| Unknown item | `unknown item 'helth_vial'` |
| Missing required field | `add_item: 'name' is missing` |
| Too many entries | `'stats' has 7 entries, the limit is 6` |

Use `pcall` if a definition can fail and the mod must continue.

### Content functions after the load

The functions that add or change definitions work only while the mod loads: at the top of `mod.lua`, or in a file it runs with `dofile`. These are `add_item`, `add_entity`, `add_recipe`, `add_shop_entry`, `add_fluid`, `add_status`, `add_object`, and each `edit_*` and `remove_shop_entry`. In a callback they raise the error `add_item works only while the mod loads`.

Online, the host and each guest must have the same definitions. A change in a callback would happen on one machine only. See [Online](online.md#content-mods).

## Load order

Mods load from the top of the Mods menu to the bottom. When two mods edit the same field, the mod lower in the list wins, because it runs last.

The `requires`, `load_after` and `load_before` rules of [mod.toml](getting-started.md#dependencies) come first. A mod waits until each mod it must follow has loaded. Apart from that, the mods keep the order of the menu. Local mods and Workshop mods share one order.

After a load, the Mods menu and `load_order.txt` show the order the mods really loaded in.

The load order sets the ids of mod items, entities, statuses and fluids. Online, a guest must load the content mods in the same order as the host. See [Online](online.md#content-mods).

Listeners of the same hook run in load order.

The game stores the order and the enabled state in `load_order.txt` in the user data folder.

| Platform | User data folder |
|---|---|
| Linux | `$XDG_DATA_HOME/mycopocene/` or `~/.local/share/mycopocene/` |
| Windows | `%APPDATA%\Mycopocene\` |

## Limits

| Thing | Limit |
|---|---|
| Mods | 64 |
| Listeners for one hook, across all mods | 64 |
| Passives | 64 |
| Intervals | 64 |
| `on_draw_ui` listeners | 64 |
| Console commands | 64 |
| UI images in use | 64 |
| Item icon images, across all mods | 256 |
| Item icon tiles, across all mods | 3872 |
| Replaced game files, across all mods | 256 |
| Sounds, across all mods | 128 |
| Music tracks, across all mods | 32 |
| Fluids, with the built-in ones | 64 |
| Mod statuses | 64 |
| Mod code objects | 64 |
| Placed mod objects that run at one time | 256 |
| UI draw calls in one frame | 256 |
| Stats on an item | 6 |
| Loot entries on an entity | 8 |
| Recipe ingredients | 64 |
| Shape cells of a Modification | 5 |

A registration past a limit raises an error. A UI draw call past the limit is not drawn.
