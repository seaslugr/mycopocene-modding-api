[Index](../README.md) | Previous: [Console](console.md) | Next: [Online play](online.md)

# Custom UI

Mods draw in screen space, with the HUD.

## caffeine.on_draw_ui

```lua
caffeine.on_draw_ui(fn)
```

Calls `fn()` one time for each frame. The draw functions work only in this callback. The callback gets no arguments.

```lua
caffeine.on_draw_ui(function()
    caffeine.ui_rect(10, 10, 180, 30, 0, 0, 0, 160)
    caffeine.ui_text("Hello from my mod", 18, 16, 16)
end)
```

The UI is immediate mode. Draw all of it on each frame. Keep the state in local variables of the mod.

## Draw functions

| Function | Returns | Description |
|---|---|---|
| `caffeine.ui_image(path, x, y, w, h, anchor)` | nothing | Draws an image from the folder of the mod. `w, h` default to the image size. |
| `caffeine.ui_text(text, x, y, size, r, g, b, a, anchor)` | nothing | Draws text. `size` defaults to `16`. The color defaults to white. |
| `caffeine.ui_rect(x, y, w, h, r, g, b, a, anchor)` | nothing | Draws a filled rectangle. The color defaults to white. |
| `caffeine.ui_button(label, x, y, h, size, anchor, w)` | boolean | Draws a button. `true` on the frame of a click. `size` is the label size and defaults to `18`. `w = 0` fits the label. |
| `caffeine.ui_checkbox(label, checked, x, y, w, h, anchor)` | boolean | Draws a checkbox. Returns the new state. |
| `caffeine.ui_slider(id, value, min, max, x, y, w, h, anchor)` | number | Draws a slider. Returns the new value. |
| `caffeine.ui_screen_size()` | number, number | Screen width and height. |

Colors `r, g, b, a` are `0` to `255`.

### Images

`path` is relative to the folder of the mod. The game loads the file one time and keeps it.

```lua
caffeine.on_draw_ui(function()
    caffeine.ui_image("icons/skull.png", 10, 10, 32, 32)
end)
```

A file that does not load gives one console error. The image is then skipped.

### Buttons

```lua
local clicks = 0

caffeine.on_draw_ui(function()
    if caffeine.ui_button("Click me", 10, 10, 28) then
        clicks = clicks + 1
    end
    caffeine.ui_text("Clicks: " .. clicks, 120, 16, 14)
end)
```

`anchor` is argument 6 and `w` is argument 7. To set a width with the default anchor, write `caffeine.ui_button("Cancel", 10, 50, 28, 18, "top_left", 120)`.

A click on a mod button does not also fire a game action bound to the mouse.

### Checkboxes and sliders

Pass the current value in. Keep the value the function returns.

```lua
local enabled = false
local volume = 0.5

caffeine.on_draw_ui(function()
    enabled = caffeine.ui_checkbox("Enable", enabled, 10, 10, 140, 20)
    volume = caffeine.ui_slider("volume", volume, 0, 1, 10, 40, 160, 20)
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

- With an edge, `x` or `y` is the margin from that edge.
- With a center, `x` or `y` is an offset from the center.

The layout stays correct at each resolution.

```lua
caffeine.on_draw_ui(function()
    caffeine.ui_image("icon.png", 10, 10, 64, 64, "bottom_right")
    caffeine.ui_text("My Mod", 0, 20, 24, 255, 255, 255, 255, "top_center")
end)
```

To pass `anchor` to `ui_text` or `ui_rect`, you must also pass the color.

## Popups

| Function | Description |
|---|---|
| `caffeine.ui_popup_open()` | Sets the popup flag. |
| `caffeine.ui_popup_close()` | Clears the flag. |
| `caffeine.ui_popup_is_open()` | Returns the flag. |

While the flag is set, gameplay is paused and Escape clears the flag. The game draws nothing for the popup. Draw it yourself in `on_draw_ui` when `ui_popup_is_open()` is `true`.

```lua
caffeine.on_draw_ui(function()
    if caffeine.ui_button("Menu", 10, 10, 28) then
        caffeine.ui_popup_open()
    end
    if caffeine.ui_popup_is_open() then
        local w, h = caffeine.ui_screen_size()
        caffeine.ui_rect(0, 0, w, h, 0, 0, 0, 160)
        caffeine.ui_text("Paused by a mod", 0, -30, 28, 255, 255, 255, 255, "center")
        if caffeine.ui_button("Close", -40, 20, 32, 18, "center") then
            caffeine.ui_popup_close()
        end
    end
end)
```

Read the flag with `ui_popup_is_open()`. Do not keep your own copy, because Escape clears the flag in the game.

All mods share the one flag, so only one mod popup can be open.

## Scroll regions

```lua
scroll = caffeine.ui_scroll_begin(x, y, w, h, content_h, scroll, anchor)
caffeine.ui_scroll_end()
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

caffeine.on_draw_ui(function()
    scroll = caffeine.ui_scroll_begin(10, 10, 150, 100, #rows * 24, scroll)
    for i, row in ipairs(rows) do
        caffeine.ui_text(row, 4, (i - 1) * 24, 16)
    end
    caffeine.ui_scroll_end()
end)
```

## Keyboard

| Function | Returns | Description |
|---|---|---|
| `caffeine.key_pressed(name)` | boolean | `true` on the frame the key goes down. |
| `caffeine.key_down(name)` | boolean | `true` while the key is down. |
| `caffeine.key_released(name)` | boolean | `true` on the frame the key goes up. |
| `caffeine.get_char_pressed()` | integer or nil | Next typed codepoint. `nil` when the queue is empty. |
| `caffeine.ui_capture_keyboard(on)` | nothing | While `true`, the game ignores its own keyboard actions. |

Key names: `"a"` to `"z"`, `"0"` to `"9"`, `"space"`, `"enter"`, `"return"`, `"escape"`, `"backspace"`, `"tab"`, `"delete"`, `"left"`, `"right"`, `"up"`, `"down"`, `"shift"`, `"ctrl"`, `"alt"`.

Read keys in `on_draw_ui`.

```lua
local show = true

caffeine.on_draw_ui(function()
    if caffeine.key_pressed("h") then
        show = not show
    end
    if show then
        caffeine.ui_text("press H to hide", 10, 10, 14)
    end
end)
```

### A text field

There is no text field widget. Make one with `get_char_pressed`.

```lua
local text = ""
local focused = false

caffeine.on_draw_ui(function()
    if caffeine.ui_button(focused and "Done" or "Edit", 10, 10, 26) then
        focused = not focused
        caffeine.ui_capture_keyboard(focused)
    end
    if focused then
        local cp = caffeine.get_char_pressed()
        while cp do
            text = text .. utf8.char(cp)
            cp = caffeine.get_char_pressed()
        end
        if caffeine.key_pressed("backspace") then
            text = text:sub(1, -2)
        end
    end
    caffeine.ui_text(text, 90, 14, 16)
end)
```

Call `ui_capture_keyboard(false)` when the field loses focus. If you do not, the player cannot move.

## Limits

| Thing | Limit |
|---|---|
| `on_draw_ui` listeners | 64 |
| Images in use | 64 |
| Draw calls in one frame, across all mods | 256 |
| Text length of one draw call | 191 bytes |

Mod UI has mouse and keyboard input only. It has no gamepad navigation.
