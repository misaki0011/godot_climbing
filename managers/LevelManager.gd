extends Node

signal hud_updated(stage_name: String, time_text: String, deaths: int)
signal stage_cleared(stats: Dictionary)

var current_level: Node = null
var player: Node = null
var respawn_position := Vector2.ZERO
var death_count := 0
var elapsed_time := 0.0
var running := false
var stage_name := ""


func _ready() -> void:
	add_to_group("level_manager")


func _process(delta: float) -> void:
	if not running:
		return
	elapsed_time += delta
	_emit_hud_update()


func setup_level(level_root: Node, player_ref: Node, level_stage_name: String, spawn_position: Vector2) -> void:
	current_level = level_root
	player = player_ref
	stage_name = level_stage_name
	respawn_position = spawn_position
	death_count = 0
	elapsed_time = 0.0
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
	stage_cleared.emit({
		"stage_name": stage_name,
		"time_text": get_time_text(),
		"deaths": death_count,
	})


func get_time_text() -> String:
	var total_msec := int(round(elapsed_time * 1000.0))
	var minutes := total_msec / 60000
	var seconds := (total_msec / 1000) % 60
	var hundredths := (total_msec % 1000) / 10
	return "%02d:%02d.%02d" % [minutes, seconds, hundredths]


func _emit_hud_update() -> void:
	hud_updated.emit(stage_name, get_time_text(), death_count)

