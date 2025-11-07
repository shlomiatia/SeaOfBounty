class_name Main extends Node2D

@onready var map: Map = $Map
@onready var movement_overlay: MovementOverlay = $MovementOverlay
@onready var movement_preview: MovementPreview = $MovementPreview
@onready var battle: Battle = $Battle
@onready var turn_label: Label = $CanvasLayer/TurnLabel
@onready var cursor: Cursor = $Cursor

var current_hero: Unit = null
var is_input_disabled: bool = false
var moved_heroes: Array[Unit] = []

func _ready() -> void:
    start_player_turn()

func _process(_delta: float) -> void:
    if is_input_disabled:
        return

    if !current_hero || current_hero in moved_heroes:
        return

    movement_preview.preview_movement_path(current_hero.position, cursor.position)

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
        
    if await move_and_attack(clicked_grid_pos):
        return

    entity = movement_overlay.highlight_movement_and_attack(clicked_grid_pos, "enemies")
    if entity != null:
        current_hero = null
        return

    current_hero = null
    clear()

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
                await battle.start()

            current_hero.modulate = Color(0.5, 0.5, 0.5)
            moved_heroes.append(current_hero)
            current_hero = null

            is_input_disabled = false

            check_all_heroes_moved()
            return true
    return false


func can_attack(target_pos: Vector2i) -> bool:
    var attack_tile_data = movement_overlay.possible_attack.get_cell_source_id(target_pos)
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
    movement_overlay.clear()
    movement_preview.clear()

func start_enemy_turn() -> void:
    is_input_disabled = true

    await start_turn("Enemy Turn")

    await execute_enemy_ai()

    await start_player_turn()

func start_player_turn() -> void:
    is_input_disabled = false
    moved_heroes.clear()
    
    var heroes = get_tree().get_nodes_in_group("heroes")
    for hero in heroes:
        hero.modulate = Color(1, 1, 1)

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
    if moved_heroes.size() >= heroes.size():
        start_enemy_turn()

func execute_enemy_ai() -> void:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var heroes = get_tree().get_nodes_in_group("heroes")

    for enemy in enemies:
        var enemy_pos = enemy.position
        var shortest_path: Array[Vector2i] = []
        var nearest_hero: Unit = null

        for hero in heroes:
            var hero_pos = hero.position
            var path = map.find_tile_path(enemy_pos, hero_pos, true)

            if path.size() > 0:
                if shortest_path.size() == 0 or path.size() < shortest_path.size():
                    shortest_path = path
                    nearest_hero = hero

        if shortest_path.size() == 0 or nearest_hero == null:
            continue

        if shortest_path.size() == 2:
            await battle.start()

        elif shortest_path.size() <= enemy.max_movement + 2:
            var target_tile = shortest_path[shortest_path.size() - 2]
            await enemy.move_to(target_tile)

            await battle.start()

        else:
            var tiles_to_move = min(enemy.max_movement, shortest_path.size() - 1)
            var target_tile = shortest_path[tiles_to_move]
            await enemy.move_to(target_tile)