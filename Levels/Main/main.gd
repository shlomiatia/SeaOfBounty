class_name Main extends Node2D

const MAX_MOVEMENT := 4

@onready var player: Node2D = $Player
@onready var map: TileMapLayer = $Map
@onready var possible_movement: TileMapLayer = $PossibleMovement
@onready var movement_preview: TileMapLayer = $MovementPreview

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_left_click(event.position)
        if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            possible_movement.clear()


func handle_left_click(mouse_pos: Vector2) -> void:
    var player_grid_pos = Vector2i(
        int(player.position.x / 80),
        int(player.position.y / 80)
    )

    var clicked_grid_pos = Vector2i(
        int(mouse_pos.x / 80),
        int(mouse_pos.y / 80)
    )

    if clicked_grid_pos == player_grid_pos:
        highlight_possible_movement(player_grid_pos)


func highlight_possible_movement(grid_pos: Vector2i) -> void:
    possible_movement.clear()

    var reachable_tiles = get_reachable_tiles(grid_pos, MAX_MOVEMENT)

    for tile_pos in reachable_tiles:
        possible_movement.set_cell(tile_pos, 0, Vector2i(0, 0))


func get_reachable_tiles(start_pos: Vector2i, max_distance: int) -> Array[Vector2i]:
    var reachable: Array[Vector2i] = []

    var start_world_pos = map.map_to_local(start_pos)

    for dx in range(-max_distance, max_distance + 1):
        for dy in range(-max_distance, max_distance + 1):
            var manhattan_dist = abs(dx) + abs(dy)
            if manhattan_dist > 0 and manhattan_dist <= max_distance:
                var tile_pos = Vector2i(start_pos.x + dx, start_pos.y + dy)
                var target_world_pos = map.map_to_local(tile_pos)

                var path = find_navigation_path(start_world_pos, target_world_pos)


                if path.size() > 0:
                    var path_length = calculate_path_length_in_tiles(path)
                    if path_length <= max_distance:
                        reachable.append(tile_pos)

    return reachable


func find_navigation_path(from: Vector2, to: Vector2) -> PackedVector2Array:
    var navigation_map = map.get_navigation_map()

    var path = NavigationServer2D.map_get_path(navigation_map, from, to, true)

    return path


func calculate_path_length_in_tiles(path: PackedVector2Array) -> int:
    if path.size() < 2:
        return 0

    var tile_count = 0
    var current_tile = map.local_to_map(path[0])

    for i in range(1, path.size()):
        var next_tile = map.local_to_map(path[i])
        if next_tile != current_tile:
            tile_count += 1
            current_tile = next_tile

    return tile_count
