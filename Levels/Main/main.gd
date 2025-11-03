class_name Main extends Node2D

const MAX_MOVEMENT := 4

enum TileTransform {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
}

@onready var player: Node2D = $Player
@onready var map: TileMapLayer = $Map
@onready var possible_movement: TileMapLayer = $PossibleMovement
@onready var movement_preview: TileMapLayer = $MovementPreview

var last_hovered_tile: Vector2i = Vector2i(-1000, -1000)
var is_moving: bool = false
var movement_speed: float = 400.0

func _process(_delta: float) -> void:
    if not is_moving:
        handle_mouse_hover()

func _input(event: InputEvent) -> void:
    if is_moving:
        return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_left_click(event.position)
        if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            possible_movement.clear()
            movement_preview.clear()

func handle_mouse_hover() -> void:
    var mouse_pos = get_global_mouse_position()
    var hovered_grid_pos = map.local_to_map(mouse_pos)

    if hovered_grid_pos != last_hovered_tile:
        last_hovered_tile = hovered_grid_pos

        var tile_data = possible_movement.get_cell_source_id(hovered_grid_pos)
        if tile_data != -1:
            preview_movement_path(hovered_grid_pos)
        else:
            movement_preview.clear()

func preview_movement_path(target_pos: Vector2i) -> void:
    movement_preview.clear()

    var player_grid_pos := map.local_to_map(player.position)
    var start_world_pos := map.map_to_local(player_grid_pos)
    var target_world_pos := map.map_to_local(target_pos)
    var tile_path := find_tile_path(start_world_pos, target_world_pos)

    for i in range(tile_path.size()):
        var tile_pos = tile_path[i]

        if i == tile_path.size() - 1:
            var direction = get_direction_from_previous(tile_path, i)
            var arrow_tile = Vector2i(1, 0)
            var tile_transform = get_transform_for_arrow(direction)
            movement_preview.set_cell(tile_pos, 0, arrow_tile, tile_transform)
        elif i > 0:
            var prev_dir = get_direction_between(tile_path[i - 1], tile_path[i])
            var next_dir = get_direction_between(tile_path[i], tile_path[i + 1])

            if prev_dir == next_dir:
                var straight_tile = Vector2i(0, 1)
                var tile_transform = get_transform_for_straight(prev_dir)
                movement_preview.set_cell(tile_pos, 0, straight_tile, tile_transform)
            else:
                var turn_tile = Vector2i(1, 1)
                var tile_transform = get_transform_for_turn(prev_dir, next_dir)
                movement_preview.set_cell(tile_pos, 0, turn_tile, tile_transform)

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


func handle_left_click(mouse_pos: Vector2) -> void:
    var player_grid_pos = map.local_to_map(player.position)
    var clicked_grid_pos := map.local_to_map(mouse_pos)
    var tile_data = possible_movement.get_cell_source_id(clicked_grid_pos)

    if tile_data != -1:
        move_player_to(clicked_grid_pos)
        return

    if clicked_grid_pos == player_grid_pos:
        highlight_possible_movement(player_grid_pos)


func move_player_to(target_grid_pos: Vector2i) -> void:
    var player_grid_pos := map.local_to_map(player.position)
    var start_world_pos := map.map_to_local(player_grid_pos)
    var target_world_pos := map.map_to_local(target_grid_pos)
    var tile_path := find_tile_path(start_world_pos, target_world_pos)

    possible_movement.clear()
    movement_preview.clear()

    is_moving = true
    await animate_along_path(tile_path)
    is_moving = false


func animate_along_path(tile_path: Array[Vector2i]) -> void:
    for i in range(1, tile_path.size()):
        var target_tile = tile_path[i]
        var target_world_pos = map.map_to_local(target_tile)

        var tween = create_tween()
        var distance = player.position.distance_to(target_world_pos)
        var duration = distance / movement_speed

        tween.tween_property(player, "position", target_world_pos, duration)
        await tween.finished


func highlight_possible_movement(grid_pos: Vector2i) -> void:
    possible_movement.clear()

    var reachable_tiles = get_reachable_tiles(grid_pos, MAX_MOVEMENT)

    for tile_pos in reachable_tiles:
        possible_movement.set_cell(tile_pos, 0, Vector2i(0, 0))


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

                var path = find_tile_path(start_world_pos, target_world_pos)

                if path.size() <= max_distance:
                    reachable.append(tile_pos)

    return reachable


func find_tile_path(from: Vector2, to: Vector2) -> Array[Vector2i]:
    var navigation_map = map.get_navigation_map()

    var path = NavigationServer2D.map_get_path(navigation_map, from, to, true)

    if path.size() == 0:
        return []
    
    var tile_path: Array[Vector2i] = []
    var current_tile = map.local_to_map(path[0])
    tile_path.append(current_tile)

    for i in range(1, path.size()):
        var next_tile = map.local_to_map(path[i])
        if next_tile != current_tile:
            tile_path.append(next_tile)
            current_tile = next_tile

    return tile_path
