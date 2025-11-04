class_name Hero extends Node2D

const movement_speed: float = 400.0

@export var map: Map
@export var max_movement := 4

@onready var sprite2d = $Sprite2D

func _ready() -> void:
    position = map.map_to_local(map.local_to_map(position))

func move_to(target_grid_pos: Vector2i) -> void:
    var player_grid_pos := map.local_to_map(position)
    var start_world_pos := map.map_to_local(player_grid_pos)
    var target_world_pos := map.map_to_local(target_grid_pos)
    var tile_path := map.find_tile_path(start_world_pos, target_world_pos)
    
    await animate_along_path(tile_path)


func animate_along_path(tile_path: Array[Vector2i]) -> void:
    for i in range(1, tile_path.size()):
        var target_tile = tile_path[i]
        var target_world_pos = map.map_to_local(target_tile)

        var direction = (target_world_pos - position).normalized()

        update_sprite_for_direction(direction)

        var tween = create_tween()
        var distance = position.distance_to(target_world_pos)
        var duration = distance / movement_speed

        tween.tween_property(self, "position", target_world_pos, duration)
        await tween.finished


func update_sprite_for_direction(direction: Vector2) -> void:
    if abs(direction.x) > abs(direction.y):
        sprite2d.texture = load("res://Textures/ship_right.tres")
        sprite2d.flip_h = direction.x < 0
    else:
        if direction.y < 0:
            sprite2d.texture = load("res://Textures/ship_up.tres")
        else:
            sprite2d.texture = load("res://Textures/ship_down.tres")
        sprite2d.flip_h = false
