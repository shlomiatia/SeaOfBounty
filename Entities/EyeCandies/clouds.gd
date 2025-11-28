class_name Clouds extends Node2D

@export var min_time: float = 10.0
@export var max_time: float = 20.0
@export var min_speed: float = 5.0
@export var max_speed: float = 15.0
@export var min_clouds_per_spawn: int = 1
@export var max_clouds_per_spawn: int = 3
@export var min_alpha: float = 0.01
@export var max_alpha: float = 0.1

var cloud_textures: Array[Texture2D] = []
var active_clouds: Array[Dictionary] = []
var first_spawn: bool = true

func _ready() -> void:
    for i in range(1, 6):
        var texture_path = "res://Textures/קישוטים/clouds%d.png" % i
        var texture = load(texture_path) as Texture2D
        if texture:
            cloud_textures.append(texture)

    set_process(true)
    _spawn_initial_clouds()
    _schedule_next_spawn()

func _process(delta: float) -> void:
    for i in range(active_clouds.size() - 1, -1, -1):
        var cloud = active_clouds[i]
        var sprite = cloud.sprite as Sprite2D
        sprite.position += cloud.velocity * delta

        if cloud.velocity.x > 0 and sprite.position.x > cloud.end_x:
            sprite.queue_free()
            active_clouds.remove_at(i)
        elif cloud.velocity.x < 0 and sprite.position.x < cloud.end_x:
            sprite.queue_free()
            active_clouds.remove_at(i)

func _schedule_next_spawn() -> void:
    var t = randf_range(min_time, max_time)
    get_tree().create_timer(t).connect("timeout", Callable(self, "_on_spawn_timer_timeout"))

func _on_spawn_timer_timeout() -> void:
    _spawn_clouds()
    _schedule_next_spawn()

func _spawn_clouds() -> void:
    if cloud_textures.size() == 0:
        return

    var num_clouds = randi_range(min_clouds_per_spawn, max_clouds_per_spawn)

    for i in range(num_clouds):
        _spawn_single_cloud()


func _spawn_initial_clouds() -> void:
    if cloud_textures.size() == 0:
        return

    var num_clouds = randi_range(min_clouds_per_spawn, max_clouds_per_spawn)

    for i in range(num_clouds):
        _spawn_single_cloud(true)

func _spawn_single_cloud(initial: bool = false) -> void:
    var margin := 300
    var rect = get_viewport().get_visible_rect()
    var w = rect.size.x
    var h = rect.size.y

    var edge = randi() % 2
    var dir = Vector2.ZERO
    var start_pos = Vector2.ZERO
    var end_x = 0.0

    if edge == 0:
        dir = Vector2(1, 0)
        start_pos.x = - margin
        end_x = w + margin
    else:
        dir = Vector2(-1, 0)
        start_pos.x = w + margin
        end_x = - margin

    if initial:
        start_pos.x = randf_range(0, w)
    start_pos.y = randf_range(0, h)
    

    var speed = randf_range(min_speed, max_speed)
    var velocity = dir * speed

    var sprite = Sprite2D.new()
    sprite.texture = cloud_textures[randi() % cloud_textures.size()]
    sprite.position = start_pos

    sprite.flip_h = randf() < 0.5

    sprite.modulate = Color(1, 1, 1, randf_range(min_alpha, max_alpha))

    add_child(sprite)

    var cloud_data = {
        "sprite": sprite,
        "velocity": velocity,
        "end_x": end_x
    }
    active_clouds.append(cloud_data)
