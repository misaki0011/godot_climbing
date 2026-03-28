extends Node

signal hud_updated(stage_name: String, time_text: String, target_time_text: String, deaths: int)
signal stage_cleared(stats: Dictionary)

var current_level: Node = null
var player: Node = null
var respawn_position := Vector2.ZERO
var death_count := 0
var elapsed_time := 0.0
var running := false
var stage_name := ""
var target_time_seconds := 0.0


func _ready() -> void:
	add_to_group("level_manager")


func _process(delta: float) -> void:
	if not running:
		return
	elapsed_time += delta
	_emit_hud_update()


func setup_level(level_root: Node, player_ref: Node, level_stage_name: String, spawn_position: Vector2, target_time: float) -> void:
	current_level = level_root
	player = player_ref
	stage_name = level_stage_name
	respawn_position = spawn_position
	death_count = 0
	elapsed_time = 0.0
	target_time_seconds = target_time
	running = true
	_emit_hud_update()


func register_checkpoint(checkpoint_position: Vector2) -> void:
	respawn_position = checkpoint_position
	AudioManager.play_sfx("checkpoint")


func kill_player() -> void:
	if player == null:
		return
	death_count += 1
	AudioManager.play_sfx("death")
	player.respawn(respawn_position)
	_emit_hud_update()


func complete_level() -> void:
	if not running:
		return
	running = false
	AudioManager.play_sfx("clear")
	var speed_bonus := 0.3 if elapsed_time <= target_time_seconds else 0.0
	var stage_reward := maxf(0.0, 1.0 - death_count * 0.2 + speed_bonus)
	stage_cleared.emit({
		"stage_name": stage_name,
		"time_text": get_time_text(),
		"deaths": death_count,
		"death_penalty": snappedf(death_count * 0.2, 0.1),
		"clear_reward": 1.0,
		"speed_bonus": speed_bonus,
		"target_time_text": _format_time_text(target_time_seconds),
		"reached_target": elapsed_time <= target_time_seconds,
		"stage_reward": snappedf(stage_reward, 0.1),
	})


func get_time_text() -> String:
	return _format_time_text(elapsed_time)


func _format_time_text(total_seconds: float) -> String:
	var total_msec := int(round(total_seconds * 1000.0))
	var minutes := total_msec / 60000
	var seconds := (total_msec / 1000) % 60
	var hundredths := (total_msec % 1000) / 10
	return "%02d:%02d.%02d" % [minutes, seconds, hundredths]


func _emit_hud_update() -> void:
	hud_updated.emit(stage_name, get_time_text(), _format_time_text(target_time_seconds), death_count)
