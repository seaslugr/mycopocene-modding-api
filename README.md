# Mycopocene Modding API

Mods for Mycopocene are Lua 5.4 scripts. A mod can add items, enemies, recipes, shop entries, console commands and HUD elements. A mod can also edit the content of the base game.

This repository is the reference for the mod API. The API table in Lua is named `caffeine`.

## Quick start

1. Make a folder in `mods/`, next to the game executable.
2. Put a `mod.lua` file in it.
3. Start the game. Open the console with `~` to see the load result.

```lua
name = "My First Mod"
version = "1.0.0"
author = "your_name"

caffeine.add_item({
    name = "Lucky Coin",
    icon_tile_id = 12,
    category = "Artifact",
    rarity = "Rare",
    description = "It feels warm.",
    stats = { { type = "max_health", value = 10 } },
    equipable = true,
})

caffeine.on_room_enter(function(world, player)
    caffeine.log("player " .. player:get_index() + 1 .. " is in " .. world:get_room_name())
end)
```

## Pages

| Page | Contents |
|---|---|
| [Getting started](docs/getting-started.md) | Mod folder, `mod.lua`, tools, debugging |
| [Environment](docs/environment.md) | Globals, sandbox, errors, load order, limits |
| [Ids, keys and refs](docs/ids.md) | How to name an item or an entity |
| [Items](docs/items.md) | `add_item`, `edit_item`, stats, weapons, Modifications |
| [Entities](docs/entities.md) | `add_entity`, `edit_entity`, loot, animations, spawn |
| [Recipes and shops](docs/recipes-and-shops.md) | `add_recipe`, Schematics, shop entries |
| [Players and worlds](docs/players-and-worlds.md) | The Player and World objects, the two player numbers |
| [Hooks and callbacks](docs/hooks.md) | Events, passives, intervals, `on_use`, `on_death` |
| [Console](docs/console.md) | `add_command`, `log` |
| [Custom UI](docs/ui.md) | Images, text, buttons, sliders, popups, keyboard |
| [Online play](docs/online.md) | Host and guest rules, content mods |
| [Rooms and Workshop](docs/rooms-and-workshop.md) | Room files, Steam Workshop |
| [Examples](examples/) | Complete mods |

## Function index

### `caffeine` functions

| Function | Page |
|---|---|
| `caffeine.add_command(name, usage, fn)` | [Console](docs/console.md#caffeineadd_command) |
| `caffeine.add_entity(def)` | [Entities](docs/entities.md#caffeineadd_entity) |
| `caffeine.add_item(def)` | [Items](docs/items.md#caffeineadd_item) |
| `caffeine.add_passive(fn)` | [Hooks](docs/hooks.md#caffeineadd_passive) |
| `caffeine.add_recipe(def)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineadd_recipe) |
| `caffeine.add_shop_entry(def)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineadd_shop_entry) |
| `caffeine.clear_interval(handle)` | [Hooks](docs/hooks.md#caffeineclear_interval) |
| `caffeine.edit_entity(entity, patches)` | [Entities](docs/entities.md#caffeineedit_entity) |
| `caffeine.edit_item(item, patches)` | [Items](docs/items.md#caffeineedit_item) |
| `caffeine.edit_shop_entry(vendor_id, item, patches)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineedit_shop_entry) |
| `caffeine.get_char_pressed()` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.get_entity_id(name)` | [Ids](docs/ids.md#caffeineget_entity_id) |
| `caffeine.get_item_id(ref)` | [Ids](docs/ids.md#caffeineget_item_id) |
| `caffeine.key_down(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.key_pressed(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.key_released(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.log(msg)` | [Console](docs/console.md#caffeinelog) |
| `caffeine.on_craft(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_draw_ui(fn)` | [Custom UI](docs/ui.md#caffeineon_draw_ui) |
| `caffeine.on_enemy_killed(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_level_up(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_player_damaged(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_player_death(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_room_enter(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_run_end(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_run_start(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.remove_passive(handle)` | [Hooks](docs/hooks.md#caffeineremove_passive) |
| `caffeine.remove_shop_entry(vendor_id, item)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineremove_shop_entry) |
| `caffeine.set_interval(fn, seconds)` | [Hooks](docs/hooks.md#caffeineset_interval) |
| `caffeine.spawn_entity(entity, x, y)` | [Entities](docs/entities.md#caffeinespawn_entity) |
| `caffeine.ui_button(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_capture_keyboard(on)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.ui_checkbox(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_image(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_popup_close()` | [Custom UI](docs/ui.md#popups) |
| `caffeine.ui_popup_is_open()` | [Custom UI](docs/ui.md#popups) |
| `caffeine.ui_popup_open()` | [Custom UI](docs/ui.md#popups) |
| `caffeine.ui_rect(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_screen_size()` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_scroll_begin(...)` | [Custom UI](docs/ui.md#scroll-regions) |
| `caffeine.ui_scroll_end()` | [Custom UI](docs/ui.md#scroll-regions) |
| `caffeine.ui_slider(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `caffeine.ui_text(...)` | [Custom UI](docs/ui.md#draw-functions) |

### Objects

| Object | Methods | Page |
|---|---|---|
| Player | `get_index`, `get_room_index`, `get_pos`, `get_health`, `get_max_health`, `get_level`, `get_xp`, `get_attack_damage`, `get_defense`, `get_move_speed`, `get_atk_speed`, `get_stat`, `count_item`, `give_item`, `remove_item`, `add_xp`, `heal`, `damage`, `damage_raw`, `teleport` | [Player methods](docs/players-and-worlds.md#player-methods) |
| World | `get_room_name`, `get_room_id`, `get_player_count`, `get_player`, `get_player_pos`, `get_player_health`, `get_player_level`, `get_gold`, `get_enemy_count`, `get_nearest_enemy_pos`, `get_chest_count`, `get_expedition_time`, `get_expedition_active`, `damage_player`, `teleport_player`, `teleport_player_to_room`, `spawn_item`, `spawn_entity` | [World methods](docs/players-and-worlds.md#world-methods) |

### Globals

| Global | Page |
|---|---|
| `MOD_DIR`, `name`, `version`, `author` | [Getting started](docs/getting-started.md#modlua) |
| `dofile`, `load`, `loadfile`, standard libraries | [Environment](docs/environment.md#globals) |
