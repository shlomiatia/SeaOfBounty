class_name Battle extends Node2D

@onready var battle_meter: BattleMeter = $BattleMeter
@onready var hero_placeholder: Node2D = $Hero
@onready var enemy_placeholder: Node2D = $Enemy
@onready var hero_hp_label: Label = $HeroHP
@onready var enemy_hp_label: Label = $EnemyHP
@onready var map: Map = $"../Map"
@onready var shaking_camera: Camera2D = $"../ShakingCamera"

func start(attacker: Unit, defender: Unit) -> void:
    visible = true

    var defender_is_hero := defender.is_in_group("heroes")
    var can_counter_attack := _can_counter_attack(attacker, defender)
    var hero_name: String
    var enemy_name: String
    var hero: Unit
    var enemy: Unit

    if defender_is_hero:
        hero_name = defender.display_name
        enemy_name = attacker.display_name
        hero = defender
        enemy = attacker
    else:
        hero_name = attacker.display_name
        enemy_name = defender.display_name
        hero = attacker
        enemy = defender

    set_hp_label(hero_hp_label, hero.hp)
    set_hp_label(enemy_hp_label, enemy.hp)
    
    var hero_unit = "res://Entities/BattleUnits/%s/%s.tscn" % [hero_name, hero_name]
    var battle_hero: BattleUnit = load(hero_unit).instantiate() as BattleUnit
    battle_hero.unit = hero
    hero_placeholder.add_child(battle_hero)

    var enemy_unit = "res://Entities/BattleUnits/%s/%s.tscn" % [enemy_name, enemy_name]
    var battle_enemy: BattleUnit = load(enemy_unit).instantiate() as BattleUnit
    battle_enemy.unit = enemy
    enemy_placeholder.add_child(battle_enemy)


    if defender_is_hero:
        await _perform_defend(defender, attacker, battle_enemy, battle_hero)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_attack(defender, attacker, battle_hero, battle_enemy)
    else:
        await _perform_attack(attacker, defender, battle_hero, battle_enemy)
        if attacker.hp > 0 and defender.hp > 0 and can_counter_attack:
            await _perform_defend(attacker, defender, battle_enemy, battle_hero)
        
    await get_tree().create_timer(0.2).timeout

    visible = false
    hero_placeholder.remove_child(battle_hero)
    enemy_placeholder.remove_child(battle_enemy)

    if enemy.hp == 0:
        await _fade_out_and_remove(enemy)
    if hero.hp == 0:
        await _fade_out_and_remove(hero)


func _can_counter_attack(attacker: Unit, defender: Unit) -> bool:
    var attacker_grid_pos = map.local_to_map(attacker.position)
    return Utils.is_in_range(defender, attacker_grid_pos, map)

func _perform_attack(hero: Unit, enemy: Unit, battle_hero: BattleUnit, battle_enemy: BattleUnit) -> void:
    battle_hero.start()
    battle_meter.start("attack")
    var attack_value = await battle_meter.indicator_stopped

    assign_damage(hero, enemy, hero_hp_label, enemy_hp_label, attack_value, battle_enemy)
    await battle_hero.attack()

func _perform_defend(hero: Unit, enemy: Unit, battle_enemy: BattleUnit, battle_hero: BattleUnit) -> void:
    battle_enemy.start()
    battle_meter.start("defend")
    var defend_value = await battle_meter.indicator_stopped

    assign_damage(enemy, hero, enemy_hp_label, hero_hp_label, defend_value, battle_hero)
    await battle_enemy.attack()

func _fade_out_and_remove(unit: Unit) -> void:
    unit.remove_from_group("heroes")
    unit.remove_from_group("enemies")
    var tween = create_tween()
    tween.tween_property(unit.animated_sprite_2d, "modulate:a", 0.0, 1.0)
    await tween.finished
    unit.queue_free()

func assign_damage(attacker: Unit, defender: Unit, attacker_hp_label: Label, defender_hp_label: Label, modifier: float, battle_unit: BattleUnit) -> void:
    var damage_dealt = int(attacker.damage * modifier)
    if damage_dealt == 0:
        attacker_hp_label.text = "Miss!"
    else:
        attacker_hp_label.text = "%s damage (%s%%)" % [damage_dealt, int(modifier * 100)]
        var tween = create_tween()
        battle_unit.modulate = Color.RED
        tween.tween_property(battle_unit, "modulate", Color.WHITE, 1.0)
        
    var old_hp = defender.hp
    defender.hp = max(0, defender.hp - damage_dealt)
    var new_hp = defender.hp

    var label_tween = create_tween()
    label_tween.tween_method(func(value: float) -> void: set_hp_label(defender_hp_label, value), old_hp, new_hp, 1.0)

func set_hp_label(label: Label, hp: float) -> void:
    label.text = "%s HP" % [int(hp)]
