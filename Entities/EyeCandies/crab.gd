class_name Crab extends Node2D

@onready var map: Map = $"../../Map"
@onready var _animated: AnimatedSprite2D = $AnimatedSprite2D

@export var min_appear_time: float = 5.0
@export var max_appear_time: float = 15.0

@export var min_animation_diff_time: float = 1.0
@export var max_animation_diff_time: float = 3.0

@export var flip_h_chance: float = 0.5

var _allowed_tileset_pairs: Array = [
    Vector2i(5, 1), Vector2i(6, 1), Vector2i(9, 1), Vector2i(10, 1), Vector2i(13, 1), Vector2i(14, 1),
    Vector2i(5, 2), Vector2i(6, 2), Vector2i(9, 2), Vector2i(10, 2), Vector2i(13, 2), Vector2i(14, 2),
    Vector2i(2, 6), Vector2i(5, 6)
]

func _ready() -> void:
    visible = false
    _schedule_next_spawn()

func _schedule_next_spawn() -> void:
    var t = randf_range(min_appear_time, max_appear_time)
    get_tree().create_timer(t).connect("timeout", Callable(self, "_on_spawn"))

func _on_spawn() -> void:
    var used = map.get_used_rect()
    var candidates: Array = []
    for x in range(used.position.x, used.position.x + used.size.x):
        for y in range(used.position.y, used.position.y + used.size.y):
            var cell = Vector2i(x, y)
            var atlas_coords = map.get_cell_atlas_coords(cell)

            for pair in _allowed_tileset_pairs:
                if atlas_coords.x == pair.x and atlas_coords.y == pair.y:
                    candidates.append(cell)
                    break

    if candidates.size() == 0:
        return
    
    var pick = candidates[randi() % candidates.size()]
    position = map.map_to_local(pick)
    visible = true

    var anim = "default"
    _animated.animation = anim
    _animated.flip_h = randf() < flip_h_chance
    _animated.play_backwards(anim)

    var t2 = randf_range(min_animation_diff_time, max_animation_diff_time)
    get_tree().create_timer(t2).connect("timeout", Callable(self, "_on_switch_forward"))

func _on_switch_forward() -> void:
    if _animated:
        var anim = _animated.animation
        _animated.play(anim)

    var t3 = randf_range(min_animation_diff_time, max_animation_diff_time)
    get_tree().create_timer(t3).connect("timeout", Callable(self, "_on_hide"))

func _on_hide() -> void:
    visible = false
    _schedule_next_spawn()
