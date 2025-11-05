class_name Map extends TileMapLayer

func find_tile_path(from: Vector2, to: Vector2) -> Array[Vector2i]:
    for enemy_tile in get_enemy_tiles():
        set_cell(enemy_tile)
    update_internals()
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
