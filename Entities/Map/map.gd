class_name Map extends TileMapLayer

func find_tile_path(from: Vector2, to: Vector2, to_opponent: bool = false) -> Array[Vector2i]:
    var from_tile = local_to_map(from)
    var to_tile = local_to_map(to)

    var occupied_tiles: Array[Vector2i] = []
    occupied_tiles.append_array(get_hero_tiles())
    occupied_tiles.append_array(get_enemy_tiles())
    if to_opponent:
        occupied_tiles.erase(to_tile)

    var open_set: Array[Vector2i] = [from_tile]
    var came_from: Dictionary = {}
    var g_score: Dictionary = {from_tile: 0}
    var f_score: Dictionary = {from_tile: Utils.get_tile_distance(from_tile, to_tile)}

    while open_set.size() > 0:
        var current = open_set[0]
        var lowest_f = f_score.get(current, INF)
        for tile in open_set:
            var f = f_score.get(tile, INF)
            if f < lowest_f:
                current = tile
                lowest_f = f

        if current == to_tile:
            return _reconstruct_path(came_from, current)

        open_set.erase(current)

        var neighbors = [
            current + Vector2i(1, 0),
            current + Vector2i(-1, 0),
            current + Vector2i(0, 1),
            current + Vector2i(0, -1)
        ]

        for neighbor in neighbors:
            if neighbor != from_tile and neighbor in occupied_tiles:
                continue

            if get_cell_source_id(neighbor) == -1:
                continue

            var tentative_g_score = g_score.get(current, INF) + 1

            if tentative_g_score < g_score.get(neighbor, INF):
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = tentative_g_score + Utils.get_tile_distance(neighbor, to_tile)

                if neighbor not in open_set:
                    open_set.append(neighbor)

    return []

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
    var path: Array[Vector2i] = [current]
    while current in came_from:
        current = came_from[current]
        path.push_front(current)
    return path

func get_hero_tiles() -> Array[Vector2i]:
    return get_group_tiles("heroes")

func get_enemy_tiles() -> Array[Vector2i]:
    return get_group_tiles("enemies")

func get_group_tiles(group: String) -> Array[Vector2i]:
    var group_tiles: Array[Vector2i] = []

    var group_nodes = get_tree().get_nodes_in_group(group)
    for group_node in group_nodes:
        var group_tile = local_to_map(group_node.position)
        group_tiles.append(group_tile)

    return group_tiles
