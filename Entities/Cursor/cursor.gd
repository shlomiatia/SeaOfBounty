class_name Cursor extends Sprite2D

const cursor_move_delay: float = 0.15

var is_input_disabled: bool = true
var cursor_move_timer: float = 0.0

@onready var map: Map = $"../Map"

func _ready() -> void:
    var heroes = get_tree().get_nodes_in_group("heroes")
    if heroes.size() > 0:
        var random_hero = heroes[randi() % heroes.size()]
        set_cursor_position(random_hero.position)

func _process(delta: float) -> void:
    visible = !is_input_disabled
    if is_input_disabled:
        return

    handle_cursor(delta)

func _input(event: InputEvent) -> void:
    if is_input_disabled:
        return

    if event is InputEventMouseMotion:
        var mouse_pos = get_global_mouse_position()
        set_cursor_position(mouse_pos)
    if event is InputEventMouseButton:
        set_cursor_position(get_global_mouse_position())

func handle_cursor(delta: float) -> void:
    cursor_move_timer += delta

    var direction := Vector2(
        Input.get_axis("left", "right"),
        Input.get_axis("up", "down")
    )
    var direction_i := Vector2i()
    if direction.x > 0:
        direction_i.x = 1
    elif direction.x < 0:
        direction_i.x = -1
    
    if direction.y > 0:
        direction_i.y = 1
    elif direction.y < 0:
        direction_i.y = -1

    if direction_i != Vector2i.ZERO && cursor_move_timer >= cursor_move_delay:
        _move_cursor_tile(direction_i)
        cursor_move_timer = 0.0


func _move_cursor_tile(direction: Vector2i) -> void:
    var cursor_tile = map.local_to_map(self.position)
    var new_tile = cursor_tile + direction
    var map_rect = map.get_used_rect()
    if map_rect.has_point(new_tile):
        set_cursor_position(map.map_to_local(new_tile))

func set_cursor_position(pos: Vector2) -> void:
    self.position = map.map_to_local(map.local_to_map(pos))
