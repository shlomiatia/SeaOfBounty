class_name WaterEyeCandy extends Node2D

@onready var map: Map = $"../../Map"
@onready var _animated: AnimatedSprite2D = $AnimatedSprite2D

@export var min_appear_time: float = 3.0
@export var max_appear_time: float = 8.0

@export var flip_h_chance: float = 0.5

@export var allowed_atlas_coords: Array[Vector2i] = [Vector2i(14, 6)]

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

            var is_valid_tile = false
            for coords in allowed_atlas_coords:
                if atlas_coords.x == coords.x and atlas_coords.y == coords.y:
                    is_valid_tile = true
                    break

            if !is_valid_tile:
                continue

            var unit_at_tile = Utils.get_entity_at_tile(map, cell, "units")
            if unit_at_tile == null:
                candidates.append(cell)

    if candidates.size() == 0:
        _schedule_next_spawn()
        return

    var pick = candidates[randi() % candidates.size()]
    position = map.map_to_local(pick)
    visible = true

    var anim = "default"
    _animated.animation = anim
    _animated.flip_h = randf() < flip_h_chance
    _animated.play(anim)

    await _animated.animation_finished
    _on_hide()

func _on_hide() -> void:
    visible = false
    _schedule_next_spawn()
