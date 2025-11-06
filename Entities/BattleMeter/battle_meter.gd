class_name BattleMeter extends Node2D

signal indicator_stopped(value: float)

@onready var indicator = $Indicator

var tween: Tween
var current_mode: String = "attack"

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("confirm"):
        if !tween:
            return
        stop()

func start(mode: String = "attack") -> void:
    current_mode = mode

    var start_pos = Vector2(0, -55)
    var end_pos = start_pos + Vector2(0, 110)

    var random_offset = randf() * 110
    indicator.position = start_pos + Vector2(0, random_offset)

    var go_up = randf() > 0.5
    var target_pos = end_pos if go_up else start_pos
    var distance = abs(target_pos.y - indicator.position.y)
    var initial_duration = distance / 110.0

    tween = create_tween()
    tween.tween_property(indicator, "position", target_pos, initial_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_callback(_start_looping_tween.bind(start_pos, end_pos, go_up))


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

    var center_pos = 0
    var current_pos = indicator.position.y
    var distance_from_center = abs(current_pos - center_pos)

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
            value = 1.0
        elif distance_from_center <= 15:
            value = 0.5
        elif distance_from_center <= 20:
            value = 0.25
        else:
            value = 0.0

    indicator_stopped.emit(value)
