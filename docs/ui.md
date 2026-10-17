[Index](../README.md) | Previous: [Sound and music](audio.md) | Next: [Keybinds](keybinds.md)

# Custom UI

Mods draw in screen space, with the HUD.

## Units

Everything is in pixels. `(0, 0)` is the top left of the screen.

Design your UI for a 1920 x 1080 screen. On a 1080p monitor, one UI pixel is one screen pixel. On a 4K monitor, the game makes everything two times bigger, so your UI looks the same.

The screen size changes with the monitor. A wide monitor gives a wider screen. A 1440p monitor gives 2560 x 1440. Thus a fixed right or bottom position does not stay at the edge. Use an [anchor](#anchors), or get the size with `ui_screen_size()`.

```lua
-- A 200 pixel bar, 10 pixels from the bottom right corner, on every screen.
myco.ui_rect(10, 10, 200, 20, 255, 0, 0, 255, "bottom_right")
```

Text `size` is a font size. The text is about 1.8 times that height in pixels, so size `16` text is about 28 pixels high.

To find a position, type `cursor` in the console. The game then shows the position of the mouse next to it. The `UI` numbers are the `x, y` for the draw functions with the default `"top_left"` anchor. Hold Ctrl to move the mouse slowly. Type `cursor` again to hide it.

## myco.on_draw_ui

```lua
local handle = myco.on_draw_ui(fn)
```

Calls `fn()` one time for each frame of a game session, also while the game is paused. It does not run in the main menu. The draw functions work only in this callback. The callback gets no `world` and no `player`. To act on a player from a key, see [Keys that change the game](#keys-that-change-the-game). Returns a handle. [`myco.remove_hook(handle)`](hooks.md#mycoremove_hook) stops the listener from the next frame.

```lua
myco.on_draw_ui(function()
    myco.ui_rect(10, 10, 180, 30, 0, 0, 0, 160)
    myco.ui_text("Hello from my mod", 18, 16, 16)
end)
```

The UI is immediate mode. Draw all of it on each frame. Keep the state in local variables of the mod.

## Draw functions

| Function | Returns | Description |
|---|---|---|
| `myco.ui_image(image, x, y, w, h, anchor)` | nothing | Draws an [image](#images) from the folder of the mod. `w, h` default to the image size. |
| `myco.ui_text(text, x, y, size, r, g, b, a, anchor)` | nothing | Draws text. `size` defaults to `16`. The color defaults to white. |
| `myco.ui_rect(x, y, w, h, r, g, b, a, anchor)` | nothing | Draws a filled rectangle. The color defaults to white. |
| `myco.ui_button(label, x, y, h, size, anchor, w, image)` | boolean | Draws a button. `true` on the frame of a click. `size` is the label size and defaults to `18`. `w = 0` fits the label and the image. `image` is optional. |
| `myco.ui_checkbox(label, checked, x, y, w, h, anchor)` | boolean | Draws a checkbox. Returns the new state. |
| `myco.ui_slider(id, value, min, max, x, y, w, h, anchor)` | number | Draws a slider. Returns the new value. |
| `myco.ui_screen_size()` | number, number | Screen width and height, in UI pixels. See [Units](#units). |

Colors `r, g, b, a` are `0` to `255`.

### Images

`image` is a path, or a [sprite sheet](#sprite-sheets) table. The path is relative to the folder of the mod and must stay in it. An absolute path, a path with `:` or a path with `..` draws nothing. The game loads the file one time and keeps it.

```lua
myco.on_draw_ui(function()
    myco.ui_image("icons/skull.png", 10, 10, 32, 32)
end)
```

A file that does not load gives one console error. The image is then skipped.

#### Sprite sheets

To draw one part of an image, give a table in place of the path:

```lua
myco.ui_image({ path = "icons.png", x = 16, y = 0, w = 16, h = 16 }, 10, 10, 32, 32)
```

`x, y` default to `0`. `w, h` default to the rest of the image. A part outside the image raises an error. `ui_button` takes the same table.

### Buttons

```lua
local clicks = 0

myco.on_draw_ui(function()
    if myco.ui_button("Click me", 10, 10, 28) then
        clicks = clicks + 1
    end
    myco.ui_text("Clicks: " .. clicks, 120, 16, 14)
end)
```

`anchor` is argument 6 and `w` is argument 7. To set a width with the default anchor, write `myco.ui_button("Cancel", 10, 50, 28, 18, "top_left", 120)`.

A click on a mod button does not also fire a game action bound to the mouse.

#### Image buttons

`image` is argument 8. It is a path or a [sprite sheet](#sprite-sheets) table.

```lua
myco.on_draw_ui(function()
    -- An image at the left of the label.
    if myco.ui_button("Bombs", 10, 10, 32, 16, "top_left", 0, "icons/bomb.png") then
        myco.log("bombs")
    end
    -- An image only.
    if myco.ui_button("", 10, 50, 32, 16, "top_left", 0, "icons/gear.png") then
        myco.ui_popup_open()
    end
end)
```

- The image is as high as the button, less 4 pixels at the top and 4 at the bottom. Its width follows its aspect ratio.
- With a label, the image and the label are centered together. With `""`, the image is centered.
- An image that does not load gives a text-only button.

### Checkboxes and sliders

Pass the current value in. Keep the value the function returns.

```lua
local enabled = false
local volume = 0.5

myco.on_draw_ui(function()
    enabled = myco.ui_checkbox("Enable", enabled, 10, 10, 140, 20)
    volume = myco.ui_slider("volume", volume, 0, 1, 10, 40, 160, 20)
end)
```

`w` of a checkbox is the full click width, with the label. `h` is the box size.

`id` of a slider is a string. Each slider on screen needs its own `id`. It lets a drag continue when the mouse leaves the track.

## Anchors

`anchor` selects the screen point that `x, y` start from.

| | Left | Center | Right |
|---|---|---|---|
| Top | `"top_left"` (default) | `"top_center"` | `"top_right"` |
| Middle | `"middle_left"` | `"center"` | `"middle_right"` |
| Bottom | `"bottom_left"` | `"bottom_center"` | `"bottom_right"` |

- With an edge, `x` or `y` is the margin from that edge. The same edge of the element sits on it. With `"bottom_right"`, the bottom right corner of the element is `x` pixels from the right edge and `y` pixels from the bottom edge.
- With a center, `x` or `y` is an offset from the center of the screen. The middle of the element sits on it. A positive `x` moves right, and a positive `y` moves down.

The layout stays correct at each resolution.

```lua
myco.on_draw_ui(function()
    myco.ui_image("icon.png", 10, 10, 64, 64, "bottom_right")
    myco.ui_text("My Mod", 0, 20, 24, 255, 255, 255, 255, "top_center")
end)
```

To pass `anchor` to `ui_text` or `ui_rect`, you must also pass the color.

## Popups

| Function | Description |
|---|---|
| `myco.ui_popup_open()` | Sets the popup flag. |
| `myco.ui_popup_close()` | Clears the flag. |
| `myco.ui_popup_is_open()` | Returns the flag. |

While the flag is set, gameplay is paused and Escape clears the flag. The game draws nothing for the popup. Draw it yourself in `on_draw_ui` when `ui_popup_is_open()` is `true`.

```lua
myco.on_draw_ui(function()
    if myco.ui_button("Menu", 10, 10, 28) then
        myco.ui_popup_open()
    end
    if myco.ui_popup_is_open() then
        local w, h = myco.ui_screen_size()
        myco.ui_rect(0, 0, w, h, 0, 0, 0, 160)
        myco.ui_text("Paused by a mod", 0, -30, 28, 255, 255, 255, 255, "center")
        if myco.ui_button("Close", -40, 20, 32, 18, "center") then
            myco.ui_popup_close()
        end
    end
end)
```

Read the flag with `ui_popup_is_open()`. Do not keep your own copy, because Escape clears the flag in the game.

All mods share the one flag, so only one mod popup can be open.

## Scroll regions

```lua
scroll = myco.ui_scroll_begin(x, y, w, h, content_h, scroll, anchor)
myco.ui_scroll_end()
```

`ui_scroll_begin` starts a clipped region and returns the new scroll offset. `ui_scroll_end` closes it.

| Argument | Description |
|---|---|
| `x, y, w, h` | The window on screen. `anchor` applies to it. |
| `content_h` | Full height of the content. |
| `scroll` | Current offset. Start at `0` and pass the returned value on the next frame. |

Between the two calls, `x, y` of each draw function start at the top left of the content, and `anchor` is ignored. The mouse wheel scrolls the region when the cursor is on it. Regions do not nest.

```lua
local scroll = 0
local rows = { "Sword", "Shield", "Potion", "Bow", "Ring", "Amulet", "Boots" }

myco.on_draw_ui(function()
    scroll = myco.ui_scroll_begin(10, 10, 150, 100, #rows * 24, scroll)
    for i, row in ipairs(rows) do
        myco.ui_text(row, 4, (i - 1) * 24, 16)
    end
    myco.ui_scroll_end()
end)
```

## Keyboard

| Function | Returns | Description |
|---|---|---|
| `myco.key_pressed(name)` | boolean | `true` on the frame the key goes down. |
| `myco.key_down(name)` | boolean | `true` while the key is down. |
| `myco.key_released(name)` | boolean | `true` on the frame the key goes up. |
| `myco.get_char_pressed()` | integer or nil | Next typed codepoint. `nil` when the queue is empty. |
| `myco.ui_capture_keyboard(on)` | nothing | While `true`, the game ignores its own keyboard actions. |

Key names: `"a"` to `"z"`, `"0"` to `"9"`, `"space"`, `"enter"`, `"return"`, `"escape"`, `"backspace"`, `"tab"`, `"delete"`, `"left"`, `"right"`, `"up"`, `"down"`, `"shift"`, `"ctrl"`, `"alt"`.

- A letter can be upper or lower case.
- `"shift"`, `"ctrl"` and `"alt"` are the keys on the left side of the keyboard.
- An unknown name gives `false` and no error.
- While the player types in the console or the chat, the key functions give `false` and `get_char_pressed` gives `nil`. Your own text field with `ui_capture_keyboard` still reads its keys.

For a key that acts on the game, use [`add_keybind`](keybinds.md). The player can change that key in the settings.

Read keys in `on_draw_ui`. It runs one time for each frame, so `key_pressed` and `key_released` see each press one time. In a passive or a hook they can miss a press or see it two times. `key_down` works in each callback.

```lua
local show = true

myco.on_draw_ui(function()
    if myco.key_pressed("h") then
        show = not show
    end
    if show then
        myco.ui_text("press H to hide", 10, 10, 14)
    end
end)
```

### Keys that change the game

`on_draw_ui` gets no `world` and no `player`. To make a key act on a player, use [`add_keybind`](keybinds.md). Its callback gets the `world` and the `player` that pressed the key.

This example spawns an enemy next to the player for each press of G:

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

`spawn_entity` is host only. See [World methods](players-and-worlds.md#world-methods).

### A text field

There is no text field widget. Make one with `get_char_pressed`.

```lua
local text = ""
local focused = false

myco.on_draw_ui(function()
    if myco.ui_button(focused and "Done" or "Edit", 10, 10, 26) then
        focused = not focused
        myco.ui_capture_keyboard(focused)
    end
    if focused then
        local cp = myco.get_char_pressed()
        while cp do
            text = text .. utf8.char(cp)
            cp = myco.get_char_pressed()
        end
        if myco.key_pressed("backspace") then
            -- Remove the last character. A character can be more than one byte.
            local last = utf8.offset(text, -1)
            if last then
                text = text:sub(1, last - 1)
            end
        end
    end
    myco.ui_text(text, 90, 14, 16)
end)
```

Call `ui_capture_keyboard(false)` when the field loses focus. If you do not, the player cannot move.

## Limits

| Thing | Limit |
|---|---|
| `on_draw_ui` listeners | 64 |
| Images in use | 256 |
| Image path length | 255 bytes |
| Draw calls in one frame, across all mods | 256 |
| Text length of one draw call | 191 bytes |
