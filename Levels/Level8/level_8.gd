class_name Level8 extends Node2D

func _ready() -> void:
    #MusicPlayer.stream = preload("res://Music/Level8Theme.mp3")
    #MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    $Main.start_player_turn()