extends Node2D

enum InputType {
	MOUSE,
	KEYBOARD,
	GAMEPAD
}

var last_input_type: InputType = InputType.KEYBOARD

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		last_input_type = InputType.MOUSE
	elif event is InputEventKey:
		last_input_type = InputType.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_type = InputType.GAMEPAD

func get_text(mouse_text: String, keyboard_text: String, gamepad_text: String) -> String:
	match last_input_type:
		InputType.MOUSE:
			return mouse_text
		InputType.KEYBOARD:
			return keyboard_text
		InputType.GAMEPAD:
			return gamepad_text
	return keyboard_text
