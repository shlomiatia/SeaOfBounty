class_name HeroUtils

static func move_and_attack(main: Main, clicked_grid_pos: Vector2i) -> bool:
    var current_hero = main.current_hero
    var movement_preview = main.movement_preview
    var map = main.map
    var battle = main.battle
    if current_hero && !current_hero.moved:
        var target_pos = movement_preview.last_hovered_tile
        var can_move = target_pos != Vector2i.MIN
        var enemy = Utils.get_entity_at_tile(map, clicked_grid_pos, "enemies")

        if can_move || (enemy != null && Utils.is_in_range(current_hero, clicked_grid_pos, map)):
            main.is_input_disabled = true
            main.clear()
            if can_move:
                await current_hero.move_to(target_pos)
            
            if Utils.is_in_range(current_hero, clicked_grid_pos, map):
                await battle.start(current_hero, enemy)

            current_hero.set_is_moved(true)

            main.is_input_disabled = false
            main.check_all_heroes_moved()

            return true
    return false
