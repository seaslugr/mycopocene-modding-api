[Index](../README.md) | Previous: [Custom UI](ui.md) | Next: [Online play](online.md)

# Mod data

A mod can keep data between game sessions: settings, unlocks, a high score. Each saved value is one JSON file.

```lua
local stats = caffeine.load_data("stats") or { runs = 0 }

caffeine.on_run_end(function(world, player)
    stats.runs = stats.runs + 1
    caffeine.save_data("stats", stats)
end)
```

## Where the files are

Each mod gets its own folder in the user data folder of the game:

| Platform | Folder |
|---|---|
| Linux | `~/.local/share/mycopocene/mods/My_Mod/` (or `$XDG_DATA_HOME/mycopocene/mods/My_Mod/`) |
| Windows | `%APPDATA%\Mycopocene\mods\My_Mod\` |

The folder name is the `name` of the mod, with `_` for each character that is no letter, digit or `-`. `caffeine.save_data("stats", ...)` writes `stats.json` in that folder.

The data is on this machine only. It is the same for each save slot and each player. Online, the host and each guest have their own data.

## caffeine.save_data

```lua
local ok, err = caffeine.save_data(name, value)
```

Writes `value` to the file `name`. Returns `true`. When the disk write fails, returns `false` and a message, and the old file stays.

`name` is 1 to 64 letters, digits, `_` or `-`. Any other name raises an error.

| `value` can hold | Saved as |
|---|---|
| table with the keys `1, 2, 3...` | a JSON list |
| table with string keys | a JSON object |
| string, number, boolean | the same |
| `nil` | `null` |

These raise an error, and the old file stays:

- A function, userdata or other type.
- A table with both list items and string keys, or with number keys that are not `1, 2, 3...` with no gap.
- `nan` or `inf`.
- More than 64 levels of tables in tables, or a table that holds itself.
- More than 1 MiB of JSON text.

The game writes a temp file, then puts it in place of the old file. The old file becomes a backup. A crash during a save never leaves a half-written file.

## caffeine.load_data

```lua
local value, err = caffeine.load_data(name)
```

Returns the saved value. Returns `nil` when there is no file. An empty table comes back as an empty table.

When the file is broken (a person edited it, or the disk failed), the game reads the backup. When no copy reads, it returns `nil` and a message.

A number with no `.` or `e` loads as an integer. Other numbers load as floats.

## caffeine.delete_data

```lua
local removed = caffeine.delete_data(name)
```

Deletes the file and its backup. Returns `true` if a file was there.

## Rules

- The data functions work at load and in callbacks. They work on a guest too.
- Each call reads or writes the disk. Do not call them each frame. Load the data one time at load, keep it in a local, and save when it changes.
- The console command `savewipe` deletes the data of each enabled mod. The data of a disabled mod stays.
- A person can open and edit the files. They are indented JSON.
