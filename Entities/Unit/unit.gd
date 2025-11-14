class_name Unit extends Node2D

signal text_list_finished

const movement_speed: float = 300.0

@export var hp: int = 100
@export var damage: int = 50
@export var max_movement: int = 4
@export var attack_range: int = 1
@export var initial_direction: String = "right"

@onready var map: Map = $"../../Map"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var reflection = $Reflection
@onready var hp_label: Label = $HP
@onready var typing_label: TypingLabel = $TypingLabel

var moved: bool
var activated: bool

var text_list: Array[String] = []
var current_text_index: int = 0

func _ready() -> void:
    position = map.map_to_local(map.local_to_map(position))
    setup_unit_frames()
    animated_sprite_2d.play(initial_direction)
    reflection.play(initial_direction)
    update_reflection_uv_bounds()

func setup_unit_frames() -> void:
    var frame_coords = get_frame_coordinates(name)

    if frame_coords.is_empty():
        return
    
    var base_texture = preload("res://Textures/Smaller boat characters.png")
    var sprite_frames = animated_sprite_2d.sprite_frames

    var directions = ["up", "down", "right", "left"]
    for i in range(4):
        var atlas = AtlasTexture.new()
        atlas.atlas = base_texture
        atlas.region = Rect2(frame_coords[i].x, frame_coords[i].y, 40, 40)

        sprite_frames.set_frame(directions[i], 0, atlas)

    reflection.sprite_frames = sprite_frames

func get_frame_coordinates(character_name: String) -> Array:
    var coords = []
    var start_x = 0
    var start_y = 0

    match character_name:
        "Musketeer":
            start_x = 1
            start_y = 1
        "OneEye":
            start_x = 165
            start_y = 1
        "HealerMage":
            start_x = 1
            start_y = 54
        "FireMage":
            start_x = 165
            start_y = 54
        "Fisherman":
            start_x = 1
            start_y = 107
        "Orphan":
            start_x = 165
            start_y = 107
        _:
            return []

    coords.append(Vector2(start_x, start_y))
    coords.append(Vector2(start_x + 41, start_y))
    coords.append(Vector2(start_x + 82, start_y))
    coords.append(Vector2(start_x + 123, start_y))

    return coords

func _process(_delta: float) -> void:
    hp_label.text = str(hp)

    var unit_material = animated_sprite_2d.material as ShaderMaterial
    unit_material.set_shader_parameter("alpha", modulate.a)

    var reflection_material = reflection.material as ShaderMaterial
    if reflection_material:
        reflection_material.set_shader_parameter("alpha", modulate.a)

    if current_text_index < text_list.size() && Input.is_action_just_pressed("confirm"):
        _handle_text_confirm()

func move_to(target_grid_pos: Vector2i) -> void:
    var unit_grid_pos := map.local_to_map(position)
    var start_world_pos := map.map_to_local(unit_grid_pos)
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
        update_reflection_uv_bounds()

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

func update_reflection_uv_bounds() -> void:
    var current_animation = reflection.animation
    var sprite_frames = reflection.sprite_frames

    var frame_texture = sprite_frames.get_frame_texture(current_animation, 0)

    var atlas_texture = frame_texture as AtlasTexture
    var atlas = atlas_texture.atlas
    var region = atlas_texture.region

    var atlas_width = atlas.get_width()
    var uv_left = region.position.x / atlas_width
    var uv_right = (region.position.x + region.size.x) / atlas_width

    var shader_material = reflection.material as ShaderMaterial
    shader_material.set_shader_parameter("uv_left", uv_left)
    shader_material.set_shader_parameter("uv_right", uv_right)

func set_is_moved(is_moved: bool) -> void:
    moved = is_moved
    activated = is_moved
    if !moved || !activated:
        modulate = Color(1, 1, 1)
    else:
        modulate = Color(0.5, 0.5, 0.5)

func start_text_list(texts: Array[String]) -> void:
    text_list = texts
    current_text_index = 0

    _show_current_text()

func _show_current_text() -> void:
    if current_text_index >= text_list.size():
        _finish_text_list()
        return

    typing_label.text = text_list[current_text_index]
    typing_label.visible = true

func _handle_text_confirm() -> void:
    if typing_label.is_typeing():
        typing_label.finish_typing()
    else:
        _move_to_next_text()

func _move_to_next_text() -> void:
    current_text_index += 1
    _show_current_text()

func _finish_text_list() -> void:
    typing_label.visible = false
    text_list_finished.emit()
