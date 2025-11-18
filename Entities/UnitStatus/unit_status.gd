class_name UnitStatus extends Node2D

#@onready var status: Node2D = $Status
@onready var status_background: Sprite2D = $Box/Background
@onready var hp_border: Sprite2D = $Border
@onready var status_label: Label = $Box/Label
@onready var hp_bar: Sprite2D = $Border/HPBar
@onready var unit: Unit = $".."


func _process(_delta: float) -> void:
    status_label.text = "%s\n%s/%s" % [unit.display_name, unit.hp, unit.max_hp]
    var hp_percentage = float(unit.hp) / float(unit.max_hp)
    hp_bar.scale.x = hp_percentage * 1.44
    hp_bar.position.x = -18 * (1 - hp_percentage)
        
    if unit.position.y > 20:
        position.y = -33
        status_background.scale.y = 1
        status_label.position.y = -12
        hp_border.position.y = 10
    else:
        position.y = 36
        status_background.scale.y = -1
        status_label.position.y = -5
        hp_border.position.y = -10
