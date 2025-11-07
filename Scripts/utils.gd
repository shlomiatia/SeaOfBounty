class_name Utils

static func get_entity_at_tile(map: Map, tile_pos: Vector2i, group: String) -> Node2D:
    var entities = map.get_tree().get_nodes_in_group(group)

    for entity in entities:
        var entity_grid_pos = map.local_to_map(entity.position)
        if tile_pos == entity_grid_pos:
            return entity

    return null