class_name Level3 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
    await get_tree().create_timer(1.0).timeout
    start()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level4/Level4.tscn")
    
func start() -> void:
    stage = 1
    MusicPlayer.stream = preload("res://Music/Drums D.mp3")
    MusicPlayer.play()
    dialog.start(DialogData.level_3_intro)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    background.texture = preload("res://Textures/רקעים/Background3.png")
    if stage == 1:
        stage += 1
        await fade.fade_in()
        dialog.start(DialogData.level_3_stage_2)

    elif stage == 2:
        get_tree().change_scene_to_file("res://Levels/Level4/Level4.tscn")
