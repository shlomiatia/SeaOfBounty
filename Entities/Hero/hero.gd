class_name Hero extends Unit

const movement_speed: float = 300.0

@onready var map: Map = $"../Map"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var reflection = $AnimatedSprite2D/Reflection

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

        var animation = get_animation(direction)
        animated_sprite_2d.play(animation)
        reflection.play(animation)

        var tween = create_tween()
        var distance = position.distance_to(target_world_pos)
        var duration = distance / movement_speed

        tween.tween_property(self, "position", target_world_pos, duration)
        await tween.finished


func get_animation(direction: Vector2) -> String:
    if abs(direction.x) > abs(direction.y):
        if direction.x < 0:
            return "left"
        else:
            return "right"
    else:
        if direction.y < 0:
            return "up"
        else:
            return "down"
