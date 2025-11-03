class_name Hero extends Node2D

@export var map: Map
@export var max_movement := 4
const movement_speed: float = 400.0

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

        var tween = create_tween()
        var distance = position.distance_to(target_world_pos)
        var duration = distance / movement_speed

        tween.tween_property(self, "position", target_world_pos, duration)
        await tween.finished
