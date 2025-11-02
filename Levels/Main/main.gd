class_name Main extends Node2D

const max_movement := 3

@onready var player: Node2D = $Player
@onready var map: TileMapLayer = $Map
@onready var movement: TileMapLayer = $Movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
