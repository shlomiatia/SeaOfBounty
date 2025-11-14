class_name AttackRange extends TileMapLayer

@onready var map: Map = $"../../Map"
@export var possible_movement: PossibleMovement

func highlight_attack_range(unit: Unit) -> void:
    var excluded_tiles: Array[Vector2i] = []
    if unit.is_in_group("heroes"):
        excluded_tiles = map.get_hero_tiles()
    else:
        excluded_tiles = map.get_enemy_tiles()
    excluded_tiles.append_array(map.get_non_navigable_tiles())

    clear()

    var filled_cells = possible_movement.get_used_cells()
    filled_cells.append(map.local_to_map(unit.position))

    var attack_cells: Array[Vector2i] = []

    for cell in filled_cells:
        for x in range(-unit.attack_range, unit.attack_range + 1):
            for y in range(-unit.attack_range, unit.attack_range + 1):
                if abs(x) + abs(y) > unit.attack_range or (x == 0 and y == 0):
                    continue

                var attack_cell = cell + Vector2i(x, y)

                if excluded_tiles.has(attack_cell):
                    continue

                var attack_tile_data = possible_movement.get_cell_source_id(attack_cell)

                if attack_tile_data == -1 and not attack_cells.has(attack_cell):
                    attack_cells.append(attack_cell)

    for attack_cell in attack_cells:
        set_cell(attack_cell, 0, Vector2i(0, 0))
