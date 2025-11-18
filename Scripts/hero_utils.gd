class_name HeroUtils

static func move_and_attack(main: Main, clicked_grid_pos: Vector2i) -> bool:
    var current_hero = main.current_hero
    var movement_preview = main.movement_preview
    var map = main.map
    var battle = main.battle
    
    if current_hero && (!current_hero.moved || !current_hero.activated):
        var target_pos = movement_preview.last_hovered_tile
        var can_move = target_pos != Vector2i.MIN
        var enemy = Utils.get_entity_at_tile(map, clicked_grid_pos, "enemies")

        if can_move || (enemy != null && Utils.is_in_range(current_hero, clicked_grid_pos, map)):
            main.is_input_disabled = true
            main.clear()
            if can_move:
                await current_hero.move_to(target_pos)
            
            var can_attack = Utils.is_in_range(current_hero, clicked_grid_pos, map)
            if can_attack:
                await battle.start(current_hero, enemy)
                current_hero.activated = true

            current_hero.moved = true
            main.is_input_disabled = false

            var heroes = main.get_tree().get_nodes_in_group("heroes")
            for hero in heroes:
                if hero.moved && !hero.activated:
                    hero.activated = main.map.get_enemy_tiles().filter(func(enemy_tile): return Utils.is_in_range(hero, enemy_tile, map)).size() == 0

            if !current_hero.activated:
                main.movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "heroes")
                main.movement_preview.preview_movement_path(current_hero, clicked_grid_pos)
            else:
                main.current_hero = null

            return true
    return false
