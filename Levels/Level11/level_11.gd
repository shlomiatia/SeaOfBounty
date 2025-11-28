class_name Level11 extends Node2D

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
    MusicPlayer.stream = preload("res://Music/Trumpet B.mp3")
    MusicPlayer.play()
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

    constantine.start_text_list(DialogData.level_11_constantine)
    await constantine.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(DialogData.level_11_lia)
    await lia.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(DialogData.level_11_miguel)
    await miguel.text_list_finished
    await get_tree().process_frame

    var one_eye_prefab = preload("res://Entities/Unit/Units/OneEye.tscn")
    one_eye = one_eye_prefab.instantiate()
    units_node.add_child(one_eye)

    one_eye.position = map.map_to_local(Vector2i(-1, 7))
    var one_eye_path: Array[Vector2i] = [Vector2i(-1, 7), Vector2i(0, 7)]
    await one_eye.animate_along_path(one_eye_path)

    one_eye.start_text_list(DialogData.level_11_one_eye_1)
    await one_eye.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(DialogData.level_11_lia_2)
    await lia.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(DialogData.level_11_miguel_2)
    await miguel.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(DialogData.level_11_constantine_2)
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()

func _process(_delta: float) -> void:
    if Input.is_action_pressed("confirm") && Input.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level12/Level12.tscn")

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level12/Level12.tscn")