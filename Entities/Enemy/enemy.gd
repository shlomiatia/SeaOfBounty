class_name Enemey extends Node2D

@export var max_movement: int = 3
@onready var map: Map = $/root/Main/Map

func _ready() -> void:
    var tile = map.local_to_map(position)
    position = map.map_to_local(tile)
    #map.set_cell(tile)
