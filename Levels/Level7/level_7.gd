class_name Level7 extends Node2D

@onready var dialog: Dialog = $Dialog
@onready var fade: Fade = $CanvasLayer/Fade
@onready var background: Sprite2D = $Background
var stage := 0

func _ready() -> void:
    await get_tree().create_timer(1.0).timeout
    start()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel"):
        get_tree().change_scene_to_file("res://Levels/Level8/Level8.tscn")

func start() -> void:
    stage = 1
    MusicPlayer.stream = preload("res://Music/Flute D.mp3")
    MusicPlayer.play()
    var array: Array[Array] = [
        ["", "Somewhere else, not far..."],
        ["Constantine", "Disgusting creatures… I scorch five, and ten more crawl out!"],
        ["Miguel", "Ah, but you handle it with such elegance..."],
        ["Constantine", "Don't flatter me while I'm irritated!"],
        ["Miguel", "That mean you'll never get compliments, and that won't do."],
        ["Constantine", "<sigh> They're coming from the north, it's obvious now."],
        ["Miguel", "Than that's our destination."],
        ["Constantine", "It's not our problem!"],
        ["Miguel", "Would you rather burn the source or the leftovers?"],
        ["Constantine", "...Let's go."],
    ]
    dialog.start(array)
    dialog.dialog_finished.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
    get_tree().change_scene_to_file("res://Levels/Level8/Level8.tscn")
