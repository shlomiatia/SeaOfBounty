class_name Level1 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _input(event: InputEvent) -> void:
    if stage == 0 && (event.is_action_pressed("confirm") || event.is_action_pressed("cancel")):
        dialog.show()
        start()
    elif stage > 0 && event.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")

func start() -> void:
    $CanvasLayer/Label.modulate = Color.TRANSPARENT
    stage = 1
    MusicPlayer.play()
    var array: Array[Array] = [
        ["", "Somwhere in the ocean..."],
        ["Kate", "Caught anything yet?"],
        ["Finn", "The sea is silent.\nSomething is scaring the fish..."],
        ["Kate", "Whoo, Monsters?!"],
        ["Finn", "Yes. The island folk sent word."],
        ["Kate", "Can we go, please??"],
        ["Finn", "<sigh> We're going..."],
    ]
    dialog.start(array)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    if stage == 1:
        background.texture = preload("res://Textures/רקעים/Background4.png")
        stage += 1
        var array: Array[Array] = [
            ["OneEye", "Took you long enough, old man."],
            ["Finn", "Didn't know this job was taken."],
            ["OneEye", "It isn't. Just don't expect me to share."],
            ["Kate", "So… whoever kills them first??"],
            ["OneEye", "You got spirit kid...\nThat's fair."],
            ["Finn", "We hunt at first light.\nGet some rest."],
        ]
        await fade.fade_in()
        dialog.start(array)
        
    elif stage == 2:
        background.texture = preload("res://Textures/רקעים/Background2.png")
        stage += 1
        var array: Array[Array] = [
            ["", "The next morning...\nKate bed is empty."],
            ["Finn", "Not again..."],
        ]
        await fade.fade_in()
        dialog.start(array)
        
    elif stage == 3:
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")
