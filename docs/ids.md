[Index](../README.md) | Previous: [Environment](environment.md) | Next: [Items](items.md)

# Ids, keys and refs

Each item and each entity has a number id. The numbers change between game versions and between load orders. Do not write an id number in a mod.

## Items

Each API function that takes an item accepts one of these forms.

| Form | Example | Notes |
|---|---|---|
| Key | `"health_vial"` | Base game items. The console command `list items` prints the keys. |
| Mod ref | `"My Mod:Spider Web"` | Items of a mod. The form is `mod name:item name`. |
| Display name | `"Health Vial"` | Works, but a key is safer. Two items can have the same display name. |
| Number | `web` | A variable that holds the number `add_item` or `get_item_id` returned in this session. |

In a mod ref, a space and an underscore are the same. `"My Mod:Spider Web"` and `"My_Mod:Spider_Web"` name the same item. Saves and room files use the underscore form.

An unknown item text raises an error.

```lua
local web = myco.add_item({ name = "Spider Web", icon_tile_id = 210 })

myco.add_shop_entry({ item_id = web, price = 20 })
myco.add_shop_entry({ item_id = "health_vial", price = 35 })
myco.add_shop_entry({ item_id = "Other Mod:Iron Splinter", price = 6 })
```

To use an item of a different mod, that mod must load before yours. Put it in `requires` or `load_after` in your [mod.toml](getting-started.md#dependencies).

## Entities

Each API function that takes an entity accepts the entity name or the number `add_entity` returned.

```lua
myco.edit_entity("primitive", { max_health = 20 })
world:spawn_entity("primitive", x, y)
```

Entity names are unique across the base game and all mods. The console command `list enemies` prints them.

## Speed

A text lookup searches the item table. That is fine at load. In a callback that runs each frame, get the id one time and keep it.

```lua
local vial = myco.get_item_id("health_vial")

myco.add_passive(function(world, player)
    if player:count_item(vial) == 0 then
        player:give_item(vial, 1)
    end
end)
```

## myco.get_item_id

```lua
myco.get_item_id(ref)
```

Returns the id of an item, or `nil` when no item matches. `ref` is a key, a mod ref or a display name. Use it to test if an item exists.

## myco.get_entity_id

```lua
myco.get_entity_id(name)
```

Returns the id of an entity, or `nil` when no entity has that name.
