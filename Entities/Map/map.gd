class_name Map extends TileMapLayer

func find_tile_path(from: Vector2, to: Vector2) -> Array[Vector2i]:
    var navigation_map = get_navigation_map()

    var path = NavigationServer2D.map_get_path(navigation_map, from, to, true)

    if path.size() == 0:
        return []
    
    var tile_path: Array[Vector2i] = []
    var current_tile = local_to_map(path[0])
    tile_path.append(current_tile)

    for i in range(1, path.size()):
        var next_tile = local_to_map(path[i])
        if next_tile != current_tile:
            tile_path.append(next_tile)
            current_tile = next_tile

    return tile_path
