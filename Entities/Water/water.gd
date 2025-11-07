@tool
extends Sprite2D

func _process(_delta: float) -> void:
    material.set_shader_parameter("scale", scale)
    var zoom = get_viewport().global_canvas_transform.y
    material.set_shader_parameter("zoom", zoom)