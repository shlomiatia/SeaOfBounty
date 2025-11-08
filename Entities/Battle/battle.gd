class_name Battle extends Node2D

@onready var label = $Label
@onready var battle_meter = $BattleMeter
@onready var map: Map = $"../Map"

func start(attacker: Unit, defender: Unit) -> void:
    visible = true

    var defender_is_hero = defender.is_in_group("heroes")

    var can_counter_attack = _can_counter_attack(attacker, defender)

    if defender_is_hero:
        await _perform_defend(defender, attacker)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_attack(defender, attacker)
    else:
        await _perform_attack(attacker, defender)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_defend(attacker, defender)

    await get_tree().create_timer(0.5).timeout
    visible = false

func _can_counter_attack(attacker: Unit, defender: Unit) -> bool:
    var attacker_grid_pos = map.local_to_map(attacker.position)
    var defender_grid_pos = map.local_to_map(defender.position)
    var distance = abs(attacker_grid_pos.x - defender_grid_pos.x) + abs(attacker_grid_pos.y - defender_grid_pos.y)
    return distance <= defender.attack_range and distance > 0


func _perform_attack(attacker: Unit, defender: Unit) -> void:
    label.text = "Attack"
    battle_meter.start("attack")
    var attack_value = await battle_meter.indicator_stopped

    var damage_dealt = int(attacker.damage * attack_value)
    defender.hp = max(0, defender.hp - damage_dealt)

    label.text = "Inflicted " + str(damage_dealt) + " damage"
    await get_tree().create_timer(1.0).timeout

    if defender.hp == 0:
        await _fade_out_and_remove(defender)


func _perform_defend(defender: Unit, attacker: Unit) -> void:
    label.text = "Defend"
    battle_meter.start("defense")
    var defend_value = await battle_meter.indicator_stopped

    var damage_dealt = int(attacker.damage * defend_value)
    defender.hp = max(0, defender.hp - damage_dealt)

    label.text = "Took " + str(damage_dealt) + " damage"
    await get_tree().create_timer(1.0).timeout

    if defender.hp == 0:
        await _fade_out_and_remove(defender)

func _fade_out_and_remove(unit: Unit) -> void:
    label.text = ""
    var tween = create_tween()
    tween.tween_property(unit, "modulate:a", 0.0, 1.0)
    await tween.finished
    unit.queue_free()
