class_name Main extends Node2D

@onready var map: Map = $Map
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var attack_range: AttackRange = $AttackRange
@onready var possible_attack: PossibleAttack = $PossibleAttack
@onready var movement_preview: MovementPreview = $MovementPreview
@onready var battle: Battle = $Battle
@onready var turn_label: Label = $CanvasLayer/TurnLabel

var current_hero: Unit = null
var is_input_disabled: bool = false
var moved_heroes: Array[Unit] = []

func _ready() -> void:
    start_player_turn()

func _process(_delta: float) -> void:
    if is_input_disabled:
        return
    
    handle_mouse_hover()

func _input(event: InputEvent) -> void:
    if is_input_disabled:
        return

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            handle_left_click(event.position)
        if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            clear()

func handle_mouse_hover() -> void:
    if !current_hero || current_hero in moved_heroes:
        return

    var mouse_pos = get_global_mouse_position()

    movement_preview.preview_movement_path(current_hero.position, mouse_pos)

func handle_left_click(mouse_pos: Vector2) -> void:
    var clicked_grid_pos := map.local_to_map(mouse_pos)

    if highlight_movement_and_attack(clicked_grid_pos, "heroes"):
        return
        
    if await move_and_attack(clicked_grid_pos):
        return

    if highlight_movement_and_attack(clicked_grid_pos, "enemies"):
        return

    current_hero = null
    clear()

func highlight_movement_and_attack(clicked_grid_pos: Vector2i, group: String) -> bool:
    var entities = get_tree().get_nodes_in_group(group)

    for entity in entities:
        var entity_grid_pos = map.local_to_map(entity.position)
        if clicked_grid_pos == entity_grid_pos:
            if group == "heroes":
                current_hero = entity
            else:
                current_hero = null
            clear()

            possible_movement.highlight_possible_movement(clicked_grid_pos, entity.max_movement)
            attack_range.highlight_attack_range(entity)
            possible_attack.highlight_possible_attack(entity)

            return true

    return false

func move_and_attack(clicked_grid_pos: Vector2i) -> bool:
    if current_hero && !current_hero in moved_heroes:
        var target_pos = movement_preview.last_hovered_tile
        var can_move = target_pos != Vector2i.MIN

        if can_move || can_attack(clicked_grid_pos):
            is_input_disabled = true
            clear()
            if can_move:
                await current_hero.move_to(target_pos)
            if is_adjcent_to_hero(clicked_grid_pos):
                battle.visible = true
                await battle.start()
                battle.visible = false

            current_hero.modulate = Color(0.5, 0.5, 0.5)
            moved_heroes.append(current_hero)
            current_hero = null

            is_input_disabled = false

            check_all_heroes_moved()
            return true
    return false

func can_attack(target_pos: Vector2i) -> bool:
    var attack_tile_data = possible_attack.get_cell_source_id(target_pos)
    if attack_tile_data == -1:
        return false

    return is_adjcent_to_hero(target_pos)

    
func is_adjcent_to_hero(target_pos: Vector2i) -> bool:
    if !current_hero:
        return false

    var current_hero_tile = map.local_to_map(current_hero.position)
    var is_adjacent = (
        target_pos == current_hero_tile + Vector2i(1, 0) or
        target_pos == current_hero_tile + Vector2i(-1, 0) or
        target_pos == current_hero_tile + Vector2i(0, 1) or
        target_pos == current_hero_tile + Vector2i(0, -1)
    )
    return is_adjacent

func clear() -> void:
    possible_movement.clear()
    attack_range.clear()
    possible_attack.clear()
    movement_preview.clear()

func start_player_turn() -> void:
    is_input_disabled = false
    moved_heroes.clear()

    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        hero.modulate = Color(1, 1, 1)

    turn_label.text = "Your Turn"
    turn_label.visible = true
    turn_label.modulate.a = 1.0

    await get_tree().create_timer(1.0).timeout
    var tween = create_tween()
    tween.tween_property(turn_label, "modulate:a", 0.0, 0.5)
    await tween.finished
    turn_label.visible = false

func start_enemy_turn() -> void:
    is_input_disabled = true

    turn_label.text = "Enemy Turn"
    turn_label.visible = true
    turn_label.modulate.a = 1.0

    await get_tree().create_timer(1.0).timeout
    var tween = create_tween()
    tween.tween_property(turn_label, "modulate:a", 0.0, 0.5)
    await tween.finished
    turn_label.visible = false

    # TODO: Add enemy AI logic here

    start_player_turn()

func check_all_heroes_moved() -> void:
    var heroes = get_tree().get_nodes_in_group("heroes")
    if moved_heroes.size() >= heroes.size():
        start_enemy_turn()
