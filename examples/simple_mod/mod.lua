local spider_web = myco.add_item({
    name = "Spider Web",
    icon = "sprites/web.png",
    category = "Material",
    rarity = "Uncommon",
    value = 25,
    description = "Sticky thread from a spider.",
    lootbox_dropable = true,
})

local spider = myco.add_entity({
    name = "spider",
    sheet = "sprites/spider.png",
    anims = {
        idle = { x = 0, y = 0, frames = 2, speed = 0.6, loop = true },
        walk = { x = 0, y = 1, frames = 4, speed = 0.12, loop = true },
    },
    max_health = 40,
    contact_damage = 8,
    xp_reward = 20,
    move_speed = 120,
    attack_speed = 280,
    attack_range = 50,
    attack_cooldown = 1.4,
    attack_duration = 0.24,
    can_jump = true,
    patrol_style = "wander",
    loot = {
        { item_id = "gold", chance = 0.8, min = 1, max = 3 },
        { item_id = spider_web, chance = 0.8, min = 1, max = 2 },
    },
    hurtbox = { x = 8, y = 6, w = 32, h = 40 },
    attack_box = { x = 36, y = 10, w = 22, h = 28 },
    detect_box = { left = 120, right = 120, top = 80, bottom = 80 },
    on_death = function(info, world)
        myco.log("spider killed in " .. info.room)
    end,
})

myco.on_room_enter(function(world, player)
    local x, y = player:get_pos()
    pcall(world.spawn_entity, world, spider, x + 250, y)
end)

myco.on_level_up(function(level, world, player)
    myco.log("player " .. player:get_index() + 1 .. " reached level " .. level)
end)

myco.add_recipe({
    result_item_id = "health_vial",
    ingredients = {
        { item_id = spider_web, qty = 3 },
        { item_id = "plant_matter", qty = 5 },
    },
})

myco.add_shop_entry({ item_id = spider_web, price = 20, vendor_id = 0 })
