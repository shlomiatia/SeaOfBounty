class_name Level10 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade
@onready var miguel: Unit = $Main/Units/Miguel
@onready var lia: Unit = $Main/Units/Lia
@onready var constantine: Unit = $Main/Units/Constantine
@onready var units_node: Node2D = $Main/Units
@onready var map: Map = $Main/Map

var won_triggered: bool = false
var kraken: Unit
var one_eye: Unit

func _ready() -> void:
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/Piano B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    miguel.start_text_list(["An ambush!"])
    await miguel.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["They want to flee, we're just in the way."])
    await lia.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(["Bad luck for them!"])
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("confirm") && Input.is_action_just_pressed("cancel"):
        for enemy in get_tree().get_nodes_in_group("enemies"):
            enemy.queue_free()
        await get_tree().process_frame
        main.start_enemy_turn_if_needed()

func on_won() -> void:
    for hero: Unit in get_tree().get_nodes_in_group("heroes"):
        hero.hp = hero.max_hp
    if won_triggered:
        return
    won_triggered = true

    var kraken_prefab = preload("res://Entities/Unit/Units/Kraken.tscn")
    kraken = kraken_prefab.instantiate()
    units_node.add_child(kraken)

    kraken.position = map.map_to_local(Vector2i(17, 7))

    var kraken_path: Array[Vector2i] = [Vector2i(17, 7), Vector2i(16, 7), Vector2i(15, 7), Vector2i(14, 7)]
    await kraken.animate_along_path(kraken_path)

    var tentacle_prefab = preload("res://Entities/Unit/Units/Tentacle.tscn")
    var tentacle_positions: Array[Vector2i] = [
        Vector2i(13, 6), # top-left
        Vector2i(14, 6), # top
        Vector2i(15, 6), # top-right
        Vector2i(13, 7), # left
        Vector2i(15, 7), # right
        Vector2i(13, 8), # bottom-left
        Vector2i(14, 8), # bottom
        Vector2i(15, 8) # bottom-right
    ]

    var tentacles: Array[Unit] = []
    for pos in tentacle_positions:
        var tentacle: Unit = tentacle_prefab.instantiate()
        units_node.add_child(tentacle)
        tentacle.position = map.map_to_local(pos)
        tentacles.append(tentacle)

    for tentacle in tentacles:
        var tentacle_sprite: AnimatedSprite2D = tentacle.get_node("AnimatedSprite2D")
        tentacle_sprite.play("emerge")

    await get_tree().create_timer(0.5).timeout

    constantine.start_text_list(["Your collosal beast! I imagined it will be bigger..."])
    await constantine.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["It's not the one we encountered.", "I think it's running away too..."])
    await lia.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(["What can scare such a terrible behemoth..."])
    await miguel.text_list_finished
    await get_tree().process_frame

    var one_eye_prefab = preload("res://Entities/Unit/Units/OneEye.tscn")
    one_eye = one_eye_prefab.instantiate()
    units_node.add_child(one_eye)

    var target_y: int = 4
    for y in range(4, 9):
        var check_pos = Vector2i(0, y)
        var is_free = true
        for unit in units_node.get_children():
            if unit is Unit:
                var unit_grid_pos = map.local_to_map(unit.position)
                if unit_grid_pos == check_pos:
                    is_free = false
                    break
        if is_free:
            target_y = y
            break

    one_eye.position = map.map_to_local(Vector2i(-1, target_y))

    var one_eye_path: Array[Vector2i] = [Vector2i(-1, target_y), Vector2i(0, target_y)]
    await one_eye.animate_along_path(one_eye_path)

    one_eye.start_text_list(["It will soon run away from me!"])
    await one_eye.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["One Eye, you're alive!"])
    await lia.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(["This magnificant warrior is with you?"])
    await miguel.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(["Good, that should be enough, attack!"])
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()