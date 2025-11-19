class_name Level6 extends Node2D

@onready var kate: Unit = $Main/Units/Orphan
@onready var lia: Unit = $Main/Units/Lia
@onready var tutorial_event_handler: TutorialEventHandler6 = $TutorialEventHandler

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Cello B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    kate.start_text_list(["That ugly fish spitted on me!"])
    await kate.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["I'll patch you up."])
    await lia.text_list_finished
    await get_tree().process_frame

    $Main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)
