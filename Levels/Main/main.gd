class_name Main extends Node2D

@onready var map: Map = $Map
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var attack_range: AttackRange = $AttackRange
@onready var possible_attack: PossibleAttack = $PossibleAttack
@onready var movement_preview: MovementPreview = $MovementPreview
@onready var battle: Battle = $Battle

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
    var hovered_grid_pos = map.local_to_map(mouse_pos)

    var enemy_tiles = map.get_enemy_tiles()
    for enemy_grid_pos in enemy_tiles:
        if hovered_grid_pos == enemy_grid_pos:
            return

    movement_preview.preview_movement_path(current_hero.position, mouse_pos)

func handle_left_click(mouse_pos: Vector2) -> void:
    var clicked_grid_pos := map.local_to_map(mouse_pos)

    var heroes = get_tree().get_nodes_in_group("heroes")

    for hero in heroes:
        var hero_grid_pos = map.local_to_map(hero.position)
        if clicked_grid_pos == hero_grid_pos:
            current_hero = hero
            clear()
            var hero_tiles = map.get_hero_tiles()
            var enemy_tiles = map.get_enemy_tiles()
            var excluded_tiles = hero_tiles + enemy_tiles

            possible_movement.highlight_possible_movement(hero_grid_pos, hero.max_movement, excluded_tiles)
            attack_range.highlight_attack_range(hero_tiles)
            possible_attack.highlight_possible_attack(enemy_tiles)

            return

    if current_hero:
        var target_pos = movement_preview.last_hovered_tile
        var can_move = target_pos != Vector2i.MIN

        
        if can_move || can_attack(clicked_grid_pos):
            is_moving = true
            clear()
            if can_move:
                await current_hero.move_to(target_pos)
            if is_adjcent_to_hero(clicked_grid_pos):
                battle.visible = true
                await battle.start()
                battle.visible = false
            is_moving = false
            return

    var enemies = get_tree().get_nodes_in_group("enemies")

    for enemy in enemies:
        var enemy_grid_pos = map.local_to_map(enemy.position)
        if clicked_grid_pos == enemy_grid_pos:
            current_hero = null
            clear()
            var hero_tiles = map.get_hero_tiles()
            var enemy_tiles = map.get_enemy_tiles()
            var excluded_tiles = hero_tiles + enemy_tiles

            possible_movement.highlight_possible_movement(enemy_grid_pos, enemy.max_movement, excluded_tiles)
            attack_range.highlight_attack_range(enemy_tiles)
            possible_attack.highlight_possible_attack(hero_tiles)

            return


    current_hero = null
    clear()

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
