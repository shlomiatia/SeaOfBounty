class_name BattleUnit extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var unit: Unit

func _ready() -> void:
    animation_player.animation_finished.connect(_on_animation_finished)
    if unit.display_name == "Crab":
        var crab_sprite: CrabAnimatedSprite = get_node("AnimatedSprite2D") as CrabAnimatedSprite
        crab_sprite.unit = unit

func start() -> void:
    animation_player.play("MoveToBeforeAttack")

func attack() -> void:
    animation_player.play("Attack")
    await animation_player.animation_finished

func _on_animation_finished(animation: String) -> void:
    if animation == "MoveToBeforeAttack":
        animation_player.play("BeforeAttack")
