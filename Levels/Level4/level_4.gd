class_name Level4 extends Node2D

@onready var orphan: Unit = $Main/Units/Orphan
@onready var finn: Unit = $Main/Units/Fisherman
@onready var one_eye: Unit = $Main/Units/OneEye
@onready var fade: Fade = $Main/CanvasLayer/Fade

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Drums B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    orphan.start_text_list(["There are so many!"])
    await orphan.text_list_finished
    await get_tree().process_frame

    one_eye.start_text_list(["That's our only way out."])
    await one_eye.text_list_finished
    await get_tree().process_frame

    finn.start_text_list(["Then we fight!"])
    await finn.text_list_finished

    $Main.start_player_turn()

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level5/Level5.tscn")
