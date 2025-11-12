class_name Level2 extends Node2D

@onready var orphan: Unit = $Main/Units/Orphan
@onready var tutorial: Node2D = $Tutorial

func _ready() -> void:
    MusicPlayer.stream = preload("res://Music/Pirate stuff slow.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout
    var array: Array[String] = [
        "I'll beat those monsters and win the bounty!",
        "Finn will be so proud..."
    ]
    orphan.start_text_list(array)
    orphan.text_list_finished.connect(on_text_list_finished)

func on_text_list_finished() -> void:
    $Main.start_player_turn()
