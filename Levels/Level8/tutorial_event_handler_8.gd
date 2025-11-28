class_name TutorialEventHandler8 extends ColorRect

@onready var tutorial: Node2D = $"../Tutorial"
@onready var typing_label: TypingLabel = $"../Tutorial/TypingLabel"
@onready var map: Map = $"../Main/Map"
@onready var main: Main = $"../Main"
@onready var tutorial_highlight: TileMapLayer = $"../TutorialHighlight"
@onready var tutorial_label: TypingLabel = $"../TutorialLabel"

var tutorial_active: bool = false
var tutorial_step: int = 0
var tutorial_cells: Array[Vector2i] = [
    Vector2i(0, 0),
]

func _input(event: InputEvent) -> void:
    if not tutorial_active:
        return

    if event.is_action_pressed("cancel"):
        get_viewport().set_input_as_handled()

    if tutorial_step == 0:
        if event.is_action_pressed("skip"):
            get_viewport().set_input_as_handled()
        if event.is_action_pressed("confirm"):
            var clicked_pos = main.cursor.position
            var clicked_cell = map.local_to_map(clicked_pos)

            if clicked_cell == tutorial_cells[tutorial_step]:
                tutorial_active = false
                tutorial_highlight.clear()
                show_tutorial_at_step(1)
            else:
                get_viewport().set_input_as_handled()
                typing_label.text = DialogData.tutorial_click_me
    elif tutorial_step == 1:
        if event.is_action_pressed("confirm"):
            get_viewport().set_input_as_handled()
        if event.is_action_pressed("skip"):
            tutorial_active = false
            tutorial_highlight.clear()
            tutorial.visible = false
            tutorial_label.text = ""

func get_tutorial_text(step: int) -> String:
    var text = DialogData.get_tutorial_level8_text(step)
    if step == 1:
        return text % [LastInput.get_text("Middle mouse button", "Backspace", "Y button")]
    return text

func show_tutorial_at_step(step: int) -> void:
    tutorial_step = step

    if step == 0:
        var target_position = map.map_to_local(tutorial_cells[step])
        tutorial.position = target_position
        tutorial.visible = true
        tutorial_active = true
        typing_label.text = ""

        set_tutorial_highlight(tutorial_cells[step])
    elif step == 1:
        tutorial.visible = false
        tutorial_active = true
        set_tutorial_highlight(Vector2i.MIN)

    tutorial_label.text = get_tutorial_text(step)

func set_tutorial_highlight(cell_to_highlight: Vector2i) -> void:
    tutorial_highlight.clear()
    var map_rect = map.get_used_rect()
    for x in range(map_rect.position.x, map_rect.position.x + map_rect.size.x):
        for y in range(map_rect.position.y, map_rect.position.y + map_rect.size.y):
            var cell = Vector2i(x, y)
            if cell != cell_to_highlight:
                tutorial_highlight.set_cell(cell, 0, Vector2i(2, 0))
