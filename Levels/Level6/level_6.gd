class_name Level6 extends Node2D

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Cello B.mp3")
    MusicPlayer.play()
    $Main.start_player_turn()