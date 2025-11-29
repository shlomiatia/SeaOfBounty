extends Node

const SAVE_FILE = "user://save_game.dat"

func save_progress(level_number: int) -> void:
	var save_data = {
		"current_level": level_number
	}

	if OS.has_feature("web"):
		var config = ConfigFile.new()
		config.set_value("progress", "current_level", level_number)
		config.save(SAVE_FILE)
	else:
		var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(save_data))
			file.close()

func load_progress() -> int:
	if OS.has_feature("web"):
		var config = ConfigFile.new()
		var err = config.load(SAVE_FILE)
		if err == OK:
			return config.get_value("progress", "current_level", 1)
		return 1
	else:
		if not FileAccess.file_exists(SAVE_FILE):
			return 1

		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				if data.has("current_level"):
					return data["current_level"]
		return 1

func has_save() -> bool:
	if OS.has_feature("web"):
		var config = ConfigFile.new()
		var err = config.load(SAVE_FILE)
		return err == OK
	else:
		return FileAccess.file_exists(SAVE_FILE)

func clear_save() -> void:
	if OS.has_feature("web"):
		var config = ConfigFile.new()
		config.clear()
		config.save(SAVE_FILE)
	else:
		if FileAccess.file_exists(SAVE_FILE):
			DirAccess.remove_absolute(SAVE_FILE)

func get_level_path(level_number: int) -> String:
	if level_number == 1:
		return "res://Levels/Level1/Level1.tscn"
	elif level_number == 2:
		return "res://Levels/Level2/Level2.tscn"
	elif level_number == 3:
		return "res://Levels/Level3/Level3.tscn"
	elif level_number == 4:
		return "res://Levels/Level4/Level4.tscn"
	elif level_number == 5:
		return "res://Levels/Level5/Level5.tscn"
	elif level_number == 6:
		return "res://Levels/Level6/Level6.tscn"
	elif level_number == 7:
		return "res://Levels/Level7/Level7.tscn"
	elif level_number == 8:
		return "res://Levels/Level8/Level8.tscn"
	elif level_number == 9:
		return "res://Levels/Level9/Level9.tscn"
	elif level_number == 10:
		return "res://Levels/Level10/Level10.tscn"
	elif level_number == 11:
		return "res://Levels/Level11/Level11.tscn"
	elif level_number == 12:
		return "res://Levels/Level12/Level12.tscn"
	elif level_number == 13:
		return "res://Levels/Level13/Level13.tscn"
	else:
		return "res://Levels/Level1/Level1.tscn"
