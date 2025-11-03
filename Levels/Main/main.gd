class_name Main extends Node2D

const MAX_MOVEMENT := 4


@onready var player: Node2D = $Player
@onready var map: Map = $Map
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var movement_preview: MovementPreview = $MovementPreview

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
            movement_preview.preview_movement_path(player.position, hovered_grid_pos)
        else:
            movement_preview.clear()


func handle_left_click(mouse_pos: Vector2) -> void:
    var player_grid_pos = map.local_to_map(player.position)
    var clicked_grid_pos := map.local_to_map(mouse_pos)
    var tile_data = possible_movement.get_cell_source_id(clicked_grid_pos)

    if tile_data != -1:
        move_player_to(clicked_grid_pos)
        return

    if clicked_grid_pos == player_grid_pos:
        possible_movement.highlight_possible_movement(player_grid_pos, MAX_MOVEMENT)


func move_player_to(target_grid_pos: Vector2i) -> void:
    var player_grid_pos := map.local_to_map(player.position)
    var start_world_pos := map.map_to_local(player_grid_pos)
    var target_world_pos := map.map_to_local(target_grid_pos)
    var tile_path := map.find_tile_path(start_world_pos, target_world_pos)

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
