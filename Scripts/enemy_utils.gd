class_name EnemyUtils

static func execute_enemy_ai(main: Main) -> void:
    var enemies = main.get_tree().get_nodes_in_group("enemies")
    var heroes = main.get_tree().get_nodes_in_group("heroes")

    for enemy in enemies:
        var shortest_path: Array[Vector2i] = []
        var shortest_path_in_range: Array[Vector2i] = []
        var nearest_hero: Unit = null

        for hero in heroes:
            if hero.hp == 0:
                continue
            var hero_pos = hero.position
            var path = Utils.find_path_to_tile_in_range(enemy, hero_pos, main.map)

            if path.size() > 0:
                if shortest_path_in_range.size() == 0 || path.size() < shortest_path_in_range.size():
                    shortest_path_in_range = path
                    shortest_path = path
                    nearest_hero = hero
                    continue

            if shortest_path_in_range.size() == 0:
                path = Utils.find_path_to_tile_with_max_movement(enemy, hero_pos, main.map)

                if path.size() > 0 && (shortest_path.size() == 0 || path.size() < shortest_path.size()):
                    shortest_path = path
                    nearest_hero = hero
        
        if shortest_path.size() > 0:
            await enemy.move_to(shortest_path[shortest_path.size() - 1])

        if shortest_path_in_range.size() > 0:
            await main.battle.start(enemy, nearest_hero)
