class_name Level5 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
    await get_tree().create_timer(1.0).timeout
    start()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level6/Level6.tscn")

func start() -> void:
    stage = 1
    MusicPlayer.stream = preload("res://Music/Cello D.mp3")
    MusicPlayer.play()
    var array: Array[Array] = [
        ["Kate", "Ouch! It hurts!"],
        ["Finn", "We need a healer."],
        ["OneEye", "I know one, she's not far.\nFollow me."],
    ]
    dialog.start(array)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    if stage == 1:
        background.texture = preload("res://Textures/רקעים/Background6.png")
        stage += 1
        var array: Array[Array] = [
            ["", "<healing spell cast>"],
            ["Kate", "All better now! Thanks miss healer lady!"],
            ["Lia", "You're lucky you made it here.\nMonsters are going berserk everywhere."],
            ["Finn", "Then we're going north."],
            ["OneEye", "Are you insane?\nThat's where the monsters are from!"],
            ["Finn", "Exactly.\nSomething up north is resposible for this migration."],
            ["OneEye", "This is a terrible idea!\nBut the only one we have..."],
            ["Lia", "Then I suppose I'm coming too.\nSomeone has to keep you alive."],
        ]
        await fade.fade_in()
        dialog.start(array)
    elif stage == 2:
        get_tree().change_scene_to_file("res://Levels/Level6/Level6.tscn")
