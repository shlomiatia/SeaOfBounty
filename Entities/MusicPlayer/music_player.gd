extends AudioStreamPlayer

func _ready():
    finished.connect(_on_finished)

func _on_finished():
    var path := stream.get_path()
    if path.ends_with("B.mp3"):
        stream = load("res://Music/Pirate stuff slow.mp3")
    elif path.ends_with("D.mp3"):
        stream = load("res://Music/pirate banjo menu.mp3")
    play()
