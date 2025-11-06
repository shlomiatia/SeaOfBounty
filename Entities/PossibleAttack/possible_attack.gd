class_name PossibleAttack extends TileMapLayer

@onready var attack_range: AttackRange = $"../AttackRange"
@onready var map: Map = $"../../Map"

func highlight_possible_attack(unit: Unit) -> void:
    clear()

    var possible_tiles: Array[Vector2i] = []

    if unit.is_in_group("heroes"):
        possible_tiles = map.get_enemy_tiles()
    else:
        possible_tiles = map.get_hero_tiles()

    var attack_range_cells = attack_range.get_used_cells()

    for possible_tile in possible_tiles:
        if attack_range_cells.has(possible_tile):
            set_cell(possible_tile, 0, Vector2i(0, 0))
