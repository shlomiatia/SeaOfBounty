class_name Battle extends Node2D

@onready var label = $Label
@onready var battle_meter = $BattleMeter
@onready var hero_placeholder = $Hero
@onready var hero_hp_label: Label = $Hero/HeroHP
@onready var enemy_hp_label: Label = $Enemy/EnemyHP
@onready var map: Map = $"../Map"
@onready var shaking_camera: Camera2D = $"../ShakingCamera"

func start(attacker: Unit, defender: Unit) -> void:
    visible = true

    var defender_is_hero := defender.is_in_group("heroes")
    var can_counter_attack := _can_counter_attack(attacker, defender)
    var hero_name: String
    var hero: Unit
    var enemy: Unit

    if defender_is_hero:
        hero_name = defender.name
        hero = defender
        enemy = attacker
    else:
        hero_name = attacker.name
        hero = attacker
        enemy = defender

    hero_hp_label.text = str(hero.hp)
    enemy_hp_label.text = str(enemy.hp)
    
    var unit = "res://Entities/%s/%s.tscn" % [hero_name, hero_name]
    var battle_hero: BattleUnit = load(unit).instantiate() as BattleUnit
    hero_placeholder.add_child(battle_hero)
    
    if defender_is_hero:
        await _perform_defend(defender, attacker)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_attack(defender, attacker, battle_hero)
    else:
        await _perform_attack(attacker, defender, battle_hero)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_defend(attacker, defender)
        
    await get_tree().create_timer(0.2).timeout

    visible = false
    hero_placeholder.remove_child(battle_hero)

func _can_counter_attack(attacker: Unit, defender: Unit) -> bool:
    var attacker_grid_pos = map.local_to_map(attacker.position)
    return Utils.is_in_range(defender, attacker_grid_pos, map)

func _perform_attack(hero: Unit, enemy: Unit, battle_hero: BattleUnit) -> void:
    battle_hero.start()
    label.text = "Attack"
    battle_meter.start("attack")
    var attack_value = await battle_meter.indicator_stopped

    assign_damage(hero, enemy, enemy_hp_label, attack_value)
    await battle_hero.attack()

    if enemy.hp == 0:
        await _fade_out_and_remove(enemy)


func _perform_defend(hero: Unit, enemy: Unit) -> void:
    label.text = "Defend"
    battle_meter.start("defense")
    var defend_value = await battle_meter.indicator_stopped

    await assign_damage(enemy, hero, hero_hp_label, defend_value)

    if hero.hp == 0:
        await _fade_out_and_remove(hero)

func _fade_out_and_remove(unit: Unit) -> void:
    label.text = ""
    var tween = create_tween()
    tween.tween_property(unit, "modulate:a", 0.0, 1.0)
    await tween.finished
    unit.queue_free()

func assign_damage(attacker: Unit, defender: Unit, hp_label: Label, modifier: float) -> void:
    var damage_dealt = int(attacker.damage * modifier)
    var old_hp = defender.hp
    defender.hp = max(0, defender.hp - damage_dealt)
    var new_hp = defender.hp

    label.text = ""
    var duration = 0.2
    var steps = abs(new_hp - old_hp)

    if steps == 0:
        return

    shaking_camera.start_screen_shake()

    var time_per_step = duration / steps
    var current_hp = old_hp

    while current_hp != new_hp:
        if old_hp > new_hp:
            current_hp -= 1
        else:
            current_hp += 1

        hp_label.text = str(current_hp)
        await get_tree().create_timer(time_per_step).timeout
