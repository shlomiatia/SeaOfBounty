class_name Level9 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://Levels/Level10/Level10.tscn")

func start() -> void:
	stage = 1
	MusicPlayer.stream = preload("res://Music/piano D.mp3")
	MusicPlayer.play()
	var array: Array[Array] = [
		["", "The north."],
		["Miguel", "Whoa! Who are you milady?"],
		["Lia", "You're not monsters...\nGood. I had enough of those."],
		["Constantine", "Do you know why this place is vomiting horrors into the world?"],
		["Lia", "The monsters aren't attacking...\nThey're fleeing."],
		["Lia", "My group encountered this colossal beast...\nAn iceberg broke and created a tsunamy..."],
		["Lia", "We got separated.\nI don't know who made it."],
		["Constantine", "Lovely.\nCataclysmic wave, terrified monsters, missing expedition..."],
		["Miguel", "...and three gorgeous idiots marching straight into it."],
		["Lia", "It's up to us now.\nLet's hope this isn't the end."],
	]
	dialog.start(array)
	dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
	get_tree().change_scene_to_file("res://Levels/Level10/Level10.tscn")
