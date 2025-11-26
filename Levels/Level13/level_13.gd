class_name Level13 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	start()

func start() -> void:
	stage = 1
	MusicPlayer.stream = preload("res://Music/piano D.mp3")
	MusicPlayer.play()
	var array: Array[Array] = [
		["Lia", "I think we did it. The poor monsters seem to return north."],
		["Constantine", "Poor monsters.. Bah! What we did is triumph!"],
		["Miguel", "We did both my friend., thanks to our lovely companions."],
		["OneEye", "I usually fight solo, but teaming up is not too bad..."],
		["Kate", "Finn! Can we bash heads with the pirate lady, please??"],
		["Finn", "<sigh>You're friends now? Sure, we can return home together."],
	]
	dialog.start(array)
