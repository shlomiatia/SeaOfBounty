class_name Unit extends Node2D

signal text_list_finished

const movement_speed: float = 300.0

@export var max_hp: int = 100
@export var hp: int = 100
@export var damage: int = 40
@export var max_movement: int = 4
@export var attack_range: int = 1
@export var initial_direction: String = "right"
@export var sprite_frames: SpriteFrames
@export var display_name: String = "Monster"

@onready var map: Map = $"../../Map"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var reflection = $Reflection
@onready var status: Node2D = $Status
@onready var status_background: Sprite2D = $Status/Box/Background
@onready var hp_border: Sprite2D = $Status/Border
@onready var status_label: Label = $Status/Box/Label
@onready var hp_bar: Sprite2D = $Status/Border/HPBar
@onready var status_box: Node2D = $Status/Box
@onready var typing_label: TypingLabel = $TypingLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var moved: bool
var activated: bool
var text_list: Array[String] = []
var current_text_index: int = 0
var audio_stream_player_tween: Tween

func _ready() -> void:
    if sprite_frames:
        animated_sprite_2d.sprite_frames = sprite_frames
        reflection.sprite_frames = sprite_frames

    position = map.map_to_local(map.local_to_map(position))
    animated_sprite_2d.play(initial_direction)
    reflection.play(initial_direction)
    update_reflection_uv_bounds()

func _process(_delta: float) -> void:
    status_label.text = "%s\n%s/%s" % [display_name, hp, max_hp]
    var hp_percentage = float(hp) / float(max_hp)
    hp_bar.scale.x = hp_percentage * 1.44
    hp_bar.position.x = -18 * (1 - hp_percentage)
        
    if position.y > 20:
        status.position.y = -36
        status_background.scale.y = 1
        status_label.position.y = -12
        hp_border.position.y = 10
    else:
        status.position.y = 40
        status_background.scale.y = -1
        status_label.position.y = -5
        hp_border.position.y = -10

    var unit_material = animated_sprite_2d.material as ShaderMaterial
    unit_material.set_shader_parameter("modulate", modulate)

    var reflection_material = reflection.material as ShaderMaterial
    if reflection_material:
        reflection_material.set_shader_parameter("alpha", modulate.a)

    if current_text_index < text_list.size():
        if Input.is_action_just_pressed("confirm"):
            _handle_text_confirm()
        elif Input.is_action_just_pressed("cancel"):
            typing_label.finish_typing()
            current_text_index = text_list.size() - 1
            _move_to_next_text()

func move_to(target_grid_pos: Vector2i) -> void:
    var unit_grid_pos := map.local_to_map(position)
    var start_world_pos := map.map_to_local(unit_grid_pos)
    var target_world_pos := map.map_to_local(target_grid_pos)
    var tile_path := map.find_tile_path(start_world_pos, target_world_pos)
    
    await animate_along_path(tile_path)

func animate_along_path(tile_path: Array[Vector2i]) -> void:
    if audio_stream_player_tween:
        audio_stream_player.volume_db = 0
        audio_stream_player_tween.kill()
        audio_stream_player_tween = null

    audio_stream_player.play()
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
    fade_out_sound()


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
    var reflection_sprite_frames = reflection.sprite_frames

    var frame_texture = reflection_sprite_frames.get_frame_texture(current_animation, 0)

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
    if typing_label.is_typing():
        typing_label.finish_typing()
    else:
        _move_to_next_text()

func _move_to_next_text() -> void:
    current_text_index += 1
    _show_current_text()

func _finish_text_list() -> void:
    typing_label.visible = false
    text_list_finished.emit()

func fade_out_sound(duration: float = 2.0):
    audio_stream_player_tween = create_tween()
    audio_stream_player_tween.tween_property(audio_stream_player, "volume_db", -80, duration)
    audio_stream_player_tween.tween_callback(audio_stream_player.stop)
    await audio_stream_player_tween.finished
    audio_stream_player.volume_db = 0
    audio_stream_player_tween = null