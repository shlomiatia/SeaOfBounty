class_name Level13 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
    SaveManager.clear_save()
    await get_tree().create_timer(1.0).timeout
    start()

func start() -> void:
    MusicPlayer.stream = preload("res://Music/trumpet D.mp3")
    MusicPlayer.play()
    dialog.start(DialogData.level_13_ending)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    $Dialog.hide()
    var tween := create_tween()
    tween.tween_property($CanvasLayer/Label, "modulate:a", 1.0, 1.0)
