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

        if can_move || (enemy != null && is_adjcent_to_hero(current_hero, map, clicked_grid_pos)):
            main.is_input_disabled = true
            main.clear()
            if can_move:
                await current_hero.move_to(target_pos)
            
            
            if is_adjcent_to_hero(current_hero, map, clicked_grid_pos):
                await battle.start(current_hero, enemy)

            current_hero.moved = true
            current_hero.activated = true

            main.is_input_disabled = false
            main.check_all_heroes_moved()

            return true
    return false

static func is_adjcent_to_hero(current_hero: Unit, map: Map, target_pos: Vector2i) -> bool:
    var current_hero_tile = map.local_to_map(current_hero.position)
    var is_adjacent = (
        target_pos == current_hero_tile + Vector2i(1, 0) or
        target_pos == current_hero_tile + Vector2i(-1, 0) or
        target_pos == current_hero_tile + Vector2i(0, 1) or
        target_pos == current_hero_tile + Vector2i(0, -1)
    )
    return is_adjacent
