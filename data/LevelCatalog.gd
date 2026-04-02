class_name LevelCatalog
extends RefCounted

const LEVELS := [
	{
		"scene": "res://levels/Level01.tscn",
		"name": "Level 1 - Tokyo Tower",
		"target_time": 45.0,
		"clear_reward": 3.33,
		"death_penalty": 0.6,
		"speed_bonus": 0.9,
	},
	{
		"scene": "res://levels/Level02.tscn",
		"name": "Level 2 - Tokyo Skytree",
		"target_time": 60.0,
		"clear_reward": 6.34,
		"death_penalty": 0.6,
		"speed_bonus": 0.9,
	},
	{
		"scene": "res://levels/Level03.tscn",
		"name": "Level 3 - Burj Khalifa",
		"target_time": 80.0,
		"clear_reward": 8.28,
		"death_penalty": 0.6,
		"speed_bonus": 0.9,
	},
]


static func get_level_count() -> int:
	return LEVELS.size()


static func get_level_data(level_index: int) -> Dictionary:
	if level_index < 0 or level_index >= LEVELS.size():
		return {}
	return LEVELS[level_index]


static func get_scene_path(level_index: int) -> String:
	return str(get_level_data(level_index).get("scene", ""))


static func get_level_name(level_index: int) -> String:
	return str(get_level_data(level_index).get("name", ""))


static func get_target_time(level_index: int) -> float:
	return float(get_level_data(level_index).get("target_time", 0.0))


static func get_clear_reward(level_index: int) -> float:
	return float(get_level_data(level_index).get("clear_reward", 0.0))


static func get_death_penalty(level_index: int) -> float:
	return float(get_level_data(level_index).get("death_penalty", 0.0))


static func get_speed_bonus(level_index: int) -> float:
	return float(get_level_data(level_index).get("speed_bonus", 0.0))
