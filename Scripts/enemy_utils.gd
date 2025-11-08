class_name EnemyUtils

static func execute_enemy_ai(main: Main) -> void:
    var enemies = main.get_tree().get_nodes_in_group("enemies")
    var heroes = main.get_tree().get_nodes_in_group("heroes")

    for enemy in enemies:
        var enemy_pos = enemy.position
        var shortest_path: Array[Vector2i] = []
        var nearest_hero: Unit = null

        for hero in heroes:
            var hero_pos = hero.position
            var path = main.map.find_tile_path(enemy_pos, hero_pos, true)

            if path.size() > 0:
                if shortest_path.size() == 0 or path.size() < shortest_path.size():
                    shortest_path = path
                    nearest_hero = hero

        if shortest_path.size() == 0 or nearest_hero == null:
            continue

        if shortest_path.size() == 2:
            await main.battle.start(enemy, nearest_hero)

        elif shortest_path.size() <= enemy.max_movement + 2:
            var target_tile = shortest_path[shortest_path.size() - 2]
            await enemy.move_to(target_tile)

            await main.battle.start(enemy, nearest_hero)

        else:
            var tiles_to_move = min(enemy.max_movement, shortest_path.size() - 1)
            var target_tile = shortest_path[tiles_to_move]
            await enemy.move_to(target_tile)
