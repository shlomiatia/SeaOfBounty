class_name SeaHorseAnimatedSprite extends AnimatedSprite2D

@export var unit: Unit
@export var region_offset: Vector2 = Vector2.ZERO
@export var region_size: Vector2 = Vector2.ZERO

var last_hp: int = -1

func _process(_delta: float) -> void:
    if unit != null && unit.hp != last_hp:
        last_hp = unit.hp
        update_sea_horse_region()

func update_sea_horse_region() -> void:
    if unit.hp < 500:
        for animation_name in sprite_frames.get_animation_names():
            var frame_count = sprite_frames.get_frame_count(animation_name)
            for frame_idx in range(frame_count):
                var atlas_texture = sprite_frames.get_frame_texture(animation_name, frame_idx) as AtlasTexture
                if atlas_texture:
                    var new_atlas = AtlasTexture.new()
                    new_atlas.atlas = atlas_texture.atlas
                    new_atlas.region = Rect2(
                        region_offset,
                        region_size
                    )
                    sprite_frames.set_frame(animation_name, frame_idx, new_atlas)
        unit.update_reflection_uv_bounds()
        unit.damage = 100
