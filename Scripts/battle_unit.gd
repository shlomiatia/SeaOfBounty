class_name BattleUnit extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    animation_player.animation_finished.connect(_on_animation_finished)

func start() -> void:
    animation_player.play("MoveToBeforeAttack")

func attack() -> void:
    animation_player.play("Attack")
    await animation_player.animation_finished

func _on_animation_finished(animation: String) -> void:
    if animation == "MoveToBeforeAttack":
        animation_player.play("BeforeAttack")