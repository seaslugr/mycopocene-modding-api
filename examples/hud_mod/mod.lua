name = "HUD Mod"
version = "1.0.0"
author = "example_author"

local ui_rect = caffeine.ui_rect
local ui_text = caffeine.ui_text

local kills = 0
local show_counter = true
local opacity = 0.6

caffeine.on_enemy_killed(function(info, world)
    kills = kills + 1
end)

caffeine.on_run_start(function(world, player)
    if player:get_index() == 0 then
        kills = 0
    end
end)

caffeine.add_command("kills", "kills [number] - show or set the kill counter", function(args, world, player)
    local value = tonumber(args)
    if value then
        kills = math.floor(value)
    end
    caffeine.log("kills: " .. kills)
end)

caffeine.on_draw_ui(function()
    if show_counter then
        ui_rect(10, 10, 130, 30, 0, 0, 0, math.floor(opacity * 255), "top_right")
        ui_text("Kills: " .. kills, 20, 16, 16, 255, 255, 255, 255, "top_right")
    end

    if caffeine.key_pressed("k") then
        if caffeine.ui_popup_is_open() then
            caffeine.ui_popup_close()
        else
            caffeine.ui_popup_open()
        end
    end

    if caffeine.ui_popup_is_open() then
        local w, h = caffeine.ui_screen_size()
        ui_rect(0, 0, w, h, 0, 0, 0, 160)
        ui_text("HUD Mod", 0, 60, 24, 255, 255, 255, 255, "top_center")
        show_counter = caffeine.ui_checkbox("Show the kill counter", show_counter, -110, 110, 220, 20, "top_center")
        opacity = caffeine.ui_slider("hud_opacity", opacity, 0, 1, -110, 145, 220, 20, "top_center")
        if caffeine.ui_button("Close", -40, 185, 30, 18, "top_center") then
            caffeine.ui_popup_close()
        end
    end
end)
