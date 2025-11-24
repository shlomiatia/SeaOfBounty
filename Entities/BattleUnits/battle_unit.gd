class_name BattleUnit extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var unit: Unit
var last_hp: int = -1

func _ready() -> void:
    animation_player.animation_finished.connect(_on_animation_finished)
    if unit != null:
        last_hp = unit.hp
    update_crab_texture()

func _process(_delta: float) -> void:
    if unit != null && unit.hp != last_hp:
        last_hp = unit.hp
        update_crab_texture()

func start() -> void:
    animation_player.play("MoveToBeforeAttack")

func attack() -> void:
    animation_player.play("Attack")
    await animation_player.animation_finished

func _on_animation_finished(animation: String) -> void:
    if animation == "MoveToBeforeAttack":
        animation_player.play("BeforeAttack")

func update_crab_texture() -> void:
    if unit == null || unit.display_name != "Crab":
        return

    var texture_path: String = ""

    if unit.hp >= 300:
        texture_path = "res://Textures/Monsters enemies/סרטן/סרטן רגיל.png"
    elif unit.hp >= 200:
        texture_path = "res://Textures/Monsters enemies/סרטן/סרטן מכה 1.png"
    elif unit.hp >= 100:
        texture_path = "res://Textures/Monsters enemies/סרטן/סרטן מכה 2.png"
    else:
        texture_path = "res://Textures/Monsters enemies/סרטן/סרטן מכה 3.png"

    var new_texture = load(texture_path)

    var sprite_frames = $AnimatedSprite2D.sprite_frames
    for animation_name in sprite_frames.get_animation_names():
        var frame_count = sprite_frames.get_frame_count(animation_name)
        for frame_idx in range(frame_count):
            var atlas_texture = sprite_frames.get_frame_texture(animation_name, frame_idx) as AtlasTexture
            if atlas_texture:
                var new_atlas = AtlasTexture.new()
                new_atlas.atlas = new_texture
                new_atlas.region = atlas_texture.region
                sprite_frames.set_frame(animation_name, frame_idx, new_atlas)
