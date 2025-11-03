class_name Main extends Node2D

const MAX_MOVEMENT := 4

@onready var hero: Hero = $Hero
@onready var map: Map = $Map
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var movement_preview: MovementPreview = $MovementPreview

var is_moving: bool = false

func _process(_delta: float) -> void:
    if is_moving:
        return
    
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
    movement_preview.preview_movement_path(hero.position, mouse_pos)

func handle_left_click(mouse_pos: Vector2) -> void:
    var player_grid_pos = map.local_to_map(hero.position)
    var clicked_grid_pos := map.local_to_map(mouse_pos)
    var tile_data = possible_movement.get_cell_source_id(clicked_grid_pos)

    if tile_data != -1:
        possible_movement.clear()
        movement_preview.clear()
        is_moving = true
        hero.move_to(clicked_grid_pos)
        is_moving = false
        return

    if clicked_grid_pos == player_grid_pos:
        possible_movement.highlight_possible_movement(player_grid_pos, MAX_MOVEMENT)
