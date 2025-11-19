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
@export var set_flip_h: bool

@onready var map: Map = $"../../Map"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var reflection = $Reflection
@onready var typing_label: TypingLabel = $TypingLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var status_box: Node2D = $UnitStatus/Box
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var moved: bool
var activated: bool
var text_list: Array[String] = []
var current_text_index: int = 0
var audio_stream_player_tween: Tween

func _ready() -> void:
    animation_player.seek(randf() * 2.0)
    if sprite_frames:
        animated_sprite_2d.sprite_frames = sprite_frames
        reflection.sprite_frames = sprite_frames

    position = map.map_to_local(map.local_to_map(position))
    play_animation(initial_direction)

func _process(_delta: float) -> void:
    if hp > 0:
        if !moved || !activated:
            animated_sprite_2d.modulate = Color(1, 1, 1)
        else:
            animated_sprite_2d.modulate = Color(0.5, 0.5, 0.5)

    var unit_material = animated_sprite_2d.material as ShaderMaterial
    unit_material.set_shader_parameter("modulate", animated_sprite_2d.modulate)

    var reflection_material = reflection.material as ShaderMaterial
    if reflection_material:
        reflection_material.set_shader_parameter("alpha", animated_sprite_2d.modulate.a)

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
    if tile_path.size() < 2:
        return
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
        play_animation(animation)

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
    var atlas_height = atlas.get_height()
    var uv_left = region.position.x / atlas_width
    var uv_right = (region.position.x + region.size.x) / atlas_width
    var uv_top = region.position.y / atlas_height
    var uv_bottom = (region.position.y + region.size.y) / atlas_height

    var shader_material = reflection.material as ShaderMaterial
    shader_material.set_shader_parameter("uv_left", uv_left)
    shader_material.set_shader_parameter("uv_right", uv_right)
    shader_material.set_shader_parameter("uv_top", uv_top)
    shader_material.set_shader_parameter("uv_bottom", uv_bottom)

    var unit_material = animated_sprite_2d.material as ShaderMaterial
    unit_material.set_shader_parameter("uv_bottom", uv_bottom)

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

func play_animation(anim: String) -> void:
    animated_sprite_2d.play(anim)
    reflection.play(anim)
    update_reflection_uv_bounds()
    if set_flip_h:
        if anim == "left":
            animated_sprite_2d.flip_h = true
            reflection.flip_h = true
        elif anim == "right":
            animated_sprite_2d.flip_h = false
            reflection.flip_h = false