class_name Dialog extends Node2D

@onready var description_label: TypingLabel = $DescriptionLabel
@onready var dialog_label: TypingLabel = $DialogLabel
@onready var hero_placeholder: Node2D = $Hero

@export var dialog_pairs: Array[Array] = []

var current_index: int = 0
var current_battle_unit: BattleUnit = null

func _ready() -> void:
    dialog_pairs = [
        ["", "Somwhere in the ocean..."],
        ["Orphan", "Caught anything yet?"],
        ["Fisherman", "The sea is silent.\nSomething is scaring the fish..."],
        ["Orphan", "Whoo, Monsters?!"],
        ["Fisherman", "Yes. The island folk sent word."],
        ["Orphan", "Can we go, please??"],
        ["Fisherman", "<sigh> We're going..."],
    ]
    description_label.visible = false
    dialog_label.visible = false

    if dialog_pairs.size() > 0:
        _show_current_dialog()

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("confirm"):
        _handle_confirm()

func _handle_confirm() -> void:
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

        if current_battle_unit:
            hero_placeholder.remove_child(current_battle_unit)
            current_battle_unit.queue_free()
            current_battle_unit = null
    else:
        description_label.visible = false
        dialog_label.visible = true
        dialog_label.text = text_str

        _load_battle_unit(name_str)

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

func _move_to_next() -> void:
    current_index += 1
    _show_current_dialog()

func _finish_dialog() -> void:
    description_label.visible = false
    dialog_label.visible = false

    if current_battle_unit:
        hero_placeholder.remove_child(current_battle_unit)
        current_battle_unit.queue_free()
        current_battle_unit = null

    visible = false

func _get_current_label() -> TypingLabel:
    if description_label.visible:
        return description_label
    elif dialog_label.visible:
        return dialog_label
    return null
