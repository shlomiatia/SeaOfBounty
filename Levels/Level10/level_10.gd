class_name Level10 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade
@onready var miguel: Unit = $Main/Units/Miguel
@onready var lia: Unit = $Main/Units/Lia
@onready var constantine: Unit = $Main/Units/Constantine
@onready var units_node: Node2D = $Main/Units
@onready var map: Map = $Main/Map

var won_triggered: bool = false
var kraken: Unit
var one_eye: Unit

func _ready() -> void:
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/piano B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    miguel.start_text_list(["An ambush!"])
    await miguel.text_list_finished
    await get_tree().process_frame

    lia.start_text_list(["They want to flee, we're just in the way."])
    await lia.text_list_finished
    await get_tree().process_frame

    constantine.start_text_list(["Bad luck for them!"])
    await constantine.text_list_finished
    await get_tree().process_frame

    main.start_player_turn()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("confirm") && Input.is_action_just_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level11/Level11.tscn")

func on_won() -> void:
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Levels/Level11/Level11.tscn")