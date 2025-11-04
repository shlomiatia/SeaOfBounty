class_name AttackRange extends TileMapLayer

@export var possible_movement: PossibleMovement

func highlight_attack_range(excluded_tiles: Array[Vector2i] = []) -> void:
    clear()

    var filled_cells = possible_movement.get_used_cells()

    var attack_cells: Array[Vector2i] = []

    for cell in filled_cells:
        var adjacent_offsets = [
            Vector2i(1, 0),
            Vector2i(-1, 0),
            Vector2i(0, 1),
            Vector2i(0, -1)
        ]

        for offset in adjacent_offsets:
            var adjacent_cell = cell + offset

            if excluded_tiles.has(adjacent_cell):
                continue

            var adjacent_tile_data = possible_movement.get_cell_source_id(adjacent_cell)

            if adjacent_tile_data == -1 and not attack_cells.has(adjacent_cell):
                attack_cells.append(adjacent_cell)

    for attack_cell in attack_cells:
        set_cell(attack_cell, 0, Vector2i(0, 0))