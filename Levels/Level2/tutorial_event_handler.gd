class_name TutorialEventHandler extends ColorRect

@onready var tutorial: Node2D = $"../Tutorial"
@onready var typing_label: TypingLabel = $"../Tutorial/TypingLabel"
@onready var map: Map = $"../Main/Map"
@onready var main: Main = $"../Main"
@onready var tutorial_highlight: TileMapLayer = $"../TutorialHighlight"
@onready var tutorial_label: TypingLabel = $"../TutorialLabel"
@onready var battle_meter: BattleMeter = $"../Main/Battle/BattleMeter"
@onready var battle_label: Label = $"../Main/Battle/Label"

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

var attack_tutorial_done: bool = false
var defend_tutorial_done: bool = false
var current_battle_tutorial: String = ""

func _ready() -> void:
    main.player_turn_started.connect(on_player_turn_started)
    battle_meter.indicator_started.connect(on_battle_started)
    battle_meter.indicator_stopped.connect(on_indicator_stopped)

func _process(_delta: float) -> void:
    check_battle_meter_tutorial()

func _input(event: InputEvent) -> void:
    if !is_battle_input_allowed():
        get_viewport().set_input_as_handled()
        
    if not tutorial_active:
        return

    if event.is_action_pressed("cancel"):
        get_viewport().set_input_as_handled()

    if event.is_action_pressed("confirm"):
        var clicked_pos = main.cursor.position
        var clicked_cell = map.local_to_map(clicked_pos)

        if clicked_cell == tutorial_cells[tutorial_step]:
            tutorial_active = false
            tutorial_highlight.clear()

            if tutorial_step == 0:
                show_tutorial_at_step(1)
            elif tutorial_step == 1:
                tutorial.visible = false
                tutorial_label.text = ""
            elif tutorial_step == 2:
                show_tutorial_at_step(3)
            elif tutorial_step == 3:
                show_tutorial_at_step(4)
            elif tutorial_step == 4:
                tutorial.visible = false
                tutorial_label.text = ""
            elif tutorial_step == 5:
                show_tutorial_at_step(6)
            elif tutorial_step == 6:
                tutorial.visible = false
                tutorial_label.text = ""
            elif tutorial_step == 7:
                show_tutorial_at_step(8)
            elif tutorial_step == 8:
                show_tutorial_at_step(9)
            elif tutorial_step == 9:
                tutorial.visible = false
                tutorial_label.text = ""
        else:
            get_viewport().set_input_as_handled()
            typing_label.text = "Click me!"


func on_player_turn_started() -> void:
    if tutorial_step == 1:
        show_tutorial_at_step(2)
    elif tutorial_step == 4:
        show_tutorial_at_step(5)

func get_tutorial_text(step: int) -> String:
    match step:
        0:
            return "Move cursor with mouse / D-pad / WASD.\nSelect Kate with left mouse button / gamepad A / enter."
        1:
            return "Your movement range is in green, and attack range in red.\nSelect the enemy to attack it."
        2:
            return "Select the enemy to see it's range."
        3:
            return "Move Kate outside the enemy range."
        7:
            return "Select Finn."
        8:
            return "Finn has a ranged attack.\nMove Finn into range."
        9:
            return "Attack the enemy.\nIt's out of range and won't retaliate."
        _:
            return ""

func show_tutorial_at_step(step: int) -> void:
    tutorial_step = step
    var target_position = map.map_to_local(tutorial_cells[step])
    tutorial.position = target_position
    tutorial.visible = true
    tutorial_active = true
    typing_label.text = ""

    tutorial_highlight.clear()
    var map_rect = map.get_used_rect()
    for x in range(map_rect.position.x, map_rect.position.x + map_rect.size.x):
        for y in range(map_rect.position.y, map_rect.position.y + map_rect.size.y):
            var cell = Vector2i(x, y)
            if cell != tutorial_cells[step]:
                tutorial_highlight.set_cell(cell, 0, Vector2i(2, 0))

    tutorial_label.text = get_tutorial_text(step)

func on_battle_started(battle_mode: String) -> void:
    if battle_mode == "attack" && attack_tutorial_done || battle_mode == "defend" && defend_tutorial_done:
        return
    current_battle_tutorial = battle_mode
    battle_label.text = "Wait for the right moment..."

func is_battle_tutorial() -> bool:
    return current_battle_tutorial != ""

func check_battle_meter_tutorial() -> void:
    if !is_battle_tutorial():
        return

    if battle_meter.get_indicator_distance_from_center() <= 4:
        Engine.time_scale = 0.01
        if current_battle_tutorial == "attack":
            battle_label.text = "Press to attack now!"
        else:
            battle_label.text = "Press to defend now!"
    else:
        Engine.time_scale = 1
        battle_label.text = "Wait for the right moment..."

func is_battle_input_allowed() -> bool:
    if !is_battle_tutorial():
        return true
    return battle_meter.get_indicator_distance_from_center() <= 4

func on_indicator_stopped(_value: float) -> void:
    if current_battle_tutorial == "attack":
        attack_tutorial_done = true
    elif current_battle_tutorial == "defend":
        defend_tutorial_done = true

    tutorial_label.text = ""
    Engine.time_scale = 1
    current_battle_tutorial = ""
