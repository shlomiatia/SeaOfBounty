class_name UnitStatus extends Node2D

@onready var status_background: Sprite2D = $Box/Background
@onready var hp_border: Sprite2D = $Border
@onready var status_label: Label = $Box/Label
@onready var hp_bar: Sprite2D = $Border/HPBar
@onready var unit: Unit = $".."
@onready var movement_preview: MovementPreview = $"../../../MovementPreview"


func _process(_delta: float) -> void:
    status_label.text = "%s\n%s/%s" % [unit.display_name, unit.hp, unit.max_hp]
    var hp_percentage = float(unit.hp) / float(unit.max_hp)
    hp_bar.scale.x = hp_percentage * 1.44
    hp_bar.position.x = -18 * (1 - hp_percentage)

    var should_display_below = unit.position.y <= 20

    # Check movement preview cells - display below if cell above is set but cell below is not
    var grid_pos = movement_preview.local_to_map(unit.position)
    var cell_above = grid_pos + Vector2i(0, -1)
    var cell_below = grid_pos + Vector2i(0, 1)
    if movement_preview.get_cell_source_id(cell_above) != -1 and movement_preview.get_cell_source_id(cell_below) == -1:
        should_display_below = true

    if !should_display_below:
        position.y = -33
        status_background.scale.y = 1
        status_label.position.y = -20
        hp_border.position.y = 10
    else:
        position.y = 36
        status_background.scale.y = -1
        status_label.position.y = 3
        hp_border.position.y = -10
