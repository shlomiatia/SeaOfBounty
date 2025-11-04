class_name Battle extends Node2D

@onready var label = $Label
@onready var battle_meter = $BattleMeter


func start() -> void:
    # Attack phase
    label.text = "Attack"
    battle_meter.start()
    var attack_value = await battle_meter.indicator_stopped
    label.text = "Inflicted " + str(attack_value * 100) + "% damage"

    # Wait 2 seconds
    await get_tree().create_timer(2.0).timeout

    # Defend phase
    label.text = "Defend"
    battle_meter.start()
    var defend_value = await battle_meter.indicator_stopped
    label.text = "Blocked " + str(defend_value * 100) + "% damage"
