[Index](../README.md) | Previous: [Getting started](getting-started.md) | Next: [Ids, keys and refs](ids.md)

# Environment

## Globals

Each mod runs in its own global table. A global in one mod does not change a global in a different mod. All files of one mod share the table of that mod.

| Global | Value |
|---|---|
| `caffeine` | The API table. |
| `MOD_DIR` | Path of the folder of this mod. |
| `math`, `string`, `table`, `utf8` | Standard Lua 5.4 libraries. |
| base functions | `pairs`, `ipairs`, `next`, `select`, `type`, `tostring`, `tonumber`, `pcall`, `error`, `assert`, `setmetatable`, `getmetatable`, `rawget`, `rawset`, `load`, `loadfile`, `dofile`, and the rest of the base library. |

Two mods cannot share data through globals. The library tables (`string`, `math`, `table`, `utf8`) are the same tables in each mod, so do not change them.

For speed, put the API functions you call each frame in a `local`.

```lua
local ui_text = caffeine.ui_text
```

## Sandbox

These do not exist: `io`, `os`, `package`, `require`, `debug`.

`load`, `loadfile` and `dofile` accept Lua source only. Compiled bytecode is refused. A chunk you load runs in the global table of your mod.

## Time limits

A watchdog stops a script that runs too long. The script gets the error `script exceeded its execution time budget`.

| Call | Time limit |
|---|---|
| `mod.lua` at load | 5 seconds |
| Each callback | 0.25 seconds |

## Errors

### At load

An error at the top level of `mod.lua` fails the mod. A mod also fails when `name`, `version` or `author` is missing.

A failed mod registers nothing. The game starts the load again without it, so half of a mod is never active. The other mods load as usual.

- The Mods menu shows the mod as `[Failed]` with the error text.
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

## Load order

Mods load from the top of the Mods menu to the bottom. When two mods edit the same field, the mod lower in the list wins, because it runs last.

Listeners of the same hook run in load order.

The game stores the order and the enabled state in `load_order.txt` in the user data folder.

| Platform | User data folder |
|---|---|
| Linux | `$XDG_DATA_HOME/caffeine/` or `~/.local/share/caffeine/` |
| Windows | `%APPDATA%\Caffeine\` |

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
| UI draw calls in one frame | 256 |
| Stats on an item | 6 |
| Loot entries on an entity | 8 |
| Recipe ingredients | 64 |
| Shape cells of a Modification | 5 |

A registration past a limit raises an error. A UI draw call past the limit is not drawn.
