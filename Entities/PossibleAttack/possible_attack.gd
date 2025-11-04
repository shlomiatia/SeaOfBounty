class_name PossibleAttack extends TileMapLayer

@export var attack_range: AttackRange


func highlight_possible_attack(enemy_tiles: Array[Vector2i] = []) -> void:
    clear()

    # Get all filled cells from attack_range
    var attack_range_cells = attack_range.get_used_cells()

    # For each enemy tile, check if it's in the attack range
    for enemy_tile in enemy_tiles:
        if attack_range_cells.has(enemy_tile):
            # This enemy is within attack range, highlight it
            set_cell(enemy_tile, 0, Vector2i(0, 0))
