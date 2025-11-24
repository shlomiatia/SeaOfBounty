class_name Level10 extends Node2D

@onready var main: Main = $Main
@onready var fade: Fade = $Main/CanvasLayer/Fade
@onready var miguel: Unit = $Main/Units/Miguel
@onready var lia: Unit = $Main/Units/Lia
@onready var constantine: Unit = $Main/Units/Constantine
@onready var units_node: Node2D = $Main/Units
@onready var map: Map = $Main/Map

var won_triggered: bool = false
var kraken: Unit
var one_eye: Unit

func _ready() -> void:
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/Piano B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    # Initial dialog
    miguel.start_text_list(["An ambush!"])
    await miguel.text_list_finished

    lia.start_text_list(["They want to flee, we're just in the way."])
    await lia.text_list_finished

    constantine.start_text_list(["Bad luck for them!"])
    await constantine.text_list_finished

    main.start_player_turn()

func on_won() -> void:
    if won_triggered:
        return
    won_triggered = true

    # Spawn Kraken out of screen and move to (14, 7)
    var kraken_prefab = preload("res://Entities/Unit/Units/Kraken.tscn")
    kraken = kraken_prefab.instantiate()
    units_node.add_child(kraken)

    # Position Kraken off-screen (above the map)
    kraken.position = map.map_to_local(Vector2i(14, -2))

    # Move Kraken to (14, 7)
    var kraken_path: Array[Vector2i] = [Vector2i(14, -2), Vector2i(14, -1), Vector2i(14, 0), Vector2i(14, 1), Vector2i(14, 2), Vector2i(14, 3), Vector2i(14, 4), Vector2i(14, 5), Vector2i(14, 6), Vector2i(14, 7)]
    await kraken.animate_along_path(kraken_path)

    # Spawn 8 Tentacles around the Kraken at (14, 7)
    var tentacle_prefab = preload("res://Entities/Unit/Units/Tentacle.tscn")
    var tentacle_positions: Array[Vector2i] = [
        Vector2i(13, 6), # top-left
        Vector2i(14, 6), # top
        Vector2i(15, 6), # top-right
        Vector2i(13, 7), # left
        Vector2i(15, 7), # right
        Vector2i(13, 8), # bottom-left
        Vector2i(14, 8), # bottom
        Vector2i(15, 8)  # bottom-right
    ]

    var tentacles: Array[Unit] = []
    for pos in tentacle_positions:
        var tentacle: Unit = tentacle_prefab.instantiate()
        units_node.add_child(tentacle)
        tentacle.position = map.map_to_local(pos)
        tentacles.append(tentacle)

    # Play emerge animation on all tentacles
    for tentacle in tentacles:
        var tentacle_sprite: AnimatedSprite2D = tentacle.get_node("AnimatedSprite2D")
        tentacle_sprite.play("emerge")

    # Wait for emerge animation to finish (assuming it takes about 1 second)
    await get_tree().create_timer(1.0).timeout

    # Dialog after tentacles emerge
    constantine.start_text_list(["Your collosal beast! I imagined it will be bigger..."])
    await constantine.text_list_finished

    lia.start_text_list(["It's not the one we encountered.\nI think it's running too..."])
    await lia.text_list_finished

    miguel.start_text_list(["What can scare such a terrible behemoth..."])
    await miguel.text_list_finished

    # Spawn OneEye out of screen and move to any free tile on (X, 0)
    var one_eye_prefab = preload("res://Entities/Unit/Units/OneEye.tscn")
    one_eye = one_eye_prefab.instantiate()
    units_node.add_child(one_eye)

    # Find a free tile at Y=0
    var target_x: int = 8
    for x in range(0, 16):
        var check_pos = Vector2i(x, 0)
        var is_free = true
        for unit in units_node.get_children():
            if unit is Unit:
                var unit_grid_pos = map.local_to_map(unit.position)
                if unit_grid_pos == check_pos:
                    is_free = false
                    break
        if is_free:
            target_x = x
            break

    # Position OneEye off-screen (above the map)
    one_eye.position = map.map_to_local(Vector2i(target_x, -2))

    # Move OneEye to target position
    var one_eye_path: Array[Vector2i] = [Vector2i(target_x, -2), Vector2i(target_x, -1), Vector2i(target_x, 0)]
    await one_eye.animate_along_path(one_eye_path)

    one_eye.start_text_list(["It will soon run from me!"])
    await one_eye.text_list_finished

    lia.start_text_list(["One Eye, you're alive!"])
    await lia.text_list_finished

    miguel.start_text_list(["This one is with you?"])
    await miguel.text_list_finished

    constantine.start_text_list(["Good, we have enough, attack!"])
    await constantine.text_list_finished

    main.start_player_turn()