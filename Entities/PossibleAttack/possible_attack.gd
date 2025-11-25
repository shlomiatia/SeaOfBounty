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

func preview_attack(unit: Unit, target_pos: Vector2) -> void:
    clear()

    var possible_tiles: Array[Vector2i] = []

    var movement_dest = map.local_to_map(target_pos)
    var attack_range_cells = attack_range.get_used_cells()

    var enemy = Utils.get_entity_at_tile(map, movement_dest, "enemies")
    if enemy:
        if attack_range_cells.has(movement_dest):
            set_cell(movement_dest, 0, Vector2i(0, 0))
        return

    possible_tiles = map.get_enemy_tiles()

    for enemy_tile in possible_tiles:
        if Utils.get_tile_distance(movement_dest, enemy_tile) <= unit.attack_range && attack_range_cells.has(enemy_tile):
            set_cell(enemy_tile, 0, Vector2i(0, 0))
