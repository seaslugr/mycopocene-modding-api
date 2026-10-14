# Mycopocene Modding API

Mods for Mycopocene are Lua 5.4 scripts. A mod can add items, enemies, enemy AI, projectiles, recipes, shop entries, fluids, status effects, code objects, tilesets, sounds, music, console commands and HUD elements. A mod can also edit the content of the base game and replace its art.

This repository is the reference for the mod API. The API table in Lua is named `caffeine`.

## Quick start

1. Make a folder in `mods/`, next to the game executable.
2. Put a `mod.toml` and a `mod.lua` file in it, and a 16 by 16 pixel `coin.png` for the icon.
3. Start the game. Open the console with `~` to see the load result.

`mod.toml`:

```toml
name = "My First Mod"
version = "1.0.0"
author = "your_name"
description = "Adds the Lucky Coin."
```

`mod.lua`:

```lua
caffeine.add_item({
    name = "Lucky Coin",
    icon = "coin.png",
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
| [Getting started](docs/getting-started.md) | Mod folder, `mod.toml`, dependencies, `mod.lua`, tools, debugging |
| [Environment](docs/environment.md) | Globals, sandbox, file paths, time and memory limits, errors, load order, limits |
| [Ids, keys and refs](docs/ids.md) | How to name an item or an entity |
| [Items](docs/items.md) | `add_item`, `edit_item`, custom icons, stats, weapons, Modifications |
| [Entities](docs/entities.md) | `add_entity`, `edit_entity`, custom sprite sheets, animations, loot, spawn |
| [Enemy AI and projectiles](docs/enemy-ai.md) | `add_projectile`, `ai`, `on_attack`, the enemy handle |
| [Recipes and shops](docs/recipes-and-shops.md) | `add_recipe`, Schematics, shop entries |
| [Tilesets and texture packs](docs/tilesets.md) | Tilesets for mod rooms, `replace_asset` for the art and sound of the game |
| [Fluids](docs/fluids.md) | The fluid table, `add_fluid`, viscosity, density, colors, fluids in a world |
| [Status effects](docs/statuses.md) | `add_status`, `edit_status`, status callbacks, `apply_status` |
| [Code objects](docs/objects.md) | `add_object`, placing mod objects in a room, object callbacks |
| [Players and worlds](docs/players-and-worlds.md) | The Player and World objects, the two player numbers |
| [Hooks and callbacks](docs/hooks.md) | Events, passives, intervals, `on_use`, `on_death` |
| [Console](docs/console.md) | `add_command`, `log` |
| [Sound and music](docs/audio.md) | Mod sounds and music, hooks on the sounds and tracks of the game |
| [Custom UI](docs/ui.md) | Images, text, buttons, sliders, popups, keyboard |
| [Mod data](docs/data.md) | `save_data`, `load_data`, `delete_data`: JSON files that persist between sessions |
| [Online play](docs/online.md) | Host and guest rules, content mods |
| [Rooms and Workshop](docs/rooms-and-workshop.md) | Room files, Steam Workshop |
| [Examples](examples/) | Complete mods |

## Function index

### `caffeine` functions

| Function | Page |
|---|---|
| `caffeine.add_command(name, usage, fn)` | [Console](docs/console.md#caffeineadd_command) |
| `caffeine.add_entity(def)` | [Entities](docs/entities.md#caffeineadd_entity) |
| `caffeine.add_fluid(def)` | [Fluids](docs/fluids.md#caffeineadd_fluid) |
| `caffeine.add_item(def)` | [Items](docs/items.md#caffeineadd_item) |
| `caffeine.add_object(def)` | [Code objects](docs/objects.md#caffeineadd_object) |
| `caffeine.add_projectile(def)` | [Enemy AI and projectiles](docs/enemy-ai.md#caffeineadd_projectile) |
| `caffeine.add_passive(fn)` | [Hooks](docs/hooks.md#caffeineadd_passive) |
| `caffeine.add_recipe(def)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineadd_recipe) |
| `caffeine.add_shop_entry(def)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineadd_shop_entry) |
| `caffeine.add_status(def)` | [Status effects](docs/statuses.md#caffeineadd_status) |
| `caffeine.clear_interval(handle)` | [Hooks](docs/hooks.md#caffeineclear_interval) |
| `caffeine.delete_data(name)` | [Mod data](docs/data.md#caffeinedelete_data) |
| `caffeine.edit_entity(entity, patches)` | [Entities](docs/entities.md#caffeineedit_entity) |
| `caffeine.edit_fluid(fluid, patches)` | [Fluids](docs/fluids.md#caffeineedit_fluid) |
| `caffeine.edit_item(item, patches)` | [Items](docs/items.md#caffeineedit_item) |
| `caffeine.edit_shop_entry(vendor_id, item, patches)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineedit_shop_entry) |
| `caffeine.edit_status(status, patches)` | [Status effects](docs/statuses.md#caffeineedit_status) |
| `caffeine.get_char_pressed()` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.get_entity_id(name)` | [Ids](docs/ids.md#caffeineget_entity_id) |
| `caffeine.get_fluid_id(key)` | [Fluids](docs/fluids.md#caffeineget_fluid_id) |
| `caffeine.get_item_id(ref)` | [Ids](docs/ids.md#caffeineget_item_id) |
| `caffeine.get_object_count()` | [Code objects](docs/objects.md#caffeineadd_object) |
| `caffeine.get_projectile_id(key)` | [Enemy AI and projectiles](docs/enemy-ai.md#caffeineadd_projectile) |
| `caffeine.get_status_id(key)` | [Status effects](docs/statuses.md#caffeineget_status_id) |
| `caffeine.get_volume(kind)` | [Sound and music](docs/audio.md#caffeineget_volume) |
| `caffeine.key_down(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.key_pressed(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.key_released(name)` | [Custom UI](docs/ui.md#keyboard) |
| `caffeine.load_data(name)` | [Mod data](docs/data.md#caffeineload_data) |
| `caffeine.load_music(file)` | [Sound and music](docs/audio.md#caffeineload_music) |
| `caffeine.load_sound(file, voices)` | [Sound and music](docs/audio.md#caffeineload_sound) |
| `caffeine.log(msg)` | [Console](docs/console.md#caffeinelog) |
| `caffeine.music_playing()` | [Sound and music](docs/audio.md#caffeinemusic_playing) |
| `caffeine.on_craft(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_draw_ui(fn)` | [Custom UI](docs/ui.md#caffeineon_draw_ui) |
| `caffeine.on_enemy_killed(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_level_up(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_music(fn)` | [Sound and music](docs/audio.md#caffeineon_music) |
| `caffeine.on_player_damaged(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_player_death(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_room_enter(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_run_end(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_run_start(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `caffeine.on_sfx(fn)` | [Sound and music](docs/audio.md#caffeineon_sfx) |
| `caffeine.play_music(handle, loop, volume, fade)` | [Sound and music](docs/audio.md#caffeineplay_music) |
| `caffeine.play_sfx(name, pitch)` | [Sound and music](docs/audio.md#caffeineplay_sfx) |
| `caffeine.play_sound(handle, volume, pitch, pan)` | [Sound and music](docs/audio.md#caffeineplay_sound) |
| `caffeine.play_sound_at(handle, x, y, listener, ...)` | [Sound and music](docs/audio.md#caffeineplay_sound_at) |
| `caffeine.remove_hook(handle)` | [Hooks](docs/hooks.md#caffeineremove_hook) |
| `caffeine.remove_passive(handle)` | [Hooks](docs/hooks.md#caffeineremove_passive) |
| `caffeine.remove_shop_entry(vendor_id, item)` | [Recipes and shops](docs/recipes-and-shops.md#caffeineremove_shop_entry) |
| `caffeine.replace_asset(asset, file)` | [Tilesets and texture packs](docs/tilesets.md#caffeinereplace_asset) |
| `caffeine.save_data(name, value)` | [Mod data](docs/data.md#caffeinesave_data) |
| `caffeine.set_interval(fn, seconds)` | [Hooks](docs/hooks.md#caffeineset_interval) |
| `caffeine.sound_playing(handle)` | [Sound and music](docs/audio.md#caffeinesound_playing) |
| `caffeine.spawn_entity(entity, x, y)` | [Entities](docs/entities.md#caffeinespawn_entity) |
| `caffeine.stop_music(fade)` | [Sound and music](docs/audio.md#caffeinestop_music) |
| `caffeine.stop_sound(handle)` | [Sound and music](docs/audio.md#caffeinestop_sound) |
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
| Player | `get_index`, `get_room_index`, `get_pos`, `get_health`, `get_max_health`, `get_level`, `get_xp`, `get_attack_damage`, `get_defense`, `get_move_speed`, `get_atk_speed`, `get_stat`, `get_status`, `count_item`, `give_item`, `remove_item`, `add_xp`, `heal`, `damage`, `damage_raw`, `teleport`, `apply_status`, `clear_status` | [Player methods](docs/players-and-worlds.md#player-methods) |
| World | `get_room_name`, `get_room_id`, `get_player_count`, `get_player`, `get_player_pos`, `get_player_health`, `get_player_level`, `get_gold`, `get_enemy_count`, `get_nearest_enemy_pos`, `get_chest_count`, `get_expedition_time`, `get_expedition_active`, `get_fluid`, `damage_player`, `teleport_player`, `teleport_player_to_room`, `spawn_item`, `spawn_entity`, `spawn_projectile`, `add_fluid` | [World methods](docs/players-and-worlds.md#world-methods) |
| Object | `get_key`, `get_pos`, `get_tile`, `get_values`, `get_rotation`, `get_area`, `get_frame`, `set_frame`, `set_visible`, `get_data` | [The object handle](docs/objects.md#the-object-handle) |
| Enemy | `exists`, `get_entity`, `get_pos`, `get_vel`, `get_size`, `get_health`, `get_max_health`, `get_state`, `get_facing`, `on_ground`, `get_target`, `can_attack`, `get_attack_time`, `get_data`, `move`, `walk_to`, `wander`, `jump`, `set_vel`, `face`, `attack`, `shoot`, `damage`, `heal`, `knockback`, `alert` | [The enemy handle](docs/enemy-ai.md#the-enemy-handle) |

### Globals

| Global | Page |
|---|---|
| `MOD_DIR`, `MOD_NAME`, `MOD_VERSION` | [Getting started](docs/getting-started.md#globals-from-modtoml) |
| `dofile`, `load`, `loadfile`, standard libraries | [Environment](docs/environment.md#globals) |
