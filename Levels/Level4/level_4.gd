class_name Level4 extends Node2D

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Drums B.mp3")
    MusicPlayer.play()
    $Main.start_player_turn()