extends AudioStreamPlayer

func _ready():
    finished.connect(_on_finished)

func _on_finished():
    if stream.get_path() != "res://Music/Pirate stuff.mp3":
        stream = load("res://Music/Pirate stuff slow.mp3")
    play()
