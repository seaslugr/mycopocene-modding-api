[Index](../README.md) | Previous: [Tilesets and texture packs](tilesets.md) | Next: [Status effects](statuses.md)

# Fluids

The water in the game is a simulation. Water flows, fills holes, falls as drops and makes waves. The fluid table lists each liquid the simulation can move. A mod can add fluids and change the built-in ones.

## Built-in fluids

| Key | Viscosity | Density | Notes |
|---|---|---|---|
| `water` | 0 | 1.0 | Rain and painted water are always water. |
| `oil` | 0.45 | 0.8 | Floats on water. Never dries. |
| `lava` | 0.85 | 3.0 | Sinks under the others. Burns a body in it. Never dries. |

The console command `fluid` lists the fluids. `fluid lava 6` pours 6 cells of lava over the player.

## How fluids act

- Each cell of the simulation holds one fluid. When a fluid flows into a cell, the cell becomes the fluid that is most of it.
- A heavier fluid on top of a lighter one changes place with it, one cell each tick. Oil comes up through water, and lava goes down.
- Viscosity slows the flow and the speed of the fluid. At viscosity 1 a fluid hardly moves.
- Two fluids next to each other at the same height do not mix. Each keeps its own cells.
- A body in a fluid gets the lift, drag and swim speed of that fluid, and its status effect.

Fluids do not react with each other yet. Lava and water do not make stone or steam.

## caffeine.add_fluid

```lua
local id = caffeine.add_fluid(def)
```

Adds a fluid and returns its id. The new fluid starts as a copy of water, so give only the fields that differ.

| Field | Type | Default | Description |
|---|---|---|---|
| `key` | string | required | Unique name. Use a prefix of your mod, for example `"mymod_acid"`. |
| `name` | string | the key | Display name. |
| `color` | color | water | The color under the surface. Its alpha is how opaque the fluid is there. |
| `deep_color` | color | water | The color at depth, with its own alpha. |
| `surface_color` | color | water | The lit band at the surface. |
| `viscosity` | number | `0` | From `0` (flows as water) to `1` (hardly flows). |
| `density` | number | `1` | Water is `1`. A lighter fluid floats on a heavier one. Must be above `0`. |
| `evaporation` | number | `1` | Times the drying speed of water. `0` never dries. |
| `buoyancy` | number | `1` | Times the lift of water on a swimming body. |
| `swim_speed` | number | `1` | Times the swim speed in water. |
| `status` | string | `"none"` | A status effect a body in the fluid gets. See [Status effects](statuses.md#status-names). |
| `status_magnitude` | integer | `0` | Strength of the status. |
| `status_duration` | number | `0` | Seconds of the status. The game gives it again each tick while the body is in the fluid. |
| `reflective` | boolean | `true` | The surface mirrors the scene, as rain water does. |

A color is a table `{ r, g, b, a }` with values from 0 to 255. `a` is optional and defaults to 255.

```lua
caffeine.add_fluid({
    key = "mymod_acid",
    name = "Acid",
    color = { 120, 210, 40, 170 },
    deep_color = { 40, 90, 10, 230 },
    surface_color = { 210, 255, 120, 210 },
    viscosity = 0.2,
    density = 1.2,
    evaporation = 0.5,
    status = "poison",
    status_magnitude = 2,
    status_duration = 1.0,
    reflective = false,
})
```

Drops of a fluid in the air use `color` for their body and `surface_color` for their lit top.

## caffeine.edit_fluid

```lua
caffeine.edit_fluid(fluid, patches)
```

Changes fields of a fluid. `fluid` is a key or an id. `patches` takes each field of `add_fluid` but `key`.

```lua
caffeine.edit_fluid("water", { color = { 30, 60, 90, 150 }, surface_color = { 110, 150, 200, 190 } })
```

## caffeine.get_fluid_id

```lua
local id = caffeine.get_fluid_id(key)
```

Returns the id of a fluid, or `nil`. An id is valid for one mod load only. Store a fluid by its key.

## Fluids in a world

### world:add_fluid

```lua
world:add_fluid(fluid, x, y, amount)
```

Puts fluid into the cell at pixel position `x, y`. `fluid` is a key or an id. `amount` is in cells and defaults to `1`: one cell is one full tile. A solid cell and a painted water cell take nothing. Host only.

```lua
caffeine.add_command("spring", "spring - a spring of acid over player one", function(args, world, player)
    local x, y = player:get_pos()
    for i = 1, 8 do
        world:add_fluid("mymod_acid", x, y - 48 * (i + 1), 1)
    end
end)
```

### world:get_fluid

```lua
local key, amount = world:get_fluid(x, y)
```

Returns the key of the fluid at pixel position `x, y` and its amount from `0` to `1`. Returns `nil` for a dry place.

```lua
caffeine.add_passive(function(world, player)
    local x, y = player:get_pos()
    local key = world:get_fluid(x + 12, y + 30)
    if key == "mymod_acid" and player:get_index() == 0 then
        caffeine.log("in acid")
    end
end)
```

## Room scripts

A room script can pour fluid with `add_water(col, row, amount, fluid)`. `fluid` is a key and defaults to `"water"`.

## Online

`add_fluid` and `edit_fluid` are Content functions. A host and a guest must have the same fluids, so the mod must match on both sides. See [Online play](online.md). `world:add_fluid` is host only. `world:get_fluid` works on a guest.

## Limits

| Thing | Limit |
|---|---|
| Fluids, with the built-in ones | 64 |

Painted water cells (the Water flag in Room Builder) are always water. A room cannot paint another fluid yet. Use a room script or a mod to pour one.
