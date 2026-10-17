[Index](../README.md) | Previous: [Console](console.md) | Next: [Custom UI](ui.md)

# Sound and music

A mod can:

- play its own sounds
- play its own music in place of the game music
- play a sound of the game
- listen to the sounds and the music tracks that the game starts, and stop them

All of it is on this machine only. In online play each player hears the audio of their own mods.

## Files

Put the files in the mod folder. The types are `.wav`, `.ogg`, `.mp3` and `.flac`.

```
mods/
  my_mod/
    mod.lua
    sounds/
      chime.wav
      boss_theme.ogg
```

Load each file one time, at the top of `mod.lua`. Keep the handle that the load returns.

```lua
local chime = myco.load_sound("sounds/chime.wav")
local boss_theme = myco.load_music("sounds/boss_theme.ogg")
```

The game decodes the files after all mods are loaded. A file that is missing or has the wrong type is a load error. A file that exists but does not decode gives one console error, and it then plays nothing.

## Sounds

### myco.load_sound

```lua
local handle = myco.load_sound(file, voices)
```

| Argument | Default | Description |
|---|---|---|
| `file` | required | Path from the mod folder. |
| `voices` | `4` | How many times the sound can play at one time, from 1 to 8. |

When all voices are in use, a new play takes the voice that started first. Use 1 voice for a long sound that must not overlap itself. Each voice holds its own copy of the samples, so keep long sounds at 1 or 2.

### myco.play_sound

```lua
myco.play_sound(handle, volume, pitch, pan)
```

| Argument | Default | Description |
|---|---|---|
| `volume` | `1.0` | From `0.0` to `1.0`. The SFX and master volume of the player apply on top. |
| `pitch` | `1.0` | Playback speed, from `0.25` to `4.0`. `2.0` is one octave up. |
| `pan` | `0.0` | From `-1.0` (left) to `1.0` (right). |

```lua
myco.on_level_up(function(level, world, player)
    myco.play_sound(chime, 1.0, 1.0 + level * 0.02)
end)
```

### myco.play_sound_at

```lua
myco.play_sound_at(handle, x, y, listener, reach, volume, pitch)
```

Plays a sound at a place in the room. `listener` is the Player that hears it. The sound moves left or right with the horizontal distance and gets quiet with the distance.

| Argument | Default | Description |
|---|---|---|
| `x`, `y` | required | Position in room pixels. See [Positions](players-and-worlds.md#positions). |
| `listener` | required | A Player object. |
| `reach` | `600` | Distance in pixels at which the sound is silent. |
| `volume`, `pitch` | `1.0` | As in `play_sound`. |

```lua
myco.on_enemy_killed(function(info, world)
    local listener = world:get_player(0)
    if listener then
        myco.play_sound_at(chime, info.x, info.y, listener)
    end
end)
```

Online, `on_enemy_killed` runs on the host only, so only the host hears this sound.

In splitscreen all players share one pair of speakers. Pick one listener. If you play the sound one time for each player, it is louder.

### myco.stop_sound

```lua
myco.stop_sound(handle)
```

Stops each voice of the sound.

### myco.sound_playing

```lua
local playing = myco.sound_playing(handle)
```

Returns `true` while a voice of the sound plays.

## Music

One mod track can play at a time. While it plays, the game music is paused. When it ends or stops, the game music continues.

### myco.load_music

```lua
local handle = myco.load_music(file)
```

Music is streamed from the file. It does not use memory for the full track.

### myco.play_music

```lua
myco.play_music(handle, loop, volume, fade)
```

| Argument | Default | Description |
|---|---|---|
| `loop` | `true` | The track starts again at its end. |
| `volume` | `1.0` | From `0.0` to `1.0`. The music and master volume of the player apply on top. |
| `fade` | `0` | Seconds of the fade in. |

A call for the track that plays now does not restart it. It changes `loop`, `volume` and the fade. A call for a different track stops the current one.

### myco.stop_music

```lua
myco.stop_music(fade)
```

Stops the mod track and gives the music back to the game. `fade` is the seconds of the fade out. It defaults to `0`.

### myco.music_playing

```lua
local playing = myco.music_playing()
```

Returns `true` while a mod track plays. This is the track of any mod.

```lua
local boss_theme = myco.load_music("sounds/boss_theme.ogg")

myco.on_room_enter(function(world, player)
    if world:get_room_name() == "mymod_boss_room" then
        myco.play_music(boss_theme, true, 1.0, 2.0)
    elseif myco.music_playing() then
        myco.stop_music(2.0)
    end
end)
```

## Sounds and music of the game

### myco.play_sfx

```lua
local found = myco.play_sfx(name, pitch)
```

Plays a sound of the game. Returns `false` when no sound has the name.

Names: `button`, `attack`, `death`, `jump`, `walk`, `dash`, `land`, `swim`, `hit_enemy`, `hurt`, `title`, `rain_hit`, `thunder`.

### myco.on_sfx

```lua
local handle = myco.on_sfx(fn)
```

The game calls `fn(name)` before it plays one of its sounds. Return `false` to stop the sound. Any other return value lets it play.

```lua
local soft_step = myco.load_sound("sounds/soft_step.wav")

myco.on_sfx(function(name)
    if name == "walk" then
        myco.play_sound(soft_step, 0.6)
        return false
    end
end)
```

Rules:

- A sound that a mod plays with `play_sfx` or `play_sound` does not call the listeners.
- When one listener returns `false`, the sound does not play. The other listeners still run.
- Some sounds play very often. `rain_hit` can play many times each second. Test the name first and return fast.

To change a sound for the whole game with no code, replace its file with [`replace_asset`](tilesets.md#mycoreplace_asset).

### myco.on_music

```lua
local handle = myco.on_music(fn)
```

The game calls `fn(name)` when it is about to start one of its tracks. Return `false` to stop the track. The game then plays no music until it changes to a different track.

Names: `menu`, `overworld`, `xenogolemjr_theme`.

```lua
local my_overworld = myco.load_music("sounds/overworld.ogg")

myco.on_music(function(name)
    if name == "overworld" then
        myco.play_music(my_overworld, true, 1.0, 1.0)
    elseif myco.music_playing() then
        myco.stop_music(1.0)
    end
end)
```

This plays the mod track where the game plays `overworld`, and gives the music back for each other track.

### myco.get_volume

```lua
local volume = myco.get_volume(kind)
```

Returns a volume setting of the player from `0.0` to `1.0`. `kind` is `"master"`, `"sfx"` or `"music"`. The game applies these to mod audio by itself. Read them only to show them.

## Remove a listener

Each `on_*` function returns a handle. `myco.remove_hook(handle)` removes the listener. See [Hooks](hooks.md#mycoremove_hook).

## Limits

| Thing | Limit |
|---|---|
| Sounds, across all mods | 128 |
| Music tracks, across all mods | 32 |
| Voices of one sound | 8 |
| Listeners of `on_sfx`, across all mods | 32 |
| Listeners of `on_music`, across all mods | 32 |

Mods load again when a game session starts. A mod track that plays in the menu stops at that time.
