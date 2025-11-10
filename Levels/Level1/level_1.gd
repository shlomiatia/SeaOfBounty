class_name Level1 extends Node2D

@onready var dialog: Dialog = $Main/Dialog
@onready var fade: Fade = $Main/CanvasLayer/Fade
var stage := 1

func _ready() -> void:
    var array: Array[Array] = [
        ["", "Somwhere in the ocean..."],
        ["Orphan", "Caught anything yet?"],
        ["Fisherman", "The sea is silent.\nSomething is scaring the fish..."],
        ["Orphan", "Whoo, Monsters?!"],
        ["Fisherman", "Yes. The island folk sent word."],
        ["Orphan", "Can we go, please??"],
        ["Fisherman", "<sigh> We're going..."],
    ]
    dialog.start(array)

    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    await fade.fade_out()
    if stage == 1:
        stage += 1
        var array: Array[Array] = [
            ["OneEye", "Took you long enough, old man."],
            ["Fisherman", "Didn't know this job was taken."],
            ["OneEye", "It isn't. Just don't expect me to share."],
            ["Orphan", "So… whoever kills them first??"],
            ["OneEye", "You got spirit kid...\nThat's fair."],
            ["Fisherman", "We hunt at first light.\nGet some rest."],
        ]
        dialog.start(array)
        await fade.fade_in()
    elif stage == 2:
        stage += 1
        var array: Array[Array] = [
            ["", "The next morning...\nKate bed is empty"],
            ["Fisherman", "Not again..."],
        ]
        dialog.start(array)
        await fade.fade_in()
    elif stage == 3:
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")
