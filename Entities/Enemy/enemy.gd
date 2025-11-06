class_name Enemey extends Unit

@onready var map: Map = $"../Map"

func _ready() -> void:
    position = map.map_to_local(map.local_to_map(position))
