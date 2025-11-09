class_name Utils

static func get_entity_at_tile(map: Map, tile_pos: Vector2i, group: String) -> Node2D:
    var entities = map.get_tree().get_nodes_in_group(group)

    for entity in entities:
        var entity_grid_pos = map.local_to_map(entity.position)
        if tile_pos == entity_grid_pos:
            return entity

    return null

static func find_path_to_tile_in_range(unit: Unit, target_pos: Vector2, map: Map) -> Array[Vector2i]:
    var target_grid_pos = map.local_to_map(target_pos)

    var tile_path = map.find_tile_path(unit.position, target_pos, true)

    tile_path = tile_path.slice(0, unit.max_movement + 1)

    for i in range(tile_path.size()):
        var tile_pos = tile_path[i]
        var distance_to_target = get_tile_distance(tile_pos, target_grid_pos)

        if distance_to_target <= unit.attack_range:
            return tile_path.slice(0, i + 1)

    return []

static func is_in_range(unit: Unit, target_pos: Vector2i, map: Map) -> bool:
    var unit_grid_pos = map.local_to_map(unit.position)
    var distance = get_tile_distance(unit_grid_pos, target_pos)
    return distance <= unit.attack_range

static func get_tile_distance(a: Vector2i, b: Vector2i) -> int:
    return abs(a.x - b.x) + abs(a.y - b.y)
