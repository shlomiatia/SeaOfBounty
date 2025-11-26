class_name Level12 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade
@onready var map: Map = $Main/Map

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Pirate stuff.mp3")
    MusicPlayer.play()
    

    main.start_player_turn()