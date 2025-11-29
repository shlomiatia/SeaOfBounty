class_name Level13 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
	SaveManager.save_progress(13)
	await get_tree().create_timer(1.0).timeout
	start()

func start() -> void:
	stage = 1
	MusicPlayer.stream = preload("res://Music/trumpet D.mp3")
	MusicPlayer.play()
	dialog.start(DialogData.level_13_ending)
