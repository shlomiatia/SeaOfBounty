class_name Main extends Node2D

@onready var map: Map = $Map
@onready var movement_overlay: MovementOverlay = $MovementOverlay
@onready var movement_preview: MovementPreview = $MovementPreview
@onready var battle: Battle = $Battle
@onready var turn_label: Label = $CanvasLayer/TurnLabel
@onready var cursor: Cursor = $Cursor

var current_hero: Unit = null
var is_input_disabled: bool = true

func _process(_delta: float) -> void:
    if is_input_disabled:
        return

    if !current_hero || current_hero.moved:
        return

    movement_preview.preview_movement_path(current_hero, cursor.position)

func _input(event: InputEvent) -> void:
    if is_input_disabled:
        return

    if event.is_action_pressed("confirm"):
        handle_confirm(cursor.position)
    elif event.is_action_pressed("cancel"):
        clear()

func handle_confirm(cursor_pos: Vector2) -> void:
    var clicked_grid_pos := map.local_to_map(cursor_pos)

    var entity = movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "heroes")
    if entity != null:
        current_hero = entity
        return
        
    if await HeroUtils.move_and_attack(self, clicked_grid_pos):
        return

    entity = movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "enemies")
    if entity != null:
        current_hero = null
        return

    current_hero = null
    clear()

func clear() -> void:
    movement_overlay.clear()
    movement_preview.clear()

func start_enemy_turn() -> void:
    is_input_disabled = true
    cursor.is_input_disabled = true

    await start_turn("Enemy Turn")

    await EnemyUtils.execute_enemy_ai(self)

    await start_player_turn()

func start_player_turn() -> void:
    is_input_disabled = false
    cursor.is_input_disabled = false
    
    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        hero.moved = false
        hero.activated = false

    await start_turn("Player Turn")
    

func start_turn(text: String) -> void:
    turn_label.text = text
    turn_label.visible = true
    turn_label.modulate.a = 1.0

    await get_tree().create_timer(1.0).timeout
    var tween = create_tween()
    tween.tween_property(turn_label, "modulate:a", 0.0, 0.5)
    await tween.finished
    turn_label.visible = false

func check_all_heroes_moved() -> void:
    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        if !hero.moved || !hero.activated:
            return
    
    start_enemy_turn()
