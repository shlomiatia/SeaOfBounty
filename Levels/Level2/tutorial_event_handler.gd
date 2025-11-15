class_name TutorialEventHandler extends ColorRect

@onready var tutorial: Node2D = $"../Tutorial"
@onready var typing_label: TypingLabel = $"../Tutorial/TypingLabel"
@onready var map: Map = $"../Main/Map"
@onready var main: Main = $"../Main"
@onready var tutorial_highlight: TileMapLayer = $"../TutorialHighlight"
@onready var tutorial_label: TypingLabel = $"../TutorialLabel"

var tutorial_active: bool = false
var tutorial_step: int = 0
var tutorial_cells: Array[Vector2i] = [
    Vector2i(0, 4),
    Vector2i(6, 4),
    Vector2i(11, 0),
    Vector2i(5, 4),
    Vector2i(7, 2),
    Vector2i(7, 2),
    Vector2i(7, 0),
    Vector2i(0, 4),
    Vector2i(2, 2),
    Vector2i(2, 0)
]


func _ready() -> void:
    main.player_turn_started.connect(on_player_turn_started)

func _input(event: InputEvent) -> void:
    if not tutorial_active:
        return

    if event.is_action_pressed("cancel"):
        get_viewport().set_input_as_handled()

    if event.is_action_pressed("confirm"):
        var clicked_pos = main.cursor.position
        var clicked_cell = map.local_to_map(clicked_pos)

        if clicked_cell == tutorial_cells[tutorial_step]:
            tutorial_active = false

            if tutorial_step == 0:
                show_tutorial_at_step(1)
            elif tutorial_step == 1:
                tutorial.visible = false
            elif tutorial_step == 2:
                show_tutorial_at_step(3)
            elif tutorial_step == 3:
                show_tutorial_at_step(4)
            elif tutorial_step == 4:
                tutorial.visible = false
            elif tutorial_step == 5:
                show_tutorial_at_step(6)
            elif tutorial_step == 6:
                tutorial.visible = false
            elif tutorial_step == 7:
                show_tutorial_at_step(8)
            elif tutorial_step == 8:
                show_tutorial_at_step(9)
            elif tutorial_step == 9:
                tutorial.visible = false
        else:
            get_viewport().set_input_as_handled()
            typing_label.text = "Click me!"


func on_player_turn_started() -> void:
    if tutorial_step == 1:
        show_tutorial_at_step(2)
    elif tutorial_step == 4:
        show_tutorial_at_step(5)

func show_tutorial_at_step(step: int) -> void:
    tutorial_step = step
    var target_position = map.map_to_local(tutorial_cells[step])
    tutorial.position = target_position
    tutorial.visible = true
    tutorial_active = true
    typing_label.text = ""
