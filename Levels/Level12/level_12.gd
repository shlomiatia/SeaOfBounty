class_name Level12 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade
@onready var map: Map = $Main/Map
@onready var units_node: Node2D = $Main/Units
@onready var lia: Unit = $Main/Units/Lia
@onready var constantine: Unit = $Main/Units/Constantine
@onready var miguel: Unit = $Main/Units/Miguel
@onready var one_eye: Unit = $Main/Units/OneEye
@onready var sea_horse_head: Unit = $Main/Units/SeaHorseHead
@onready var sea_horse_body: Unit = $Main/Units/SeaHorseBody
@onready var sea_horse_tail: Unit = $Main/Units/SeaHorseTail
@onready var orphan: Unit = $Main/Units/Orphan
@onready var fisherman: Unit = $Main/Units/Fisherman

func _on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level13/Level13.tscn")

func _process(_delta: float) -> void:
    if Input.is_action_pressed("confirm") && Input.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level13/Level13.tscn")

func _ready() -> void:
    main.won.connect(_on_won)
    MusicPlayer.stream = preload("res://Music/Pirate stuff.mp3")
    MusicPlayer.play()

    var head_path: Array[Vector2i] = [Vector2i(16, 6), Vector2i(15, 6), Vector2i(14, 6), Vector2i(13, 6)]
    var body_path: Array[Vector2i] = [Vector2i(17, 6), Vector2i(16, 6), Vector2i(15, 6), Vector2i(14, 6)]
    var tail_path: Array[Vector2i] = [Vector2i(18, 6), Vector2i(17, 6), Vector2i(16, 6), Vector2i(15, 6)]

    sea_horse_head.animate_along_path(head_path)
    sea_horse_body.animate_along_path(body_path)
    await sea_horse_tail.animate_along_path(tail_path)

    constantine.start_text_list(["This is the one?"])
    await constantine.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["This is it."])
    await lia.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(["We are going to die."])
    await constantine.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(["At least we'll die together!"])
    await miguel.text_list_finished
    await get_tree().process_frame

    var orphan_path: Array[Vector2i] = [Vector2i(1, 10), Vector2i(1, 9), Vector2i(1, 8), Vector2i(1, 7)]
    var fisherman_path: Array[Vector2i] = [Vector2i(0, 10), Vector2i(0, 9), Vector2i(0, 8), Vector2i(0, 7)]

    orphan.animate_along_path(orphan_path)
    await fisherman.animate_along_path(fisherman_path)

    orphan.start_text_list(["You guys wanted to die without us??"])
    await orphan.text_list_finished
    await get_tree().process_frame

    one_eye.start_text_list(["Kate! Finn! You made it!"])
    await one_eye.text_list_finished
    await get_tree().process_frame

    fisherman.start_text_list(["Just in time for the last battle. Ready?"])
    await fisherman.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["Yes!"])
    constantine.start_text_list(["Yes!"])
    miguel.start_text_list(["Yes!"])
    one_eye.start_text_list(["Yes!"])
    orphan.start_text_list(["Yes!"])
    await orphan.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()