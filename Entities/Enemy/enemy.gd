class_name Enemey extends Node2D

@export var map: Map

func _ready() -> void:
    position = map.map_to_local(map.local_to_map(position))
