class_name Level2 extends Node2D

@onready var main: Main = $Main
@onready var tutorial_event_handler: TutorialEventHandler = $TutorialEventHandler
@onready var orphan: Unit = $Main/Units/Orphan
@onready var units_node: Node2D = $Main/Units
@onready var map: Map = $Main/Map
@onready var fade: Fade = $Main/CanvasLayer/Fade

var won_triggered: bool = false
var fisherman: Unit

func _ready() -> void:
    SaveManager.save_progress(2)
    main.won.connect(on_won)
    MusicPlayer.stream = preload("res://Music/violin B.mp3")
    MusicPlayer.play()
    await get_tree().create_timer(1.0).timeout

    orphan.start_text_list(DialogData.level_2_intro)
    await orphan.text_list_finished
    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(0)

func on_won() -> void:
    if won_triggered:
        await fade.fade_out()
        get_tree().change_scene_to_file("res://Levels/Level3/Level3.tscn")
        return
    won_triggered = true

    orphan.start_text_list(DialogData.level_2_won_1)
    await orphan.text_list_finished

    var monster_prefab = preload("res://Entities/Unit/Units/Monster.tscn")
    var monster1 = monster_prefab.instantiate()
    var monster2 = monster_prefab.instantiate()
    var monster3 = monster_prefab.instantiate()
    monster3.initial_direction = "left"

    units_node.add_child(monster1)
    units_node.add_child(monster2)
    units_node.add_child(monster3)

    monster1.position = map.map_to_local(Vector2i(2, -1))
    monster2.position = map.map_to_local(Vector2i(2, 9))
    monster3.position = map.map_to_local(Vector2i(15, 9))
    
    var path1: Array[Vector2i] = [Vector2i(2, -1), Vector2i(2, 0)]
    var path2: Array[Vector2i] = [Vector2i(2, 9), Vector2i(2, 8)]
    var path3: Array[Vector2i] = [Vector2i(15, 9), Vector2i(15, 8)]

    monster1.animate_along_path(path1)
    monster2.animate_along_path(path2)
    await monster3.animate_along_path(path3)

    orphan.start_text_list(DialogData.level_2_won_2)
    await orphan.text_list_finished

    fisherman = preload("res://Entities/Unit/Units/Fisherman.tscn").instantiate()
    units_node.add_child(fisherman)
    fisherman.position = map.map_to_local(Vector2i(-1, 4))

    var fisherman_path: Array[Vector2i] = [Vector2i(-1, 4), Vector2i(0, 4)]
    await fisherman.animate_along_path(fisherman_path)

    fisherman.start_text_list(DialogData.level_2_fisherman)
    await fisherman.text_list_finished

    main.start_player_turn()
    tutorial_event_handler.show_tutorial_at_step(7)
