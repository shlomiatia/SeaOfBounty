class_name BattleUnit extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start() -> void:
    animation_player.play("MoveToBeforeAttack")
    await animation_player.animation_finished
    animation_player.play("BeforeAttack")

func attack() -> void:
    animation_player.play("Attack")
    await animation_player.animation_finished
