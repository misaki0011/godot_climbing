extends CharacterBody2D

signal restart_requested

@export var step_height := 52.0
@export var step_duration := 0.16
@export var sway_distance := 10.0

@onready var body_polygon: Polygon2D = $Body
@onready var camera: Camera2D = $Camera2D

var respawning := false
var ladder_x := 0.0
var step_start_position := Vector2.ZERO
var step_target_position := Vector2.ZERO
var step_elapsed := 0.0
var step_in_progress := false
var sway_direction := 1.0
var default_body_color := Color(0.35, 0.75, 1.0)


func _ready() -> void:
	add_to_group("player")
	default_body_color = body_polygon.color


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		request_restart()

	if respawning:
		return

	if Input.is_action_just_pressed("jump") and not step_in_progress:
		try_climb()

	if step_in_progress:
		step_elapsed = min(step_elapsed + delta, step_duration)
		var progress := step_elapsed / step_duration
		var eased := ease(progress, -2.0)
		var current_position := step_start_position.lerp(step_target_position, eased)
		current_position.x = ladder_x + sin(progress * PI) * sway_distance * sway_direction
		global_position = current_position
		if progress >= 1.0:
			step_in_progress = false
			global_position = step_target_position
			body_polygon.scale.x = sway_direction
			sway_direction *= -1.0
	else:
		global_position.x = ladder_x


func request_restart() -> void:
	restart_requested.emit()


func try_climb() -> void:
	if respawning or step_in_progress:
		return
	_begin_step()


func _begin_step() -> void:
	step_in_progress = true
	step_elapsed = 0.0
	step_start_position = global_position
	step_target_position = Vector2(ladder_x, global_position.y - step_height)
	AudioManager.play_sfx("climb")


func respawn(respawn_position: Vector2) -> void:
	set_climb_anchor(respawn_position)
	respawning = true
	body_polygon.color = Color(1.0, 0.95, 0.55)
	await get_tree().create_timer(0.08).timeout
	body_polygon.color = default_body_color
	respawning = false


func configure_camera(bounds: Rect2) -> void:
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.position.x + bounds.size.x)
	camera.limit_bottom = int(bounds.position.y + bounds.size.y)


func is_respawning() -> bool:
	return respawning


func set_climb_anchor(anchor_position: Vector2) -> void:
	ladder_x = anchor_position.x
	step_in_progress = false
	step_elapsed = 0.0
	step_start_position = anchor_position
	step_target_position = anchor_position
	global_position = anchor_position
