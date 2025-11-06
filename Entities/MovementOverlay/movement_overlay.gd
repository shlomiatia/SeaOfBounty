class_name MovementOverlay extends Node2D

@onready var map: Map = $"../Map"
@onready var possible_movement: PossibleMovement = $PossibleMovement
@onready var attack_range: AttackRange = $AttackRange
@onready var possible_attack: PossibleAttack = $PossibleAttack


func highlight_movement_and_attack(clicked_grid_pos: Vector2i, group: String) -> Unit:
    var entities = get_tree().get_nodes_in_group(group)

    for entity in entities:
        var entity_grid_pos = map.local_to_map(entity.position)
        if clicked_grid_pos == entity_grid_pos:
            clear()

            possible_movement.highlight_possible_movement(clicked_grid_pos, entity.max_movement)
            attack_range.highlight_attack_range(entity)
            possible_attack.highlight_possible_attack(entity)

            return entity

    return null

func clear() -> void:
    possible_movement.clear()
    attack_range.clear()
    possible_attack.clear()