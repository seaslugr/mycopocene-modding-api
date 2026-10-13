[Index](../README.md) | Previous: [Hooks and callbacks](hooks.md) | Next: [Custom UI](ui.md)

# Console

Open the in-game console with `~`.

## caffeine.log

```lua
caffeine.log(msg)
```

Writes a line to the console. `msg` must be a string or a number. Use `tostring` for other values.

```lua
caffeine.log("enemies: " .. world:get_enemy_count())
caffeine.log(tostring(player:get_stat("xp")))
```

## caffeine.add_command

```lua
caffeine.add_command(name, usage, fn)
```

Adds a command to the console.

| Argument | Description |
|---|---|
| `name` | The word the player types. No spaces, at most 31 characters. |
| `usage` | The line that `help` shows. |
| `fn` | The game calls `fn(args, world, player)`. |

| Callback argument | Value |
|---|---|
| `args` | The text after the command name, as one string. It is `""` when the player typed no arguments. |
| `world` | The world of player one. |
| `player` | Player one. |

```lua
caffeine.add_command("heal", "heal [amount] - heal player one", function(args, world, player)
    local amount = tonumber(args) or 100
    player:heal(amount)
    caffeine.log("healed " .. amount)
end)
```

Split `args` into words with `string.gmatch`:

```lua
caffeine.add_command("give", "give <item> [qty] - give an item to player one", function(args, world, player)
    local words = {}
    for word in args:gmatch("%S+") do
        words[#words + 1] = word
    end
    if not words[1] or not caffeine.get_item_id(words[1]) then
        caffeine.log("give: unknown item")
        return
    end
    player:give_item(words[1], tonumber(words[2]) or 1)
end)
```

### Rules

- A mod cannot replace a built-in command. The console tries its own commands first.
- Two mods cannot add the same command name. The second one gets an error.
- The command shows in `help` and in the autocomplete list.
- Online, only the host can run console commands.
- The limit is 64 mod commands.
