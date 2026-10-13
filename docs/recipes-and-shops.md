[Index](../README.md) | Previous: [Entities](entities.md) | Next: [Players and worlds](players-and-worlds.md)

# Recipes and shops

## caffeine.add_recipe

```lua
local recipe_data = caffeine.add_recipe(def)
```

Registers a crafting bench recipe. Returns the recipe data value. The first mod recipe is `1000`.

| Field | Type | Default | Description |
|---|---|---|---|
| `result_item_id` | item | required | Item the recipe makes. |
| `result_qty` | integer | `1` | Quantity. |
| `name` | string | `"Mod Recipe"` | Name of the recipe. |
| `ingredients` | array | required | 1 to 64 entries. |
| `fixed_cells` | boolean | `false` | The items must sit on the exact cells, with no turn. |

| Ingredient field | Type | Default | Description |
|---|---|---|---|
| `item_id` | item | required | Ingredient. |
| `qty` | integer | `1` | Quantity in the cell. |
| `col`, `row` | integer | next cell of row 0 | Cell in the recipe layout. |

A simple recipe is a list. The game puts the ingredients side by side.

```lua
caffeine.add_recipe({
    result_item_id = "health_vial",
    ingredients = {
        { item_id = "My Mod:Spider Web", qty = 3 },
        { item_id = "plant_matter", qty = 5 },
    },
})
```

A shaped recipe gives a cell for each ingredient.

```lua
caffeine.add_recipe({
    name = "Web Blade",
    result_item_id = "My Mod:Web Blade",
    ingredients = {
        { item_id = "metal_scrap", col = 1, row = 0 },
        { item_id = "metal_scrap", col = 1, row = 1 },
        { item_id = "My Mod:Spider Web", col = 1, row = 2 },
    },
})
```

## Schematics

A player learns a recipe the first time they craft it. A Schematic item shows the layout of a recipe at the bench.

To make a Schematic for a mod recipe:

1. Keep the value `add_recipe` returned.
2. In Room Builder, place a `schematic` item in a room.
3. Set its `data` field to that value.

The data value of a mod recipe changes with the load order. The game does not save a recipe a player learned from a mod.

## Vendors

| Vendor id | Vendor |
|---|---|
| `0` | Default merchant |
| `1` | Second merchant |
| `2` | Schematic vendor |
| `3` | Salesmander |
| `4` | Camp merchant |
| `5` | Magus |

## caffeine.add_shop_entry

```lua
caffeine.add_shop_entry(def)
```

Adds an item to a vendor.

| Field | Type | Default | Description |
|---|---|---|---|
| `item_id` | item | required | Item to sell. |
| `price` | integer | `0` | Gold cost. |
| `vendor_id` | integer | `0` | Vendor. |
| `stock` | integer | `0` | Units for sale after a restock. `0` is no limit. |

```lua
caffeine.add_shop_entry({ item_id = "My Mod:Spider Web", price = 20, stock = 5 })
```

## caffeine.edit_shop_entry

```lua
caffeine.edit_shop_entry(vendor_id, item, patches)
```

Changes `price` or `stock` of an entry that exists. It does nothing when the vendor does not sell the item.

```lua
caffeine.edit_shop_entry(0, "health_vial", { price = 10 })
```

## caffeine.remove_shop_entry

```lua
local removed = caffeine.remove_shop_entry(vendor_id, item)
```

Removes an entry. Returns `true` if the entry was there.
