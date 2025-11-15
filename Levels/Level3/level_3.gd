class_name Level3 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
var stage := 0

func _ready() -> void:
    await get_tree().create_timer(1.0).timeout
    start()
    
func start() -> void:
    stage = 1
    MusicPlayer.stream = preload("res://Music/Drums D.mp3")
    MusicPlayer.play()
    var array: Array[Array] = [
        ["Kate", "I'm sorry, Finn… \nI wanted to prove I'm strong too…"],
        ["Finn", "You already are."],
        ["Kate", "I hope you're right…\nI'll need to carry so much gold!"],
        ["Finn", "<shakes head> Let's go collect it."],
    ]
    dialog.start(array)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    if stage == 1:
        stage += 1
        var array: Array[Array] = [
            ["Kate", "Where is everybody?!"],
            ["OneEye", "That's a good question."],
            ["Kate", "What are you doing here, lady?! \nStealing our bounty??"],
            ["OneEye", "I dealt with the monsters first."],
            ["Finn", "We also slayed monsters… \nAnd the village is still empty?"],
            ["OneEye", "We need to get out of here."],
            ["Finn", "Agreed. Let's stick together."],
            ["Kate", "With her?! <frown>"],
        ]
        await fade.fade_in()
        dialog.start(array)

    elif stage == 2:
        get_tree().change_scene_to_file("res://Levels/Level4/Level4.tscn")