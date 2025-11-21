extends AudioStreamPlayer

func _ready():
	finished.connect(_on_finished)

func _on_finished():
	stream = load("res://Music/Pirate stuff slow.mp3")
	play()
