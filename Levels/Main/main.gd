class_name Main extends Node2D

const MAX_MOVEMENT := 4

@onready var map: Map = $Map
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var possible_attack: PossibleAttack = $PossibleAttack
@onready var movement_preview: MovementPreview = $MovementPreview

var current_hero: Hero = null
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
            clear()

func handle_mouse_hover() -> void:
    if !current_hero:
        return

    var mouse_pos = get_global_mouse_position()
    movement_preview.preview_movement_path(current_hero.position, mouse_pos)

func handle_left_click(mouse_pos: Vector2) -> void:
    var clicked_grid_pos := map.local_to_map(mouse_pos)

    var heroes = get_tree().get_nodes_in_group("heroes")

    for hero in heroes:
        var hero_grid_pos = map.local_to_map(hero.position)
        if clicked_grid_pos == hero_grid_pos:
            current_hero = hero
            clear()

            # Collect excluded tiles (all heroes and enemies)
            var excluded_tiles = get_excluded_tiles()

            # Collect only hero tiles for attack exclusion
            var hero_tiles = get_hero_tiles()

            possible_movement.highlight_possible_movement(hero_grid_pos, MAX_MOVEMENT, excluded_tiles)
            possible_attack.highlight_possible_attack(hero_tiles)
            return

    if current_hero:
        var tile_data = possible_movement.get_cell_source_id(clicked_grid_pos)

        if tile_data != -1:
            clear()
            is_moving = true
            current_hero.move_to(clicked_grid_pos)
            is_moving = false
            return

    clear()

func get_excluded_tiles() -> Array[Vector2i]:
    var excluded: Array[Vector2i] = []

    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        var hero_grid_pos = map.local_to_map(hero.position)
        excluded.append(hero_grid_pos)

    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        var enemy_grid_pos = map.local_to_map(enemy.position)
        excluded.append(enemy_grid_pos)

    return excluded

func get_hero_tiles() -> Array[Vector2i]:
    var hero_tiles: Array[Vector2i] = []

    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        var hero_grid_pos = map.local_to_map(hero.position)
        hero_tiles.append(hero_grid_pos)

    return hero_tiles

func clear() -> void:
    possible_movement.clear()
    possible_attack.clear()
    movement_preview.clear()
