class_name Level8 extends Node2D

@onready var main: Main = $Main
@onready var miguel: Unit = $Main/Units/Miguel
@onready var constantine: Unit = $Main/Units/Constantine
@onready var tutorial_event_handler: TutorialEventHandler8 = $TutorialEventHandler

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Flute B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    miguel.start_text_list(["Charge my friend!, charge!!!"])
    await miguel.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(["Pfff, sometimes the best strategy is to fall back."])
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)