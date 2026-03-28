extends CharacterBody2D

signal restart_requested

const NINJA_TEXTURE_PATHS := [
	"res://assets/cat_ninja_climb_tp_frame01.png",
	"res://assets/cat_ninja_climb_tp_frame02.png",
]

@export var step_height := 52.0
@export var step_duration := 0.16
@export var sway_distance := 10.0

@onready var visual_root: Node2D = $VisualRoot
@onready var body_sprite: Sprite2D = $VisualRoot/BodySprite
@onready var camera: Camera2D = $Camera2D

var respawning := false
var ladder_x := 0.0
var step_start_position := Vector2.ZERO
var step_target_position := Vector2.ZERO
var step_elapsed := 0.0
var step_in_progress := false
var sway_direction := 1.0
var default_visual_modulate := Color.WHITE
var body_frames: Array[Texture2D] = []
var current_frame_index := 0


func _ready() -> void:
	add_to_group("player")
	default_visual_modulate = visual_root.modulate
	_apply_body_frames()


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
	_advance_body_frame()
	AudioManager.play_sfx("climb")


func respawn(respawn_position: Vector2) -> void:
	set_climb_anchor(respawn_position)
	respawning = true
	visual_root.modulate = Color(1.0, 0.95, 0.55)
	await get_tree().create_timer(0.08).timeout
	visual_root.modulate = default_visual_modulate
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
	_show_body_frame(0)


func _apply_body_frames() -> void:
	body_frames.clear()
	for path in NINJA_TEXTURE_PATHS:
		var texture := _load_body_texture(path)
		if texture != null:
			body_frames.append(texture)
	_show_body_frame(0)


func _advance_body_frame() -> void:
	if body_frames.is_empty():
		return
	current_frame_index = (current_frame_index + 1) % body_frames.size()
	body_sprite.texture = body_frames[current_frame_index]


func _show_body_frame(frame_index: int) -> void:
	if body_frames.is_empty():
		return
	current_frame_index = clampi(frame_index, 0, body_frames.size() - 1)
	body_sprite.texture = body_frames[current_frame_index]


func _load_body_texture(path: String) -> Texture2D:
	var resource := load(path)
	if resource is Texture2D:
		return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Player sprite not found: %s" % path)
		return null

	var image := Image.new()
	var error := image.load_svg_from_string(FileAccess.get_file_as_string(absolute_path))
	if error != OK:
		push_warning("Player sprite could not be loaded: %s" % path)
		return null
	return ImageTexture.create_from_image(image)
