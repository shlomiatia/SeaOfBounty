class_name PossibleAttack extends TileMapLayer

@export var possible_movement: PossibleMovement


func highlight_possible_attack() -> void:
    clear()

    # Get all filled cells from possible_movement
    var filled_cells = possible_movement.get_used_cells()

    # Track cells we've already checked to avoid duplicates
    var attack_cells: Array[Vector2i] = []

    # For each filled cell in possible_movement
    for cell in filled_cells:
        # Check all 4 adjacent cells (horizontally and vertically)
        var adjacent_offsets = [
            Vector2i(1, 0),   # Right
            Vector2i(-1, 0),  # Left
            Vector2i(0, 1),   # Down
            Vector2i(0, -1)   # Up
        ]

        for offset in adjacent_offsets:
            var adjacent_cell = cell + offset

            # Check if this adjacent cell is empty in possible_movement
            var adjacent_tile_data = possible_movement.get_cell_source_id(adjacent_cell)

            # If the cell is empty (returns -1) and not already in our list
            if adjacent_tile_data == -1 and not attack_cells.has(adjacent_cell):
                attack_cells.append(adjacent_cell)

    # Set all attack cells with tile (0, 0)
    for attack_cell in attack_cells:
        set_cell(attack_cell, 0, Vector2i(0, 0))