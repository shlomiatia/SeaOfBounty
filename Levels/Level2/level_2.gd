class_name Level2 extends Node2D

@onready var main: Main = $Main
@onready var tutorial_event_handler: TutorialEventHandler = $TutorialEventHandler
@onready var orphan: Unit = $Main/Units/Orphan

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/violin B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout
    var array: Array[String] = [
        "I'll beat those monsters and win the bounty!",
        "Finn will be so proud..."
    ]

    orphan.start_text_list(array)
    orphan.text_list_finished.connect(on_text_list_finished)

func on_text_list_finished() -> void:
    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)
