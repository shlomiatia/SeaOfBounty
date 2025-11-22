class_name Level10 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Piano B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    main.start_player_turn()