[Index](../README.md) | Previous: [Entities](entities.md) | Next: [Recipes and shops](recipes-and-shops.md)

# Enemy AI and projectiles

A mod entity can have its own AI, its own attacks and its own projectiles.

- [`myco.add_projectile`](#mycoadd_projectile) adds a projectile.
- `shoots_on_attack = true` with `projectile = "key"` makes the built-in AI fire a mod projectile.
- [`on_attack`](#on_attack) keeps the built-in AI and replaces its attack.
- [`ai`](#ai) replaces all of the AI.

## myco.add_projectile

```lua
local id = myco.add_projectile(def)
```

Registers a projectile. Returns its id. Call it at load time, as `add_item`.

| Field | Type | Default | Description |
|---|---|---|---|
| `key` | string | required | Unique name. No spaces or quotes. Under 64 characters. |
| `icon` | string | none | Image file in the mod folder. A grid of 16 by 16 pixel tiles. With no icon, the projectile is a colored dot. |
| `icon_index` | integer | `0` | Tile of `icon`, counted row by row from `0`. |
| `rotate` | boolean | `false` | Turns the sprite to the direction of travel. Draw the sprite so it points right. |
| `speed` | number | `400` | Pixels per second. `0` to `5000`. |
| `size` | number | `6` | Hit radius in pixels. The sprite draws at 3.5 times this. `1` to `64`. |
| `lifetime` | number | `1.5` | Seconds before it goes away. `0.05` to `30`. |
| `gravity` | number | `0` | Downward pull in pixels per second per second. Negative pulls up. |
| `homing` | number | `0` | Turn rate toward the nearest target, in radians per second. `0` to `20`. |
| `pierce` | integer | `0` | Number of targets it goes through. `0` to `99`. |
| `bounces` | integer | `0` | Number of wall bounces. `0` to `99`. |
| `damage` | number | `1` | Multiplier of the base damage. `0` to `100`. |
| `knockback` | number | `180` | Push on a hit, in pixels per second. |
| `status` | string | none | Status to apply on a hit. A base game key such as `"burn"`, or a key from [`add_status`](statuses.md#mycoadd_status). |
| `status_seconds` | number | `3` | Duration of the status. |
| `status_power` | number | `1` | Magnitude of the status. |
| `tint` | table | white | `{ r, g, b, a }`, each `0` to `255`. `a` is optional. Colors the sprite and the trail. |
| `trail` | boolean | `true` | `false` removes the trail. |

```lua
myco.add_projectile({
    key = "spore_bolt",
    icon = "bolt.png",
    rotate = true,
    speed = 320,
    damage = 0.8,
    status = "poison",
    status_seconds = 2,
    tint = { 170, 255, 140 },
})
```

The id goes over the network. The host and each guest must have the same projectiles. A mod that adds a projectile is a content mod. See [Online play](online.md).

`myco.get_projectile_id(key)` returns the id of a projectile, or `nil`.

The damage of a hit is `(base damage + status_power) * damage`. For an enemy, the base damage is its `contact_damage`. `status_power` adds only when the projectile has a `status`.

### world:spawn_projectile

```lua
local ok = world:spawn_projectile(projectile, x, y, vx, vy, damage, friendly)
```

Spawns a projectile at a pixel position with a velocity. Returns `true` if it spawned. Host only.

| Argument | Default | Description |
|---|---|---|
| `projectile` | required | The key, or the id. |
| `x, y` | required | Position in room pixels. See [Positions](players-and-worlds.md#positions). |
| `vx, vy` | required | Velocity in pixels per second. |
| `damage` | `10` | Base damage. |
| `friendly` | `false` | `true` hurts enemies. `false` hurts players. |

## Entity fields

These fields go in [`add_entity`](entities.md#mycoadd_entity) and [`edit_entity`](entities.md#mycoedit_entity).

| Field | Type | Description |
|---|---|---|
| `projectile` | string or integer | What `shoots_on_attack` fires. The default is the arrow of the base game. |
| `ai` | function | Replaces all of the AI. See [ai](#ai). |
| `on_attack` | function | Runs on each tick of a built-in attack. See [on_attack](#on_attack). |

`edit_entity` also works on a base game enemy. This one makes the Primitive shoot spore bolts:

```lua
myco.edit_entity("primitive", { projectile = "spore_bolt", shoots_on_attack = true })
```

### ai

```lua
ai = function(enemy, world, dt) end
```

Runs one time each tick for each enemy of the type. The built-in AI does not run. `enemy` is the [enemy handle](#the-enemy-handle). `dt` is the tick length in seconds.

The game still does these things for you:

- Physics: gravity, walls, floors, water, `can_fly` and `can_swim`.
- Animation from the state. A moving enemy plays `walk`. A still enemy plays `idle`. `enemy:attack()` plays `attack`. A hit plays `hit`.
- Damage from the player, knockback, status effects and death.
- Contact damage while the hitbox of `enemy:attack()` is on.
- The end of the `spawn`, `attack` and `knockback` states. Each one goes back to `patrol`.

```lua
myco.add_entity({
    name = "Spore Brute",
    max_health = 40,
    contact_damage = 6,
    attack_box = { x = 8, y = 8, w = 40, h = 32 },
    attack_windup = 0.4,
    attack_duration = 0.2,
    attack_cooldown = 1.5,
    ai = function(enemy, world, dt)
        local data = enemy:get_data()
        data.shot = (data.shot or 0) + dt

        local tx, ty = enemy:get_target()
        if not tx then
            enemy:wander()
            return
        end
        local x, y = enemy:get_pos()
        local gap = math.abs(tx - x)
        if enemy:get_state() == "attack" then
            enemy:move(0)
        elseif gap < 50 and enemy:can_attack() then
            enemy:attack()
        elseif gap < 320 and data.shot > 2 then
            data.shot = 0
            enemy:shoot("spore_bolt")
        else
            enemy:walk_to(tx)
        end
    end,
})
```

The AI runs on the host only. A guest gets the position and the state of the enemy from the host. The Authority methods of the handle always work in `ai`, because `ai` never runs on a guest.

### on_attack

```lua
on_attack = function(enemy, world, dt, started) end
```

The built-in AI decides when to attack, with `attack_range` and `attack_cooldown`. `on_attack` then runs on each tick of the attack, in place of the built-in lunge. `started` is `true` on the first tick of each attack.

Before each call, the enemy stands still and faces its target. Move it with `enemy:move` or `enemy:set_vel`. The hitbox of the attack is on after `attack_windup`, for `attack_duration`.

```lua
myco.add_entity({
    name = "Spore Spitter",
    attack_range = 220,
    attack_windup = 0.3,
    on_attack = function(enemy, world, dt, started)
        if started then
            for i = -1, 1 do
                enemy:shoot("spore_bolt", enemy:get_facing(), i * 0.3)
            end
        end
    end,
})
```

`on_attack` does not run for an entity with `can_fly`. Use `ai` for a flyer.

## The enemy handle

`ai` and `on_attack` get a handle. The Tier column says where a method works. See [Online play](online.md). A handle stays valid while the enemy lives in the same room. After the enemy dies or walks into another room, each method raises an error, except `exists`.

| Method | Returns | Tier | Description |
|---|---|---|---|
| `enemy:exists()` | boolean | View | `true` while the handle is valid. |
| `enemy:get_entity()` | integer | View | Entity id. |
| `enemy:get_pos()` | number, number | View | Middle of the enemy, in pixels of the room. |
| `enemy:get_vel()` | number, number | View | Velocity in pixels per second. |
| `enemy:get_size()` | number | View | Draw size in pixels. |
| `enemy:get_health()` | integer | View | Current health. |
| `enemy:get_max_health()` | integer | View | Max health, with status effects. |
| `enemy:get_state()` | string | View | One of `"spawn"`, `"patrol"`, `"alert"`, `"chase"`, `"investigate"`, `"attack"`, `"jump_attack"`, `"charge_windup"`, `"charge"`, `"retreat"`, `"knockback"`. |
| `enemy:get_facing()` | integer | View | `-1` left, `1` right. |
| `enemy:on_ground()` | boolean | View | `true` on a floor. |
| `enemy:get_target()` | number, number, Player | View | Middle of the nearest living player in the room, and the player. `nil` when there is none. |
| `enemy:can_attack()` | boolean | View | `true` when `attack()` would start an attack. |
| `enemy:get_attack_time()` | number | View | Seconds since the attack started. `nil` out of an attack. |
| `enemy:get_data()` | table | View | A table for the state of your AI. See [Data](#data). |
| `enemy:move(vx)` | nothing | Authority | Walks at `vx` pixels per second until the next `move`. Negative is left. `0` stops. Sets the facing. |
| `enemy:walk_to(x, speed)` | boolean | Authority | Walks toward `x`. Slows down near it. Hops walls and gaps when `can_jump` is on. `true` at `x`. `speed` defaults to `move_speed`. |
| `enemy:wander(speed)` | nothing | Authority | Walks, turns at walls and edges, and turns at random. |
| `enemy:jump(power)` | boolean | Authority | Jumps when on a floor. `power` defaults to `760`. `true` if it jumped. |
| `enemy:set_vel(vx, vy)` | nothing | Authority | Sets the velocity now. Gravity and walls still apply. |
| `enemy:face(dir)` | nothing | Authority | `dir` below `0` faces left. Above `0` faces right. |
| `enemy:attack()` | boolean | Authority | Starts a melee attack with `attack_windup`, `attack_duration` and `attack_cooldown`. `false` during the cooldown, an attack or a knockback. |
| `enemy:shoot(projectile, dx, dy)` | boolean | Authority | Fires from the middle of the enemy in the direction `dx, dy`, at the speed of the projectile. `dx, dy` is a direction: `1, 0` is right and `0, -1` is up. Its length does not matter. To aim at a point, subtract the position of the enemy from it. With no direction, it aims at the nearest player. |
| `enemy:damage(amount)` | boolean | Authority | Hurts the enemy. Its defense applies. `true` if the hit landed. |
| `enemy:heal(amount)` | nothing | Authority | Adds health, up to the max. |
| `enemy:knockback(vx, vy)` | boolean | Authority | Pushes the enemy as a hit does. `mass` and super armor apply. |
| `enemy:alert()` | nothing | Authority | Makes the built-in AI chase for 3 seconds. |

Speeds are limited to 5000 pixels per second.

### Data

`enemy:get_data()` returns the same table on each call for the same enemy. Keep timers and phases in it.

```lua
ai = function(enemy, world, dt)
    local data = enemy:get_data()
    data.phase = data.phase or "walk"
end
```

The table goes away about 10 seconds after the enemy dies or leaves the room. The table stays on the host and does not go to the guests. Up to 1024 enemies can have a table at the same time.

## Errors

An error in `ai` or `on_attack` goes to the console. After 8 errors in a row, the callback stops. An enemy with a stopped `ai` stands still. See [Errors](environment.md#errors).

## Limits

| Thing | Limit |
|---|---|
| Projectiles of all mods | 128 |
| Projectiles in one room at the same time | 256 |
| Enemies with a data table | 1024 |
