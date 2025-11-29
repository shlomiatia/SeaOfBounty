class_name Level4 extends Node2D

@onready var main: Main = $Main
@onready var orphan: Unit = $Main/Units/Orphan
@onready var finn: Unit = $Main/Units/Fisherman
@onready var one_eye: Unit = $Main/Units/OneEye
@onready var fade: Fade = $Main/CanvasLayer/Fade

func _ready() -> void:
    SaveManager.save_progress(4)
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/Drums B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    finn.start_text_list(DialogData.level_4_finn)
    await finn.text_list_finished
    await get_tree().process_frame

    one_eye.start_text_list(DialogData.level_4_one_eye)
    await one_eye.text_list_finished
    await get_tree().process_frame

    orphan.start_text_list(DialogData.level_4_orphan)
    await orphan.text_list_finished
    await get_tree().process_frame


    main.start_player_turn()

func _process(_delta: float) -> void:
    if Input.is_action_pressed("confirm") && Input.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level5/Level5.tscn")

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level5/Level5.tscn")
