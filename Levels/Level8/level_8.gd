class_name Level8 extends Node2D

@onready var main: Main = $Main
@onready var miguel: Unit = $Main/Units/Miguel
@onready var constantine: Unit = $Main/Units/Constantine
@onready var tutorial_event_handler: TutorialEventHandler8 = $TutorialEventHandler
@onready var fade: Fade = $Main/CanvasLayer/Fade

func _ready() -> void:
    SaveManager.save_progress(8)
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/Flute B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    miguel.start_text_list(DialogData.level_8_miguel)
    await miguel.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(DialogData.level_8_constantine)
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level9/Level9.tscn")
