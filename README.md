# Mycopocene Modding API

Mods for Mycopocene are Lua 5.4 scripts. A mod can add items, enemies, enemy AI, projectiles, recipes, shop entries, fluids, status effects, code objects, tilesets, sounds, music, console commands and HUD elements. A mod can also edit the content of the base game and replace its art.

This repository is the reference for the mod API. The API table in Lua is named `myco`.

## Quick start

1. Make a folder in `mods/`, next to the game executable.
2. Put a `mod.toml` and a `mod.lua` file in it, and a 16 by 16 pixel `coin.png` for the icon of the item.

`mod.toml`:

```toml
name = "My First Mod"
version = "1.0.0"
author = "your_name"
description = "Adds the Lucky Coin."
```

`mod.lua`:

```lua
myco.add_item({
    name = "Lucky Coin",
    icon = "coin.png",
    category = "Artifact",
    rarity = "Rare",
    description = "It feels warm.",
    stats = { { type = "max_health", value = 10 } },
    equipable = true,
})

myco.on_room_enter(function(world, player)
    myco.log("player " .. player:get_index() + 1 .. " is in " .. world:get_room_name())
end)
```

3. Start the game. Open the console with `~` to see the load result.

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
| [Keybinds](docs/keybinds.md) | `add_keybind`: keys that the player can change in the settings |
| [Mod data](docs/data.md) | `save_data`, `load_data`, `delete_data`: JSON files that persist between sessions |
| [Achievements](docs/achievements.md) | `add_achievement`, unlocks, progress, where the state is saved |
| [Online play](docs/online.md) | Host and guest rules, content mods |
| [Rooms and Workshop](docs/rooms-and-workshop.md) | Room files, Steam Workshop |
| [Examples](examples/) | Complete mods |

## Function index

### `myco` functions

| Function | Page |
|---|---|
| `myco.add_achievement(def)` | [Achievements](docs/achievements.md#mycoadd_achievement) |
| `myco.add_command(name, usage, fn)` | [Console](docs/console.md#mycoadd_command) |
| `myco.add_entity(def)` | [Entities](docs/entities.md#mycoadd_entity) |
| `myco.add_fluid(def)` | [Fluids](docs/fluids.md#mycoadd_fluid) |
| `myco.add_item(def)` | [Items](docs/items.md#mycoadd_item) |
| `myco.add_keybind(def)` | [Keybinds](docs/keybinds.md#mycoadd_keybind) |
| `myco.add_object(def)` | [Code objects](docs/objects.md#mycoadd_object) |
| `myco.add_projectile(def)` | [Enemy AI and projectiles](docs/enemy-ai.md#mycoadd_projectile) |
| `myco.add_passive(fn)` | [Hooks](docs/hooks.md#mycoadd_passive) |
| `myco.add_recipe(def)` | [Recipes and shops](docs/recipes-and-shops.md#mycoadd_recipe) |
| `myco.add_shop_entry(def)` | [Recipes and shops](docs/recipes-and-shops.md#mycoadd_shop_entry) |
| `myco.add_status(def)` | [Status effects](docs/statuses.md#mycoadd_status) |
| `myco.clear_interval(handle)` | [Hooks](docs/hooks.md#mycoclear_interval) |
| `myco.delete_data(name)` | [Mod data](docs/data.md#mycodelete_data) |
| `myco.edit_entity(entity, patches)` | [Entities](docs/entities.md#mycoedit_entity) |
| `myco.edit_fluid(fluid, patches)` | [Fluids](docs/fluids.md#mycoedit_fluid) |
| `myco.edit_item(item, patches)` | [Items](docs/items.md#mycoedit_item) |
| `myco.edit_shop_entry(vendor_id, item, patches)` | [Recipes and shops](docs/recipes-and-shops.md#mycoedit_shop_entry) |
| `myco.edit_status(status, patches)` | [Status effects](docs/statuses.md#mycoedit_status) |
| `myco.get_achievement_progress(id)` | [Achievements](docs/achievements.md#unlock-and-progress) |
| `myco.get_char_pressed()` | [Custom UI](docs/ui.md#keyboard) |
| `myco.get_entity_id(name)` | [Ids](docs/ids.md#mycoget_entity_id) |
| `myco.get_fluid_id(key)` | [Fluids](docs/fluids.md#mycoget_fluid_id) |
| `myco.get_item_id(ref)` | [Ids](docs/ids.md#mycoget_item_id) |
| `myco.get_object_count()` | [Code objects](docs/objects.md#mycoadd_object) |
| `myco.get_projectile_id(key)` | [Enemy AI and projectiles](docs/enemy-ai.md#mycoadd_projectile) |
| `myco.get_status_id(key)` | [Status effects](docs/statuses.md#mycoget_status_id) |
| `myco.get_volume(kind)` | [Sound and music](docs/audio.md#mycoget_volume) |
| `myco.has_achievement(id)` | [Achievements](docs/achievements.md#unlock-and-progress) |
| `myco.key_down(name)` | [Custom UI](docs/ui.md#keyboard) |
| `myco.key_pressed(name)` | [Custom UI](docs/ui.md#keyboard) |
| `myco.key_released(name)` | [Custom UI](docs/ui.md#keyboard) |
| `myco.load_data(name)` | [Mod data](docs/data.md#mycoload_data) |
| `myco.load_music(file)` | [Sound and music](docs/audio.md#mycoload_music) |
| `myco.load_sound(file, voices)` | [Sound and music](docs/audio.md#mycoload_sound) |
| `myco.log(msg)` | [Console](docs/console.md#mycolog) |
| `myco.music_playing()` | [Sound and music](docs/audio.md#mycomusic_playing) |
| `myco.on_craft(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_draw_ui(fn)` | [Custom UI](docs/ui.md#mycoon_draw_ui) |
| `myco.on_enemy_killed(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_level_up(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_music(fn)` | [Sound and music](docs/audio.md#mycoon_music) |
| `myco.on_player_damaged(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_player_death(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_room_enter(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_run_end(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_run_start(fn)` | [Hooks](docs/hooks.md#hook-list) |
| `myco.on_sfx(fn)` | [Sound and music](docs/audio.md#mycoon_sfx) |
| `myco.play_music(handle, loop, volume, fade)` | [Sound and music](docs/audio.md#mycoplay_music) |
| `myco.play_sfx(name, pitch)` | [Sound and music](docs/audio.md#mycoplay_sfx) |
| `myco.play_sound(handle, volume, pitch, pan)` | [Sound and music](docs/audio.md#mycoplay_sound) |
| `myco.play_sound_at(handle, x, y, listener, ...)` | [Sound and music](docs/audio.md#mycoplay_sound_at) |
| `myco.remove_hook(handle)` | [Hooks](docs/hooks.md#mycoremove_hook) |
| `myco.remove_passive(handle)` | [Hooks](docs/hooks.md#mycoremove_passive) |
| `myco.remove_shop_entry(vendor_id, item)` | [Recipes and shops](docs/recipes-and-shops.md#mycoremove_shop_entry) |
| `myco.replace_asset(asset, file)` | [Tilesets and texture packs](docs/tilesets.md#mycoreplace_asset) |
| `myco.save_data(name, value)` | [Mod data](docs/data.md#mycosave_data) |
| `myco.set_interval(fn, seconds)` | [Hooks](docs/hooks.md#mycoset_interval) |
| `myco.sound_playing(handle)` | [Sound and music](docs/audio.md#mycosound_playing) |
| `myco.spawn_entity(entity, x, y)` | [Entities](docs/entities.md#mycospawn_entity) |
| `myco.stop_music(fade)` | [Sound and music](docs/audio.md#mycostop_music) |
| `myco.stop_sound(handle)` | [Sound and music](docs/audio.md#mycostop_sound) |
| `myco.ui_button(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_capture_keyboard(on)` | [Custom UI](docs/ui.md#keyboard) |
| `myco.ui_checkbox(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_image(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_popup_close()` | [Custom UI](docs/ui.md#popups) |
| `myco.ui_popup_is_open()` | [Custom UI](docs/ui.md#popups) |
| `myco.ui_popup_open()` | [Custom UI](docs/ui.md#popups) |
| `myco.ui_rect(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_screen_size()` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_scroll_begin(...)` | [Custom UI](docs/ui.md#scroll-regions) |
| `myco.ui_scroll_end()` | [Custom UI](docs/ui.md#scroll-regions) |
| `myco.ui_slider(...)` | [Custom UI](docs/ui.md#draw-functions) |
| `myco.ui_text(...)` | [Custom UI](docs/ui.md#draw-functions) |

### Objects

| Object | Methods | Page |
|---|---|---|
| Player | `get_index`, `get_room_index`, `get_pos`, `get_health`, `get_max_health`, `get_level`, `get_xp`, `get_attack_damage`, `get_defense`, `get_move_speed`, `get_atk_speed`, `get_stat`, `get_status`, `count_item`, `give_item`, `remove_item`, `add_xp`, `unlock_achievement`, `add_achievement_progress`, `heal`, `damage`, `damage_raw`, `teleport`, `apply_status`, `clear_status` | [Player methods](docs/players-and-worlds.md#player-methods) |
| World | `get_room_name`, `get_room_id`, `get_player_count`, `get_player`, `get_player_pos`, `get_player_health`, `get_player_level`, `get_gold`, `get_enemy_count`, `get_nearest_enemy_pos`, `get_chest_count`, `get_expedition_time`, `get_expedition_active`, `get_fluid`, `damage_player`, `teleport_player`, `teleport_player_to_room`, `spawn_item`, `spawn_entity`, `spawn_projectile`, `add_fluid` | [World methods](docs/players-and-worlds.md#world-methods) |
| Object | `get_key`, `get_pos`, `get_tile`, `get_values`, `get_rotation`, `get_area`, `get_frame`, `set_frame`, `set_visible`, `get_data` | [The object handle](docs/objects.md#the-object-handle) |
| Enemy | `exists`, `get_entity`, `get_pos`, `get_vel`, `get_size`, `get_health`, `get_max_health`, `get_state`, `get_facing`, `on_ground`, `get_target`, `can_attack`, `get_attack_time`, `get_data`, `move`, `walk_to`, `wander`, `jump`, `set_vel`, `face`, `attack`, `shoot`, `damage`, `heal`, `knockback`, `alert` | [The enemy handle](docs/enemy-ai.md#the-enemy-handle) |

### Globals

| Global | Page |
|---|---|
| `MOD_DIR`, `MOD_NAME`, `MOD_VERSION` | [Getting started](docs/getting-started.md#globals-from-modtoml) |
| `dofile`, `load`, `loadfile`, standard libraries | [Environment](docs/environment.md#globals) |
