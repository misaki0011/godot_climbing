extends Node

signal route_changed(route: String, level_index: int)

const TITLE := "title"
const LEVEL_SELECT := "level_select"
const STAGE := "stage"
const STAGE_CLEAR := "stage_clear"

const LEVEL_SCENES := [
	"res://levels/Level01.tscn",
	"res://levels/Level02.tscn",
	"res://levels/Level03.tscn",
]

const LEVEL_NAMES := [
	"Level 1 - Tokyo Tower",
	"Level 2 - Skytree Sprint",
	"Level 3 - Burj Khalifa",
]

const LEVEL_TARGET_TIMES := [
	45.0,
	60.0,
	80.0,
]

var current_level_index := -1
var unlocked_levels := 1
var last_stage_stats: Dictionary = {}
var stage_rewards := [0.0, 0.0, 0.0]


func show_title() -> void:
	current_level_index = -1
	route_changed.emit(TITLE, -1)


func show_level_select() -> void:
	current_level_index = -1
	route_changed.emit(LEVEL_SELECT, -1)


func start_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVEL_SCENES.size():
		return
	current_level_index = level_index
	route_changed.emit(STAGE, level_index)


func retry_level() -> void:
	if current_level_index >= 0:
		route_changed.emit(STAGE, current_level_index)


func show_stage_clear(stats: Dictionary) -> void:
	last_stage_stats = stats
	route_changed.emit(STAGE_CLEAR, current_level_index)


func complete_current_level() -> void:
	if current_level_index < 0:
		return
	unlocked_levels = min(max(unlocked_levels, current_level_index + 2), LEVEL_SCENES.size())


func next_level() -> bool:
	var next_index := current_level_index + 1
	if next_index >= LEVEL_SCENES.size():
		return false
	start_level(next_index)
	return true


func get_level_scene(level_index: int) -> String:
	return LEVEL_SCENES[level_index]


func get_level_name(level_index: int) -> String:
	return LEVEL_NAMES[level_index]


func is_final_level(level_index: int) -> bool:
	return level_index == LEVEL_SCENES.size() - 1


func get_level_target_time(level_index: int) -> float:
	return LEVEL_TARGET_TIMES[level_index]


func get_level_target_time_text(level_index: int) -> String:
	return _format_time_text(LEVEL_TARGET_TIMES[level_index])


func get_all_target_time_texts() -> Array[String]:
	var target_texts: Array[String] = []
	for level_index in LEVEL_TARGET_TIMES.size():
		target_texts.append(get_level_target_time_text(level_index))
	return target_texts


func record_stage_reward(level_index: int, reward: float) -> void:
	if level_index < 0 or level_index >= stage_rewards.size():
		return
	stage_rewards[level_index] = maxf(stage_rewards[level_index], reward)


func get_total_gems() -> float:
	var total := 0.0
	for reward in stage_rewards:
		total += reward
	return snappedf(total, 0.1)


func get_stage_rewards() -> Array[float]:
	return stage_rewards.duplicate()


func get_stage_reward(level_index: int) -> float:
	if level_index < 0 or level_index >= stage_rewards.size():
		return 0.0
	return stage_rewards[level_index]


func _format_time_text(total_seconds: float) -> String:
	var total_msec := int(round(total_seconds * 1000.0))
	var minutes := total_msec / 60000
	var seconds := (total_msec / 1000) % 60
	var hundredths := (total_msec % 1000) / 10
	return "%02d:%02d.%02d" % [minutes, seconds, hundredths]
