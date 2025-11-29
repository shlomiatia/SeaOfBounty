class_name Level6 extends Node2D

@onready var main: Main = $Main
@onready var kate: Unit = $Main/Units/Orphan
@onready var lia: Unit = $Main/Units/Lia
@onready var tutorial_event_handler: TutorialEventHandler6 = $TutorialEventHandler
@onready var fade: Fade = $Main/CanvasLayer/Fade

func _ready() -> void:
    SaveManager.save_progress(6)
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/Cello B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    kate.start_text_list(DialogData.level_6_kate)
    await kate.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(DialogData.level_6_lia)
    await lia.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)

func _process(_delta: float) -> void:
    if Input.is_action_pressed("confirm") && Input.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level7/Level7.tscn")

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level7/Level7.tscn")
