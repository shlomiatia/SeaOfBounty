class_name Battle extends Node2D

@onready var label = $Label
@onready var battle_meter = $BattleMeter


func start() -> void:
    visible = true
    label.text = "Attack"
    battle_meter.start("attack")
    var attack_value = await battle_meter.indicator_stopped
    label.text = "Inflicted " + str(attack_value * 100) + "% damage"

    await get_tree().create_timer(1.0).timeout

    label.text = "Defend"
    battle_meter.start("defense")
    var defend_value = await battle_meter.indicator_stopped
    label.text = "Blocked " + str(defend_value * 100) + "% damage"

    await get_tree().create_timer(1.0).timeout
    visible = false
