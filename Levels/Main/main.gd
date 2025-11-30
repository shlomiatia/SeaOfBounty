class_name Main extends Node2D

signal player_turn_started
signal won;

@onready var map: Map = $Map
@onready var movement_overlay: MovementOverlay = $MovementOverlay
@onready var movement_preview: MovementPreview = $MovementPreview
@onready var battle: Battle = $Battle
@onready var turn_label: Label = $CanvasLayer/TurnLabel
@onready var cursor: Cursor = $Cursor
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var controls_label: Label = $CanvasLayer/ControlsLabel

var current_hero: Unit = null
var is_input_disabled: bool = true

func _process(_delta: float) -> void:
    controls_label.visible = !is_input_disabled && current_hero != null
    controls_label.text = "%s - Skip hero turn.\n%s - Deselect hero." % [LastInput.get_text("Backspace", "Backspace", "Y button"), LastInput.get_text("Right mouse button", "Shift", "B button")]

    if is_input_disabled:
        return

    if !current_hero || current_hero.moved:
        return

    movement_preview.preview_movement_path(current_hero, cursor.position)
    movement_overlay.possible_attack.preview_attack(current_hero, cursor.position)

func _unhandled_input(event: InputEvent) -> void:
    if is_input_disabled:
        return

    if event.is_action_pressed("skip") && current_hero:
        skip_current_hero_turn()

    if event.is_action_pressed("confirm"):
        if is_game_over():
            get_tree().reload_current_scene()
            return

        if LastInput.last_input_type == LastInput.InputType.MOUSE:
            var mouse_pos = get_global_mouse_position()
            cursor.set_cursor_position(mouse_pos)

        handle_confirm(cursor.position)
    elif event.is_action_pressed("cancel"):
        deselect_current_hero()

func skip_current_hero_turn() -> void:
    if current_hero != null:
        play_confirm()
        current_hero.moved = true
        current_hero.activated = true
        current_hero = null
        clear()
        start_enemy_turn_if_needed()
        
func deselect_current_hero() -> void:
    current_hero = null
    clear()

func handle_confirm(cursor_pos: Vector2) -> void:
    var clicked_grid_pos := map.local_to_map(cursor_pos)

    if current_hero != null && current_hero.display_name == "Lia" && !current_hero.activated:
        var hero = Utils.get_entity_at_tile(map, clicked_grid_pos, "heroes")
        if hero != null && hero.hp < hero.max_hp:
            current_hero.moved = true
            current_hero.activated = true
            current_hero = null
            clear()
            audio_stream_player.stream = preload("res://Sounds/Sfx/lazer.wav")
            audio_stream_player.play()
            var tween = create_tween()
            tween.tween_method(func(value: float): hero.hp = value, hero.hp, min(hero.hp + 40, hero.max_hp), 0.5)
            start_enemy_turn_if_needed()
            return


    var entity = movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "heroes")
    if entity != null:
        play_confirm()
        current_hero = entity
        return
        
    if await HeroUtils.move_and_attack(self, clicked_grid_pos):
        start_enemy_turn_if_needed()
        return

    entity = movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "enemies")
    if entity != null:
        play_confirm()
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

    if await start_turn("Enemy Turn"):
        return

    await EnemyUtils.execute_enemy_ai(self)

    await start_player_turn()

func start_player_turn() -> void:
    player_turn_started.emit()
    is_input_disabled = false
    cursor.is_input_disabled = false

    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        hero.moved = false
        hero.activated = false

    await start_turn("Player Turn")
    
func start_turn(text: String) -> bool:
    if is_game_over():
        turn_label.text = "Game over :( Press to restart"
        turn_label.modulate.a = 1.0
        is_input_disabled = false
        cursor.is_input_disabled = false
        return true

    if is_won():
        is_input_disabled = true
        cursor.is_input_disabled = true
        won.emit()
        return true
        
    turn_label.text = text
    turn_label.modulate.a = 1.0

    await get_tree().create_timer(1.0).timeout

    var tween = create_tween()
    tween.tween_property(turn_label, "modulate:a", 0.0, 0.5)
    await tween.finished

    return false

func start_enemy_turn_if_needed() -> void:
    if is_won() || get_tree().get_nodes_in_group("heroes").filter(func(hero: Unit): return !hero.moved || !hero.activated).size() == 0:
        start_enemy_turn()

func play_confirm() -> void:
    audio_stream_player.stream = preload("res://Sounds/button press.mp3")
    audio_stream_player.play()

func is_game_over() -> bool:
    return get_tree().get_nodes_in_group("heroes").filter(func(hero: Unit): return hero.hp > 0).size() == 0

func is_won() -> bool:
    return get_tree().get_nodes_in_group("enemies").filter(func(hero: Unit): return hero.hp > 0).size() == 0
