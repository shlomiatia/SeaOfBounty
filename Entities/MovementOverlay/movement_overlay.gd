class_name MovementOverlay extends Node2D

@onready var map: Map = $"../Map"
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var attack_range: AttackRange = $AttackRange
@onready var possible_attack: PossibleAttack = $PossibleAttack
@onready var possible_buff: PossibleBuff = $PossibleBuff


func highlight_movement_and_attack(clicked_grid_pos: Vector2i, group: String) -> Unit:
    var entities = get_tree().get_nodes_in_group(group)

    for entity in entities:
        var entity_grid_pos = map.local_to_map(entity.position)
        if clicked_grid_pos == entity_grid_pos:
            clear()

            var movement = entity.max_movement
            if entity.moved:
                movement = 0

            var tentacles: Array[Unit] = []
            if entity.display_name == "Kraken":
                for enemy in get_tree().get_nodes_in_group("enemies"):
                    if enemy.display_name == "Tentacle":
                        enemy.remove_from_group("enemies")
                        tentacles.append(enemy)
            possible_movement.highlight_possible_movement(clicked_grid_pos, movement)
            for tentacle in tentacles:
                tentacle.add_to_group("enemies")
            attack_range.highlight_attack_range(entity)
            possible_attack.highlight_possible_attack(entity)
            possible_buff.highlight_possible_buff(entity)
            entity.status_box.show()

            return entity

    return null

func clear() -> void:
    var entities = get_tree().get_nodes_in_group("units")
    for entity in entities:
        entity.status_box.hide()
    possible_movement.clear()
    attack_range.clear()
    possible_attack.clear()
    possible_buff.clear()
