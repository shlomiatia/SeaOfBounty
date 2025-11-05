class_name PossibleAttack extends TileMapLayer

@export var attack_range: AttackRange


func highlight_possible_attack(enemy_tiles: Array[Vector2i] = []) -> void:
    clear()

    var attack_range_cells = attack_range.get_used_cells()

    for enemy_tile in enemy_tiles:
        if attack_range_cells.has(enemy_tile):
            set_cell(enemy_tile, 0, Vector2i(0, 0))
