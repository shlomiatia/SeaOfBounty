class_name Dialog extends Node2D

signal dialog_finished

@onready var description_label: TypingLabel = $DescriptionLabel
@onready var dialog_label: TypingLabel = $DialogLabel
@onready var hero_placeholder: Sprite2D = $Hero
@onready var name_label: Label = $NameLabel

@export var dialog_pairs: Array[Array] = []

var current_index: int = 0
var is_input_disabled: bool = true

const HERO_DATA = {
    "Finn": ["Finn", "#a22633"],
    "Kate": ["Kate", "#fee761"],
    "OneEye": ["One Eye", "#f0deb4"],
    "Lia": ["Lia", "#d77643"]
}

func start(pairs: Array[Array]) -> void:
    is_input_disabled = false
    dialog_pairs = pairs
    description_label.visible = false
    dialog_label.visible = false
    current_index = 0

    if dialog_pairs.size() > 0:
        _show_current_dialog()

func _input(event: InputEvent) -> void:
    if is_input_disabled:
        return

    if event.is_action_pressed("confirm"):
        _handle_confirm()

func _handle_confirm() -> void:
    var current_label = _get_current_label()

    if current_label and current_label.is_typing():
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
        hero_placeholder.hide()

    else:
        description_label.visible = false
        dialog_label.visible = true
        dialog_label.text = text_str

        hero_placeholder.texture = load("res://Textures/BattleUnits/%s/Normal.PNG" % [name_str])
        hero_placeholder.show()
        _set_hero_name_and_color(name_str)

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
    hero_placeholder.hide()

    is_input_disabled = true
    dialog_finished.emit()

func _get_current_label() -> TypingLabel:
    if description_label.visible:
        return description_label
    elif dialog_label.visible:
        return dialog_label
    return null
