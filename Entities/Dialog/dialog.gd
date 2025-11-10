class_name Dialog extends Node2D

signal dialog_finished

@onready var description_label: TypingLabel = $DescriptionLabel
@onready var dialog_label: TypingLabel = $DialogLabel
@onready var hero_placeholder: Node2D = $Hero
@onready var name_label: Label = $Hero/NameLabel

@export var dialog_pairs: Array[Array] = []

var current_index: int = 0
var current_battle_unit: BattleUnit = null
var is_input_disabled: bool = true

# Hero name mappings: internal_name -> [display_name, color]
const HERO_DATA = {
	"Fisherman": ["Finn", "#a22633"],
	"Orphan": ["Kate", "#fee761"],
	"OneEye": ["One Eye", "#181425"]
}

func start(pairs: Array[Array]) -> void:
    visible = true
    is_input_disabled = false
    dialog_pairs = pairs
    description_label.visible = false
    dialog_label.visible = false

    if dialog_pairs.size() > 0:
        _show_current_dialog()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("confirm"):
        _handle_confirm()

func _handle_confirm() -> void:
    if is_input_disabled:
        return

    var current_label = _get_current_label()

    if current_label and current_label.is_typeing():
        current_label.finish_typing()
    else:
        _move_to_next()

func _show_current_dialog() -> void:
    if current_index >= dialog_pairs.size():
        _finish_dialog()
        return

    var pair = dialog_pairs[current_index]
    var name_str: String = pair[0] if pair.size() > 0 else ""
    var text_str: String = pair[1] if pair.size() > 1 else ""

    if name_str == "":
        description_label.visible = true
        dialog_label.visible = false
        description_label.text = text_str
        name_label.visible = false

        if current_battle_unit:
            hero_placeholder.remove_child(current_battle_unit)
            current_battle_unit.queue_free()
            current_battle_unit = null
    else:
        description_label.visible = false
        dialog_label.visible = true
        dialog_label.text = text_str

        _load_battle_unit(name_str)
        _set_hero_name_and_color(name_str)

func _load_battle_unit(hero_name: String) -> void:
    if current_battle_unit:
        hero_placeholder.remove_child(current_battle_unit)
        current_battle_unit.queue_free()
        current_battle_unit = null

    var unit_path = "res://Entities/BattleUnits/%s/%s.tscn" % [hero_name, hero_name]
    var unit_scene = load(unit_path)
    if unit_scene:
        current_battle_unit = unit_scene.instantiate() as BattleUnit
        hero_placeholder.add_child(current_battle_unit)

func _set_hero_name_and_color(hero_name: String) -> void:
    if HERO_DATA.has(hero_name):
        var hero_info = HERO_DATA[hero_name]
        var display_name = hero_info[0]
        var color_hex = hero_info[1]

        name_label.text = display_name
        name_label.modulate = Color(color_hex)
        name_label.visible = true

func _move_to_next() -> void:
    current_index += 1
    _show_current_dialog()

func _finish_dialog() -> void:
    description_label.visible = false
    dialog_label.visible = false
    name_label.visible = false

    if current_battle_unit:
        hero_placeholder.remove_child(current_battle_unit)
        current_battle_unit.queue_free()
        current_battle_unit = null

    visible = false
    dialog_finished.emit()

func _get_current_label() -> TypingLabel:
    if description_label.visible:
        return description_label
    elif dialog_label.visible:
        return dialog_label
    return null
