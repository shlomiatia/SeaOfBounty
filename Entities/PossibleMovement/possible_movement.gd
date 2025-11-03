class_name PossibleMovement extends TileMapLayer

@export var map: Map

func highlight_possible_movement(grid_pos: Vector2i, max_movement: int) -> void:
    clear()

    var reachable_tiles = get_reachable_tiles(grid_pos, max_movement)

    for tile_pos in reachable_tiles:
        set_cell(tile_pos, 0, Vector2i(0, 0))


func get_reachable_tiles(start_pos: Vector2i, max_distance: int) -> Array[Vector2i]:
    var reachable: Array[Vector2i] = []

    var start_world_pos = map.map_to_local(start_pos)

    reachable.append(start_pos)

    for dx in range(-max_distance, max_distance + 1):
        for dy in range(-max_distance, max_distance + 1):
            var manhattan_dist = abs(dx) + abs(dy)
            if manhattan_dist > 0 and manhattan_dist <= max_distance:
                var tile_pos = Vector2i(start_pos.x + dx, start_pos.y + dy)
                var target_world_pos = map.map_to_local(tile_pos)

                var path = map.find_tile_path(start_world_pos, target_world_pos)

                if path.size() <= max_distance:
                    reachable.append(tile_pos)

    return reachable
