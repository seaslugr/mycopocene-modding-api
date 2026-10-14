[Index](../README.md) | Previous: [Items](items.md) | Next: [Enemy AI and projectiles](enemy-ai.md)

# Entities

An entity type is an enemy, or an object that uses the enemy system.

## caffeine.add_entity

```lua
local id = caffeine.add_entity(def)
```

Registers an entity type. Returns its id. The name must be unique across the base game and all mods, because room files find an entity by its name.

### Identity and sprite

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | string | required | Unique name. |
| `sheet` | string | none | Image file in the mod folder with the sprites of this entity. See [Sprites](#sprites). |
| `anims` | table | none | Animation clips in the `sheet`. See [Animations](#animations). |
| `sprite_tile_id` | integer | `0` | For an entity with no `sheet`: a tile of the tileset of the room. Find it with the Picker tool. |
| `sprite_tile_id_bottom` | integer | `0` | A second tile drawn below the first. `0` is none. |
| `use_objects_tex` | boolean | `false` | Take `sprite_tile_id` from the objects sheet and not from the tileset. |
| `draw_size` | number | `0` | Size on screen of one 16 pixel tile. `0` is the default of 48. |
| `tag` | string | `"nonstatic"` | `"static"` has no movement and no gravity. |
| `runtime_kind` | string | `"enemy"` | `"enemy"` fights. `"portal"` is the visual of a room transition. `"none"` does nothing. |

### Health and rewards

| Field | Type | Default | Description |
|---|---|---|---|
| `max_health` | integer | `10` | Health. |
| `contact_damage` | integer | `0` | Damage of a hit. |
| `xp_reward` | integer | `0` | XP for a kill. |
| `mass` | number | `0` | Knockback resistance. `0` is the default of 1. A larger number is heavier. |
| `loot` | array | none | Up to 8 entries. See [Loot](#loot). |
| `spawner_max` | integer | `0` | Maximum live count from one spawner. `0` is the game default. |

### Movement

| Field | Type | Default | Description |
|---|---|---|---|
| `move_speed` | number | `100` | Pixels per second. |
| `gravity` | number | `2400` | Pixels per second squared. |
| `can_jump` | boolean | `false` | It jumps to reach the player. |
| `can_climb` | boolean | `false` | It climbs ladders. |
| `can_swim` | boolean | `false` | It swims. |
| `can_fly` | boolean | `false` | It ignores gravity and flies to its target. |
| `patrol_style` | string | `"pace"` | `"pace"` walks near its spawn. `"stationary"` holds its position. `"wander"` roams in `patrol_radius`. |
| `patrol_radius` | number | `0` | Wander range in pixels. `0` is the default of 3 tiles. |

### Detection and chase

| Field | Type | Default | Description |
|---|---|---|---|
| `detect_box` | table | zero | `{ left, right, top, bottom }` in pixels from the entity center. |
| `player_y_tolerance` | number | `72` | Vertical range in which it engages the player. |
| `herd_alert_range` | number | `240` | Radius in which it alerts enemies of its type. |
| `chase_leash` | number | `0` | Maximum chase distance in pixels. `0` is no leash. |
| `chase_duration` | number | `0` | Seconds it chases after it loses sight. `0` is the default of 5. |
| `kite_range` | number | `0` | Distance it keeps from the player. `0` is off. |

### Attack

| Field | Type | Default | Description |
|---|---|---|---|
| `hurtbox` | table | zero | `{ x, y, w, h }` from the entity position. Where it can be hit. |
| `attack_box` | table | zero | `{ x, y, w, h }`. The hitbox of its attack. |
| `attack_range` | number | `60` | Distance at which it starts an attack. |
| `attack_windup` | number | `0` | Seconds of telegraph before the hitbox is on. |
| `attack_duration` | number | `0.26` | Seconds the hitbox is on. |
| `attack_cooldown` | number | `1.2` | Seconds between attacks. |
| `attack_speed` | number | `300` | Lunge speed in pixels per second. |
| `jump_attack_y_range` | number | `0` | Maximum height of the player for a jump attack. `0` is off. |
| `attack_super_armor` | boolean | `false` | A hit does not interrupt its attack. |
| `shoots_on_attack` | boolean | `false` | The attack fires a projectile. |
| `projectile` | string or integer | arrow | What `shoots_on_attack` fires. A key from [`add_projectile`](enemy-ai.md#caffeineadd_projectile). |

### Charge, retreat and enrage

| Field | Type | Default | Description |
|---|---|---|---|
| `can_charge` | boolean | `false` | Enables the charge attack. |
| `charge_range` | number | `0` | It charges when the player is farther than `attack_range` and nearer than this. |
| `charge_windup` | number | `0` | Seconds before the charge moves. |
| `charge_speed` | number | `0` | Pixels per second. |
| `charge_duration` | number | `0` | Seconds of the charge. |
| `charge_cooldown` | number | `0` | Seconds between charges. |
| `charge_wall_stun` | number | `0` | Seconds of stun when the charge hits a wall. |
| `charge_immune_to_kb` | boolean | `false` | No knockback during a charge. |
| `can_retreat` | boolean | `false` | It retreats at low health. |
| `retreat_health_pct` | number | `0` | Health fraction from `0.0` to `1.0` that starts a retreat. `0.3` is 30 percent. |
| `retreat_duration` | number | `0` | Seconds of a retreat. |
| `enrage_mult` | number | `0` | Speed multiplier at zero health. The speed rises as health goes down. A value above `1` enables it. |

### Callbacks

| Field | Type | Description |
|---|---|---|
| `on_death` | function | See [on_death](hooks.md#on_death). |
| `ai` | function | Replaces all of the AI. See [Enemy AI](enemy-ai.md#ai). |
| `on_attack` | function | Runs on each tick of a built-in attack. See [Enemy AI](enemy-ai.md#on_attack). |

## Loot

```lua
loot = {
    { item_id = "gold", chance = 0.8, min = 1, max = 3 },
    { item_id = spider_web, chance = 0.5 },
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `item_id` | item | required | Item to drop. |
| `chance` | number | `1.0` | Chance from `0.0` to `1.0`. |
| `min` | integer | `1` | Minimum quantity. |
| `max` | integer | `1` | Maximum quantity. |

The game rolls each entry independently.

## Sprites

Give an entity its own art with `sheet`. The sheet is a PNG file in the mod folder. It is a grid of 16 pixel tiles.

The simplest entity has a sheet with one sprite in the top left tile:

```lua
caffeine.add_entity({
    name = "glass_wasp",
    sheet = "sprites/wasp.png",
    max_health = 25,
})
```

With no `anims`, the entity draws tile `(0, 0)` as a still sprite.

Rules:

- The width and the height of the image must be a multiple of 16.
- The path is relative to the mod folder and must stay in it.
- Draw the sprite so it looks to the right. The game mirrors it when the entity looks to the left.
- One tile draws at `draw_size` pixels on screen, 48 by default. That is 3 screen pixels for each image pixel.
- Two entities can use the same file. The game loads it one time.
- An image that does not load is an error.

Without a `sheet`, an entity draws `sprite_tile_id` from the tileset of the room it is in. The look then changes with the tileset, so use a `sheet` for a real enemy.

## Animations

`anims` names the clips in the `sheet`.

```
sprites/spider.png, 64 by 48 pixels:

        x=0    x=1    x=2    x=3
      +------+------+------+------+
 y=0  | idle | idle |      |      |
      +------+------+------+------+
 y=1  | walk | walk | walk | walk |
      +------+------+------+------+
 y=2  | bite | bite | hurt | dead |
      +------+------+------+------+
```

```lua
caffeine.add_entity({
    name = "spider",
    sheet = "sprites/spider.png",
    anims = {
        idle = { x = 0, y = 0, frames = 2, speed = 0.5, loop = true },
        walk = { x = 0, y = 1, frames = 4, speed = 0.12, loop = true },
        attack = { x = 0, y = 2, frames = 2, speed = 0.1 },
        hit = { x = 2, y = 2 },
        die = { x = 3, y = 2 },
    },
})
```

The clips are `idle`, `walk`, `attack`, `hit` and `die`. A clip you do not name stays the still sprite at tile `(0, 0)`.

| Clip field | Type | Default | Description |
|---|---|---|---|
| `x`, `y` | integer | `0` | Tile of the first frame. |
| `w`, `h` | integer | `1` | Size of one frame in tiles. `w = 2, h = 2` is a 32 pixel sprite. |
| `frames` | integer | `1` | Frame count. The frames go to the right from `x`, each `w` tiles wide. |
| `speed` | number | `0` | Seconds for each frame. `0` is a still frame. |
| `loop` | boolean | `false` | The clip repeats. |

A clip that goes past the edge of the sheet is an error.

A frame of `w` by `h` tiles draws at `w * draw_size` by `h * draw_size` pixels. Set the `hurtbox` and the `attack_box` to match the art.

`edit_entity` accepts `sheet` and `anims` too, so a mod can give a base game enemy new art.

## Example

```lua
caffeine.add_entity({
    name = "glass_wasp",
    sheet = "sprites/wasp.png",
    anims = { idle = { x = 0, y = 0, frames = 2, speed = 0.1, loop = true } },
    max_health = 25,
    contact_damage = 6,
    xp_reward = 15,
    move_speed = 160,
    can_fly = true,
    patrol_style = "wander",
    patrol_radius = 200,
    kite_range = 90,
    attack_range = 70,
    attack_windup = 0.3,
    attack_cooldown = 1.8,
    hurtbox = { x = 10, y = 10, w = 28, h = 28 },
    attack_box = { x = 30, y = 12, w = 22, h = 24 },
    detect_box = { left = 220, right = 220, top = 160, bottom = 160 },
    loot = { { item_id = "gold", chance = 0.6, min = 1, max = 4 } },
})
```

## caffeine.edit_entity

```lua
caffeine.edit_entity(entity, patches)
```

Changes fields of an entity type that exists. `patches` accepts each field of `add_entity` but `name`. Only the fields in `patches` change. `loot` replaces the full list.

```lua
caffeine.edit_entity("primitive", { max_health = 20, move_speed = 140 })
```

## caffeine.spawn_entity

```lua
local ok = caffeine.spawn_entity(entity, x, y)
```

Spawns an entity at a pixel position, in the world of the callback that runs. Returns `true` if it spawned. It returns `false` outside a game session and when the room is at its enemy limit. Host only.

`world:spawn_entity(entity, x, y)` does the same on a world you name. Prefer it. See [World methods](players-and-worlds.md#world-methods).

## Place an entity in a room

Room Builder lists mod entities. A room file stores a mod entity as `mod name:entity name`, so it resolves at any load order. If the mod is off, the entity does not spawn.
