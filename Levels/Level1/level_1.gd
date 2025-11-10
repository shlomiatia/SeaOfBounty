class_name Level1 extends Node2D

@onready var dialog: Dialog = $Main/Dialog
@onready var fade: Fade = $Main/CanvasLayer/Fade

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
    get_tree().change_scene_to_file("res://Levels/Main/main.tscn")
