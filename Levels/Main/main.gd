class_name Main extends Node2D

const MAX_MOVEMENT := 4

@onready var player: Node2D = $Player
@onready var map: TileMapLayer = $Map
@onready var possible_movement: TileMapLayer = $PossibleMovement

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_left_click(event.position)


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

    reachable.append(start_pos)

    for dx in range(-max_distance, max_distance + 1):
        for dy in range(-max_distance, max_distance + 1):
            var manhattan_dist = abs(dx) + abs(dy)
            if manhattan_dist > 0 and manhattan_dist <= max_distance:
                var tile_pos = Vector2i(start_pos.x + dx, start_pos.y + dy)
                reachable.append(tile_pos)

    return reachable
