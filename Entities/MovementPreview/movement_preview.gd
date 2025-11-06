class_name MovementPreview extends TileMapLayer

enum TileTransform {
    ROTATE_0 = 0,
    ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
    ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
    ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

@onready var map: Map = $"../Map"
@onready var possible_movement: PossibleMovement = $"../MovementOverlay/PossibleMovement"

var last_hovered_tile: Vector2i = Vector2i.MIN

func preview_movement_path(source_pos: Vector2, target_pos: Vector2) -> void:
    var player_grid_pos := map.local_to_map(source_pos)
    var hovered_grid_pos = map.local_to_map(target_pos)

    var enemy_tiles = map.get_enemy_tiles()
    for enemy_grid_pos in enemy_tiles:
        if hovered_grid_pos == enemy_grid_pos:
            if last_hovered_tile != Vector2i.MIN:
                return
            var adjacent_offsets = [
                Vector2i(1, 0),
                Vector2i(-1, 0),
                Vector2i(0, 1),
                Vector2i(0, -1)
            ]

            for offset in adjacent_offsets:
                var adjacent_tile = enemy_grid_pos + offset
                if adjacent_tile == player_grid_pos:
                    return

            var found_adjacent_tile: Vector2i = Vector2i.MIN
            for offset in adjacent_offsets:
                var adjacent_tile = enemy_grid_pos + offset
                var tile_data = possible_movement.get_cell_source_id(adjacent_tile)
                if tile_data != -1:
                    found_adjacent_tile = adjacent_tile
                    break

            if found_adjacent_tile == Vector2i.MIN:
                return

            hovered_grid_pos = found_adjacent_tile
            break

    if hovered_grid_pos != last_hovered_tile:
        last_hovered_tile = Vector2i.MIN
        var tile_data = possible_movement.get_cell_source_id(hovered_grid_pos)
        clear()
        
        if tile_data != -1:
            last_hovered_tile = hovered_grid_pos
            var start_world_pos := map.map_to_local(player_grid_pos)
            var target_world_pos := map.map_to_local(hovered_grid_pos)
            var tile_path := map.find_tile_path(start_world_pos, target_world_pos)

            for i in range(tile_path.size()):
                var tile_pos = tile_path[i]

                if i == tile_path.size() - 1:
                    var direction = get_direction_from_previous(tile_path, i)
                    var arrow_tile = Vector2i(1, 0)
                    var tile_transform = get_transform_for_arrow(direction)
                    set_cell(tile_pos, 0, arrow_tile, tile_transform)
                elif i > 0:
                    var prev_dir = get_direction_between(tile_path[i - 1], tile_path[i])
                    var next_dir = get_direction_between(tile_path[i], tile_path[i + 1])

                    if prev_dir == next_dir:
                        var straight_tile = Vector2i(0, 1)
                        var tile_transform = get_transform_for_straight(prev_dir)
                        set_cell(tile_pos, 0, straight_tile, tile_transform)
                    else:
                        var turn_tile = Vector2i(1, 1)
                        var tile_transform = get_transform_for_turn(prev_dir, next_dir)
                        set_cell(tile_pos, 0, turn_tile, tile_transform)

func get_direction_from_previous(tile_path: Array[Vector2i], index: int) -> Vector2i:
    if index > 0:
        return get_direction_between(tile_path[index - 1], tile_path[index])
    return Vector2i(0, 0)

func get_direction_between(from: Vector2i, to: Vector2i) -> Vector2i:
    return Vector2i(sign(to.x - from.x), sign(to.y - from.y))


func get_transform_for_arrow(direction: Vector2i) -> int:
    if direction.y > 0:
        return TileTransform.ROTATE_180
    elif direction.x < 0:
        return TileTransform.ROTATE_270
    elif direction.y < 0:
        return TileTransform.ROTATE_0
    else:
        return TileTransform.ROTATE_90

func get_transform_for_straight(direction: Vector2i) -> int:
    if direction.y != 0:
        return TileTransform.ROTATE_90
    return TileTransform.ROTATE_0

func get_transform_for_turn(prev_dir: Vector2i, next_dir: Vector2i) -> int:
    if prev_dir.x > 0 and next_dir.y > 0:
        return TileTransform.ROTATE_270
    elif prev_dir.y < 0 and next_dir.x > 0:
        return TileTransform.ROTATE_180
    elif prev_dir.x < 0 and next_dir.y < 0:
        return TileTransform.ROTATE_90
    elif prev_dir.y > 0 and next_dir.x < 0:
        return TileTransform.ROTATE_0
    elif prev_dir.x > 0 and next_dir.y < 0:
        return TileTransform.ROTATE_0
    elif prev_dir.y > 0 and next_dir.x > 0:
        return TileTransform.ROTATE_90
    elif prev_dir.x < 0 and next_dir.y > 0:
        return TileTransform.ROTATE_180
    elif prev_dir.y < 0 and next_dir.x < 0:
        return TileTransform.ROTATE_270

    return TileTransform.ROTATE_0
