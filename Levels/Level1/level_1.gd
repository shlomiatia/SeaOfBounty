class_name Level1 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
    if SaveManager.has_save():
        var saved_level = SaveManager.load_progress()
        if saved_level > 1:
            get_tree().change_scene_to_file(SaveManager.get_level_path(saved_level))
            return

    SaveManager.save_progress(1)

func _input(event: InputEvent) -> void:
    if stage == 0 && (event.is_action_pressed("confirm") || event.is_action_pressed("cancel")):
        dialog.show()
        start()
    elif stage > 0 && event.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")

func start() -> void:
    $CanvasLayer/Label.modulate = Color.TRANSPARENT
    $CanvasLayer/Label2.modulate = Color.TRANSPARENT
    stage = 1
    MusicPlayer.play()
    dialog.start(DialogData.level_1_intro)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    if stage == 1:
        background.texture = preload("res://Textures/רקעים/Background4.png")
        stage += 1
        await fade.fade_in()
        dialog.start(DialogData.level_1_stage_2)

    elif stage == 2:
        background.texture = preload("res://Textures/רקעים/Background2.png")
        stage += 1
        await fade.fade_in()
        dialog.start(DialogData.level_1_stage_3)

    elif stage == 3:
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")
