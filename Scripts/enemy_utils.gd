class_name EnemyUtils

static func execute_single_enemy_ai(enemy: Unit, main: Main) -> void:
    var shortest_path: Array[Vector2i] = []
    var shortest_path_in_range: Array[Vector2i] = []
    var nearest_hero: Unit = null
    var heroes = main.get_tree().get_nodes_in_group("heroes")

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

        if Utils.is_in_range(enemy, main.map.local_to_map(hero_pos), main.map):
            shortest_path = []
            shortest_path_in_range = [main.map.local_to_map(enemy.position)]
            nearest_hero = hero
            break


    if shortest_path.size() > 0:
        await enemy.move_to(shortest_path[shortest_path.size() - 1])

    if shortest_path_in_range.size() > 0:
        await main.battle.start(enemy, nearest_hero)

static func execute_enemy_ai(main: Main) -> void:
    var enemies = main.get_tree().get_nodes_in_group("enemies")
    var tentacles: Array[Unit] = []

    var non_tentacle_enemies: Array[Unit] = []
    for enemy in enemies:
        if enemy.display_name == "Tentacle":
            tentacles.append(enemy)
            var animated_sprite = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
            animated_sprite.play_backwards("emerge")
        else:
            non_tentacle_enemies.append(enemy)
    if tentacles.size() > 0:
        await main.get_tree().create_timer(0.5).timeout
        for tentacle in tentacles:
            tentacle.position = main.map.map_to_local(Vector2i(-1, -1))


    for enemy in non_tentacle_enemies:
        await execute_single_enemy_ai(enemy, main)

    var kraken: Unit = null
    for enemy in main.get_tree().get_nodes_in_group("enemies"):
        if enemy.display_name == "Kraken":
            kraken = enemy
            break

    if kraken == null:
        return

    var kraken_tile = main.map.local_to_map(kraken.position)

    for tentacle in tentacles:
        var tentacle_tile = Vector2i.MIN

        for ring_distance in range(1, 5):
            tentacle_tile = get_tentacle_tile(main, kraken_tile, ring_distance)
            if tentacle_tile != Vector2i.MIN:
                break
            
            
        tentacle.position = main.map.map_to_local(tentacle_tile)
        var animated_sprite = tentacle.get_node("AnimatedSprite2D") as AnimatedSprite2D
        animated_sprite.play("emerge")

    if tentacles.size() > 0:
        await main.get_tree().create_timer(0.5).timeout

    for enemy in tentacles:
        await execute_single_enemy_ai(enemy, main)

static func get_tentacle_tile(main: Main, kraken_tile: Vector2i, radius: int):
    var goal_tile: Vector2i = Vector2i.MIN
    var heroes = main.get_tree().get_nodes_in_group("heroes")
    for row in range(kraken_tile.y - radius, kraken_tile.y + radius + 1):
        for col in range(kraken_tile.x - radius, kraken_tile.x + radius + 1):
            if row == kraken_tile.y and col == kraken_tile.x:
                continue
            var tile = Vector2i(col, row)
            var unit_at_tile = Utils.get_entity_at_tile(main.map, tile, "units")
            if unit_at_tile != null:
                continue
            goal_tile = tile

            for hero in heroes:
                var hero_tile = main.map.local_to_map(hero.position)
                if Utils.get_tile_distance(tile, hero_tile) == 1:
                    return tile

    return goal_tile
