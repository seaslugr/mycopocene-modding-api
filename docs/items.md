[Index](../README.md) | Previous: [Ids, keys and refs](ids.md) | Next: [Entities](entities.md)

# Items

## myco.add_item

```lua
local id = myco.add_item(def)
```

Registers an item. Returns its id. An item name must be unique in its mod. Call it while the mod loads. In a callback it raises an error. See [Content functions after the load](environment.md#content-functions-after-the-load).

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Display name. |
| `icon` | string | none | Image file in the mod folder. See [Icons](#icons). |
| `icon_index` | integer | `0` | Tile of the `icon` image. |
| `icon_tile_id` | integer | `0` | Tile index in the base game item sheet. Find it with the Picker tool. Use it only to reuse a base game icon. |
| `category` | string | `"Item"` | See [Categories](#categories). |
| `rarity` | string | `"Common"` | `"Common"`, `"Uncommon"`, `"Rare"`, `"Epic"`, `"Legendary"`, `"Mythic"`, `"Exotic"`, `"Hazardous"`. Sets the tooltip color. |
| `description` | string | `""` | Tooltip text. |
| `value` | integer | `0` | Gold value. |
| `max_stack` | integer | `0` | Stack size. `0` uses the default: 1 for equipment, 5 for consumables, 100 for the rest. |
| `usable` | boolean | `false` | The player can use it from the inventory. |
| `equipable` | boolean | `false` | It goes in an equipment slot. |
| `enchantable` | boolean | `false` | It can hold a spell. |
| `lootbox_dropable` | boolean | `false` | It can be in loot drops. |
| `disassembleable` | boolean | `false` | The player can break it down. |
| `gear_group` | string | `"none"` | `"sword"`, `"spear"`, `"dagger"`, `"bound"`, `"mace"`, `"armour"`. Selects which Modifications fit. A weapon group also sets `weapon_class`. |
| `weapon_class` | string | from `gear_group` | `"sword"`, `"mace"`, `"dagger"`, `"spear"`, `"bound"`. The moveset of a weapon. |
| `anim_frames` | integer | `0` | Frame count of an animated icon. The icon tile is the first frame, and the next tiles are the next frames. |
| `anim_speed` | number | `0` | Seconds for each icon frame. |
| `stats` | array | none | Up to 6 entries. See [Stats](#stats). |
| `modif` | table | none | See [Modifications](#modifications). |
| `shape` | array | none | See [Modifications](#modifications). |
| `shape_random_orient` | boolean | `false` | A shaped item starts with a random quarter turn at the bench. |
| `host_use` | boolean | `false` | Online, the host also runs `on_use`. Set it when `on_use` heals or damages. |
| `on_use` | function | none | See [on_use](hooks.md#on_use). |

## Icons

An icon is a 16 by 16 pixel tile. Put a PNG file in the mod folder and name it in `icon`.

```lua
myco.add_item({
    name = "Spider Web",
    icon = "sprites/web.png",
})
```

One image can hold many icons. The image is a grid of 16 pixel tiles. `icon_index` picks the tile. The count starts at `0` and goes row by row, left to right.

```
sprites/items.png, 48 by 32 pixels:

  +----+----+----+
  | 0  | 1  | 2  |
  +----+----+----+
  | 3  | 4  | 5  |
  +----+----+----+
```

```lua
myco.add_item({ name = "Spider Web", icon = "sprites/items.png", icon_index = 0 })
myco.add_item({ name = "Spider Fang", icon = "sprites/items.png", icon_index = 1 })
```

Rules:

- The width and the height of the image must be a multiple of 16, and 4096 or less.
- Use a PNG file. A compressed image format, such as a DXT `.dds` file, is an error.
- The path is relative to the mod folder and must stay in it.
- The game makes each pixel fully opaque or fully clear. An alpha below half becomes clear.
- An image that does not load, or an `icon_index` past the last tile, is an error.
- All mods together can add 3872 icon tiles and 256 icon images.

An animated icon uses tiles that follow each other in the image:

```lua
myco.add_item({
    name = "Blinker",
    icon = "sprites/items.png",
    icon_index = 4,
    anim_frames = 2,
    anim_speed = 0.4,
})
```

This item shows tile 4, then tile 5, each for 0.4 seconds.

`edit_item` accepts `icon` too, so a mod can give a base game item new art:

```lua
myco.edit_item("health_vial", { icon = "sprites/red_vial.png" })
```

Online, a host and a guest must load the same content mods in the same order. If they do not, a guest can see a wrong icon on the weapon of another player.

## Categories

`category` is text. The game shows it in the tooltip. Three values change how the item works.

| Category | Effect |
|---|---|
| `"Weapon"` | The item is a weapon. |
| `"Consumable"` | The default stack size is 5. |
| `"Modification"` | The item goes on gear at the crafting bench. |

The base game also uses `"Armour"`, `"Artifact"`, `"Equipment"`, `"Item"`, `"Material"`, `"Recipe"` and `"Tool"`. You can write a new category.

## Stats

```lua
stats = {
    { type = "attack_damage", value = 5 },
    { type = "atk_speed", value = 0.1 },
}
```

| Stat type | Effect |
|---|---|
| `attack_damage` | Added to attack damage. |
| `spell_damage` | Added to spell damage. |
| `defense` | Added to defense. |
| `max_health` | Added to maximum health. |
| `move_speed` | Added to move speed. |
| `atk_speed` | Added to the attack rate multiplier. The base is `1.0`. A total of `0` or less resets the multiplier to `1.0`. |
| `hit_count` | Added to the hit count of an attack. |

## Weapons

A weapon needs `category = "Weapon"`, `equipable = true` and a `gear_group`.

```lua
myco.add_item({
    name = "Glass Dagger",
    icon = "sprites/dagger.png",
    category = "Weapon",
    rarity = "Rare",
    equipable = true,
    gear_group = "dagger",
    stats = {
        { type = "attack_damage", value = 9 },
        { type = "atk_speed", value = 0.2 },
    },
})
```

`gear_group = "dagger"` gives the dagger moveset. Set `weapon_class` only when the moveset must differ from the gear group.

## Consumables

```lua
myco.add_item({
    name = "Big Vial",
    icon = "sprites/big_vial.png",
    category = "Consumable",
    usable = true,
    host_use = true,
    on_use = function(player, world)
        if player:get_health() >= player:get_max_health() then
            return false
        end
        player:heal(80)
    end,
})
```

Return `false` from `on_use` to keep the item. Any other return uses up one item.

## Modifications

A Modification is an item the player puts on gear at the crafting bench.

```lua
myco.add_item({
    name = "Venom Gland",
    icon = "sprites/gland.png",
    category = "Modification",
    stats = { { type = "attack_damage", value = 2 } },
    modif = {
        groups = { sword = 1.0, dagger = 1.5 },
        hook = "on_hit_dealt",
        chance = 0.25,
        status = "poison",
        magnitude = 3,
        duration = 4.0,
    },
    shape = { { 0, 0 }, { 1, 0 }, { 0, 1 } },
})
```

| `modif` field | Type | Description |
|---|---|---|
| `groups` | table | Stat scale for each gear group. A group with `0` or no entry does not fit. With no `groups` table the Modification fits all gear at full strength. |
| `hook` | string | `"on_hit_dealt"` or `"on_hit_taken"`. When it fires, it can apply `status`. |
| `chance` | number | Chance from `0.0` to `1.0` that the hook applies the status. |
| `status` | string | See the list below. |
| `magnitude` | integer | Strength of the status. |
| `duration` | number | Seconds of the status. |

Status names: `"poison"`, `"burn"`, `"ice"`, `"lightning"`, `"cure"`, `"light"`, `"magic_shield"`, `"reflect"`, `"heal"`, `"detect"`, `"invisible"`, `"jump"`, `"gravity"`, `"max_hp"`, `"defense"`, `"restore"`, `"absorb"`, `"atk_speed"`, and the key of each [mod status](statuses.md).

`shape` is the footprint of the Modification on the crafting grid. It is a list of up to 5 cells. Each cell is `{ column, row }` from the anchor cell. The first cell must be `{ 0, 0 }`.

| Shape | Cells |
|---|---|
| Single cell | no `shape` field |
| Line of 3 | `{ { 0, 0 }, { 1, 0 }, { 2, 0 } }` |
| L | `{ { 0, 0 }, { 0, 1 }, { 1, 1 } }` |
| Plus | `{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }` |

## myco.edit_item

```lua
myco.edit_item(item, patches)
```

Changes fields of an item that exists. It works on base game items and on mod items. `patches` accepts each field of `add_item`. Only the fields in `patches` change. `stats` replaces the full list. Call it while the mod loads, as `add_item`.

```lua
myco.edit_item("health_vial", { rarity = "Uncommon", value = 50 })

myco.edit_item("copper_sword", {
    stats = { { type = "attack_damage", value = 12 } },
})
```

An edit lasts until the next reload. A reload starts again from the base content and runs each edit again.
