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

func _ready() -> void:
    SaveManager.save_progress(12)
    main.won.connect(_on_won)
    MusicPlayer.stream = preload("res://Music/Pirate stuff.mp3")
    MusicPlayer.play()

    var head_path: Array[Vector2i] = [Vector2i(16, 6), Vector2i(15, 6), Vector2i(14, 6), Vector2i(13, 6)]
    var body_path: Array[Vector2i] = [Vector2i(17, 6), Vector2i(16, 6), Vector2i(15, 6), Vector2i(14, 6)]
    var tail_path: Array[Vector2i] = [Vector2i(18, 6), Vector2i(17, 6), Vector2i(16, 6), Vector2i(15, 6)]

    sea_horse_head.animate_along_path(head_path)
    sea_horse_body.animate_along_path(body_path)
    await sea_horse_tail.animate_along_path(tail_path)

    constantine.start_text_list(DialogData.level_12_constantine_1)
    await constantine.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(DialogData.level_12_lia_1)
    await lia.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(DialogData.level_12_constantine_2)
    await constantine.text_list_finished
    await get_tree().process_frame

    miguel.start_text_list(DialogData.level_12_miguel)
    await miguel.text_list_finished
    await get_tree().process_frame

    var orphan_path: Array[Vector2i] = [Vector2i(1, 10), Vector2i(1, 9), Vector2i(1, 8), Vector2i(1, 7)]
    var fisherman_path: Array[Vector2i] = [Vector2i(0, 10), Vector2i(0, 9), Vector2i(0, 8), Vector2i(0, 7)]

    orphan.animate_along_path(orphan_path)
    await fisherman.animate_along_path(fisherman_path)

    orphan.start_text_list(DialogData.level_12_orphan_1)
    await orphan.text_list_finished
    await get_tree().process_frame

    one_eye.start_text_list(DialogData.level_12_one_eye)
    await one_eye.text_list_finished
    await get_tree().process_frame

    fisherman.start_text_list(DialogData.level_12_fisherman)
    await fisherman.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(DialogData.level_12_lia_2)
    constantine.start_text_list(DialogData.level_12_constantine_3)
    miguel.start_text_list(DialogData.level_12_miguel_2)
    one_eye.start_text_list(DialogData.level_12_one_eye_2)
    orphan.start_text_list(DialogData.level_12_orphan_2)
    await orphan.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()