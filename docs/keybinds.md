[Index](../README.md) | Previous: [Custom UI](ui.md) | Next: [Mod data](data.md)

# Keybinds

A keybind is a key that runs a callback of your mod. The player sees it in the settings and can change it.

```lua
myco.add_keybind({
    id = "spawn",
    name = "Spawn a Primitive",
    key = "G",
    on_press = function(world, player)
        local x, y = player:get_pos()
        world:spawn_entity("primitive", x + 150, y)
    end,
})
```

Use a keybind for each key that acts on the game. The callback gets the `world` and the `player` that pressed the key.

## myco.add_keybind

```lua
myco.add_keybind(def)
```

Adds one keybind. Call it only while the mod loads, at the top of `mod.lua` or a file it runs. A later call raises an error.

| Field | Type | Description |
|---|---|---|
| `id` | string | Required. 1 to 31 letters, digits or `_`. Unique in the mod. The settings file uses it, so do not change it. |
| `name` | string | Required. The label in the settings. |
| `key` | string | The default key or [key combination](#key-combinations). See [Key names](#key-names). With no `key`, the bind starts with no key. |
| `pad` | string | The default pad button. See [Pad button names](#pad-button-names). |
| `on_press` | function | `on_press(world, player)`. Runs when the key goes down. |
| `on_release` | function | `on_release(world, player)`. Runs when the key goes up. |

Give `on_press`, `on_release` or both. A bad field, an unknown key name or an `id` that the mod uses already raises an error.

## When the callback runs

- `player` is the player that pressed the key. In splitscreen, each player presses with their own keyboard or pad.
- The callback does not run while the game is paused, while the player has a menu open, or while the player types in the console or the chat.
- The callback does not run while a mod has [`ui_capture_keyboard`](ui.md#keyboard) on.
- A key that goes up during a pause or in a menu gives no `on_release`. Do not let a held state depend on `on_release` alone.
- Online, the callback runs on the machine of the player. The Authority functions are host only there, as in each callback. See [Online play](online.md).

## In the settings

The binds of each mod show in Settings, in the Keyboard tab and the Controller tab, below the binds of the game. Each mod has a header with its name. The player can give each bind a new key.

The game saves the keys of the player in its settings file, as `Mod Name:id=key,pad`. The keys stay when the mod is off. When the mod is on again, the keys come back.

When the default `key` is in use by the game or by a bind that loaded earlier, the bind starts with no key. The player can set one in the settings. The same rule applies to `pad`.

## Key names

Case does not matter. Spaces, `_` and `-` in a name do not matter, so `"Page Up"` and `"pageup"` are the same key.

| Keys | Names |
|---|---|
| Letters and digits | `"a"` to `"z"`, `"0"` to `"9"` |
| Punctuation | `` "`" ``, `"-"`, `"="`, `"["`, `"]"`, `"\\"`, `";"`, `"'"`, `","`, `"."`, `"/"` |
| Function keys | `"f1"` to `"f12"` |
| Editing | `"space"`, `"enter"` (or `"return"`), `"tab"`, `"escape"` (or `"esc"`), `"backspace"`, `"insert"`, `"delete"`, `"home"`, `"end"`, `"pageup"`, `"pagedown"`, `"capslock"` |
| Modifiers | `"shift"` (or `"leftshift"`), `"rightshift"`, `"ctrl"` (or `"leftctrl"`), `"rightctrl"`, `"alt"` (or `"leftalt"`), `"rightalt"` |
| Arrows | `"up"`, `"down"`, `"left"`, `"right"` |
| Mouse buttons | `"lmb"`, `"rmb"`, `"mmb"`, `"mouse4"`, `"mouse5"` |

## Key combinations

Join key names with `+`. The last name is the main key. The others are held keys: at most two, and keys of the keyboard only.

```lua
myco.add_keybind({
    id = "quick_save",
    name = "Quick Save",
    key = "Ctrl + S",
    on_press = function(world, player)
        myco.log("saved")
    end,
})
```

`"Shift+LMB"` and `"ctrl+shift+g"` also work. `"LMB+G"` raises an error, because a mouse button cannot be a held key.

- The bind is down while each of its keys is down. `on_press` runs when the last key goes down, in any order. `on_release` runs when the first key goes up.
- A held `"shift"`, `"ctrl"` or `"alt"` works with the key on either side.
- A combination wins over its main key alone. With `Ctrl + S` bound, a bind of S does not run while Ctrl is down.
- A bind of a held key alone still runs. If Dash is Shift, Shift + G also dashes when Shift goes down.

In the settings, the player sets a combination the same way: hold the keys down, then let go. The bind is set when the first key goes up. The settings show it as `Ctrl + S`.

Combinations are for the keyboard only. A pad bind is one button.

## Pad button names

| Button | Names |
|---|---|
| Face buttons | `"a"`, `"b"`, `"x"`, `"y"`, or `"cross"`, `"circle"`, `"square"`, `"triangle"` |
| D-pad | `"dpadup"`, `"dpaddown"`, `"dpadleft"`, `"dpadright"` |
| Shoulders | `"lb"` (or `"l1"`), `"rb"` (or `"r1"`), `"lt"` (or `"l2"`), `"rt"` (or `"r2"`) |
| Sticks | `"l3"`, `"r3"` |
| Other | `"start"` |

## Keybinds and key_pressed

[`key_pressed`](ui.md#keyboard) reads a fixed key in `on_draw_ui`. Use it for the controls of your own UI, such as a text field or a key that closes your popup.

| | `add_keybind` | `key_pressed` |
|---|---|---|
| The player can change the key | Yes | No |
| Gets `world` and `player` | Yes | No |
| Runs while the game is paused | No | Yes |

## Limits

| Thing | Limit |
|---|---|
| Keybinds, across all mods | 256 |
| Length of `id` | 31 characters |
