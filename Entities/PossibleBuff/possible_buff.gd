class_name PossibleBuff extends TileMapLayer

@onready var map: Map = $"../../Map"

func highlight_possible_buff(unit: Unit) -> void:
    clear()

    if unit.display_name != "Lia" || unit.activated:
        return

    for hero_unit in get_tree().get_nodes_in_group("heroes"):
        if hero_unit.hp >= hero_unit.max_hp:
            continue

        var hero_grid_pos = map.local_to_map(hero_unit.position)
        set_cell(hero_grid_pos, 0, Vector2i(0, 0))
