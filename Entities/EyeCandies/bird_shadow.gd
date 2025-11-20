class_name BirdShadow extends AnimatedSprite2D

@export var min_time: float = 0.0
@export var max_time: float = 0.0
@export var min_speed: float = 80.0
@export var max_speed: float = 220.0
@export var min_x_offset: float = 100.0
@export var max_x_offset: float = 200.0
@export var min_y_offset: float = 100.0
@export var max_y_offset: float = 360.0

var _bird_child: AnimatedSprite2D = null
var _active: bool = false
var _velocity: Vector2 = Vector2.ZERO
var _end_x: float = 0.0

func _ready() -> void:
    randomize()
    if has_node("Bird"):
        _bird_child = get_node("Bird")
    visible = false
    set_process(true)
    _schedule_next_spawn()

func _process(delta: float) -> void:
    if not _active:
        return
    position += _velocity * delta
    if _velocity.x > 0 and position.x > _end_x:
        _deactivate_and_reschedule()
    elif _velocity.x < 0 and position.x < _end_x:
        _deactivate_and_reschedule()

func _schedule_next_spawn() -> void:
    var t = randf_range(min_time, max_time)
    get_tree().create_timer(t).connect("timeout", Callable(self, "_on_spawn_timer_timeout"))

func _on_spawn_timer_timeout() -> void:
    _start()

func _start() -> void:
    var rect = get_viewport().get_visible_rect()
    var w = rect.size.x
    var h = rect.size.y
    var edge = randi() % 2
    var dir = Vector2.ZERO
    var start_pos = Vector2.ZERO
    var margin = 48

    if edge == 0:
        dir = Vector2(1, 0)
        start_pos.x = - margin
        start_pos.y = randf_range(0, h)
        _end_x = w * 2 + margin
    else:
        dir = Vector2(-1, 0)
        start_pos.x = w + margin
        start_pos.y = randf_range(0, h)
        _end_x = -w - margin

    var speed = randf_range(min_speed, max_speed)
    _velocity = dir * speed

    position = start_pos
    visible = true


    var x_offset = randf_range(min_x_offset, max_x_offset)
    var y_offset = randf_range(min_y_offset, max_y_offset)
    if _velocity.x > 0:
        flip_h = true
        _bird_child.flip_h = true
        _bird_child.position = Vector2(x_offset, -y_offset)
        position.x -= x_offset
    else:
        flip_h = false
        _bird_child.flip_h = false
        # Bird is in front (negative offset), shadow moves backward to keep bird off-screen
        _bird_child.position = Vector2(-x_offset, -y_offset)
        position.x += x_offset

    _active = true

func _deactivate_and_reschedule() -> void:
    visible = false
    _active = false
    _velocity = Vector2.ZERO
    _schedule_next_spawn()
