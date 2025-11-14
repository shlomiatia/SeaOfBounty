class_name BattleMeter extends Node2D

signal indicator_stopped(value: float)

@onready var indicator = $Indicator
@onready var label = $"../Label"

var tween: Tween
var current_mode: String = "attack"
var attack_tutorial_done: bool = false
var defend_tutorial_done: bool = false

func _process(_delta: float) -> void:
    if is_tutorial():
        if get_indicator_distance_from_center() <= 4 && tween:
            Engine.time_scale = 0.01
            if current_mode == "attack":
                label.text = "Press to attack now!"
            else:
                label.text = "Press to defend now!"
        else:
            Engine.time_scale = 1
            label.text = "Wait for the right moment..."

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("confirm"):
        if !tween:
            return
        stop()

func start(mode: String = "attack") -> void:
    current_mode = mode

    var start_pos = Vector2(0, -55)
    var end_pos = start_pos + Vector2(0, 110)

    var random_offset := randf() * 110
    var go_down := randf() > 0.5

    if is_tutorial():
        random_offset = 50
        go_down = false

    indicator.position = start_pos + Vector2(0, random_offset)
    var target_pos = end_pos if go_down else start_pos
    var distance = abs(target_pos.y - indicator.position.y)
    var initial_duration = distance / 110.0

    tween = create_tween()
    tween.tween_property(indicator, "position", target_pos, initial_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    tween.tween_callback(_start_looping_tween.bind(start_pos, end_pos, go_down))


func _start_looping_tween(start_pos: Vector2, end_pos: Vector2, went_up: bool) -> void:
    tween = create_tween()
    tween.set_loops()
    if went_up:
        tween.tween_property(indicator, "position", start_pos, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
        tween.tween_property(indicator, "position", end_pos, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    else:
        tween.tween_property(indicator, "position", end_pos, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
        tween.tween_property(indicator, "position", start_pos, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)


func stop() -> void:
    if tween:
        tween.kill()
    tween = null
    Engine.time_scale = 1

    var distance_from_center = get_indicator_distance_from_center()

    if current_mode == "attack":
        attack_tutorial_done = true
    else:
        defend_tutorial_done = true

    var value := 0.0
    if current_mode == "attack":
        if distance_from_center <= 4:
            value = 1.5
        elif distance_from_center <= 15:
            value = 1.0
        elif distance_from_center <= 20:
            value = 0.5
        else:
            value = 0.0
    else:
        if distance_from_center <= 4:
            value = 0.25
        elif distance_from_center <= 15:
            value = 0.5
        elif distance_from_center <= 20:
            value = 0.75
        else:
            value = 1.0

    indicator_stopped.emit(value)

func is_tutorial() -> bool:
    return (current_mode == "attack" and !attack_tutorial_done) or (current_mode == "defend" and !defend_tutorial_done)

func get_indicator_distance_from_center() -> int:
    var center_pos = 0
    var current_pos = indicator.position.y
    return abs(current_pos - center_pos)