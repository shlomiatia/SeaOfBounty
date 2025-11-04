class_name BattleMeter extends Node2D

signal indicator_stopped(value: float)

@onready var indicator = $Indicator

var tween: Tween
var current_mode: String = "attack"

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if !tween:
            return
        stop()

func start(mode: String = "attack") -> void:
    current_mode = mode

    var start_pos = Vector2(0, -55)
    indicator.position = start_pos
    var end_pos = start_pos + Vector2(0, 110)

    tween = create_tween()
    tween.set_loops()
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
