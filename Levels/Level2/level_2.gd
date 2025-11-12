class_name Level2 extends Node2D

func _ready() -> void:
    $Main.start_player_turn()
    MusicPlayer.stream = preload("res://Music/Pirate stuff slow.mp3")
    MusicPlayer.play()
