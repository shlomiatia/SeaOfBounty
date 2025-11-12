class_name Level1 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
var stage := 0

func _input(event: InputEvent) -> void:
    if stage == 0 && event.is_action_pressed("confirm"):
        start()

func start() -> void:
    $CanvasLayer/Label.modulate = Color.TRANSPARENT
    stage = 1
    MusicPlayer.play()
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
        await fade.fade_in()
        dialog.start(array)
        
    elif stage == 2:
        stage += 1
        var array: Array[Array] = [
            ["", "The next morning...\nKate bed is empty"],
            ["Fisherman", "Not again..."],
        ]
        await fade.fade_in()
        dialog.start(array)
        
    elif stage == 3:
        get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")
