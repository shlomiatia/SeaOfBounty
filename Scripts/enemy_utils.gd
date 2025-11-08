class_name EnemyUtils

static func execute_enemy_ai(main: Main) -> void:
    var enemies = main.get_tree().get_nodes_in_group("enemies")
    var heroes = main.get_tree().get_nodes_in_group("heroes")

    for enemy in enemies:
        var enemy_pos = enemy.position
        var enemy_grid_pos = main.map.local_to_map(enemy_pos)
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

        var hero_grid_pos = main.map.local_to_map(nearest_hero.position)
        var distance_to_hero = abs(enemy_grid_pos.x - hero_grid_pos.x) + abs(enemy_grid_pos.y - hero_grid_pos.y)

        if distance_to_hero <= enemy.attack_range and distance_to_hero > 0:
            await main.battle.start(enemy, nearest_hero)

        elif shortest_path.size() <= enemy.max_movement + enemy.attack_range + 1:
            var attack_tile = find_best_attack_position(main, enemy, nearest_hero)
            if attack_tile != Vector2i.MIN:
                await enemy.move_to(attack_tile)
                await main.battle.start(enemy, nearest_hero)

        else:
            var tiles_to_move = min(enemy.max_movement, shortest_path.size() - 1)
            var target_tile = shortest_path[tiles_to_move]
            await enemy.move_to(target_tile)

static func find_best_attack_position(main: Main, enemy: Unit, hero: Unit) -> Vector2i:
    var hero_grid_pos = main.map.local_to_map(hero.position)
    var enemy_grid_pos = main.map.local_to_map(enemy.position)

    var tiles_in_range: Array[Vector2i] = []
    for x in range(-enemy.attack_range, enemy.attack_range + 1):
        for y in range(-enemy.attack_range, enemy.attack_range + 1):
            var distance = abs(x) + abs(y)
            if distance > enemy.attack_range or distance == 0:
                continue

            var potential_tile = hero_grid_pos + Vector2i(x, y)

            var tile_world_pos = main.map.map_to_local(potential_tile)
            var enemy_world_pos = main.map.map_to_local(enemy_grid_pos)
            var path = main.map.find_tile_path(enemy_world_pos, tile_world_pos, true)

            if path.size() > 0 and path.size() - 1 <= enemy.max_movement:
                tiles_in_range.append(potential_tile)

    if tiles_in_range.is_empty():
        return Vector2i.MIN

    var max_distance_from_hero: int = -1
    for tile in tiles_in_range:
        var distance_from_hero = abs(tile.x - hero_grid_pos.x) + abs(tile.y - hero_grid_pos.y)
        if distance_from_hero > max_distance_from_hero:
            max_distance_from_hero = distance_from_hero

    var furthest_from_hero: Array[Vector2i] = []
    for tile in tiles_in_range:
        var distance_from_hero = abs(tile.x - hero_grid_pos.x) + abs(tile.y - hero_grid_pos.y)
        if distance_from_hero == max_distance_from_hero:
            furthest_from_hero.append(tile)

    var best_tile: Vector2i = Vector2i.MIN
    var min_path_distance: int = 999999
    for tile in furthest_from_hero:
        var tile_world_pos = main.map.map_to_local(tile)
        var enemy_world_pos = main.map.map_to_local(enemy_grid_pos)
        var path = main.map.find_tile_path(enemy_world_pos, tile_world_pos, true)
        var path_distance = path.size()
        if path_distance > 0 and path_distance < min_path_distance:
            min_path_distance = path_distance
            best_tile = tile

    return best_tile
