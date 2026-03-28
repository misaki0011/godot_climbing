extends Node2D
class_name BaseLevel

@export var stage_name := "Level"
@export var camera_bounds := Rect2(0, 0, 1280, 720)
@export_file("*.svg", "*.png", "*.webp") var backdrop_texture_path := ""
@export var goal_offset := Vector2.ZERO


func _ready() -> void:
	_apply_backdrop_texture()


func get_stage_name() -> String:
	return stage_name


func get_spawn_position() -> Vector2:
	var spawn_point := get_node_or_null("SpawnPoint")
	if spawn_point:
		return spawn_point.global_position
	return global_position


func get_camera_bounds() -> Rect2:
	return camera_bounds


func _apply_backdrop_texture() -> void:
	var backdrop := get_node_or_null("TowerBackdrop") as Sprite2D
	if backdrop == null:
		return

	var original_backdrop_position := backdrop.position
	var texture := _load_backdrop_texture(backdrop_texture_path)
	backdrop.texture = texture
	_align_backdrop_to_ground(backdrop)
	_apply_level_alignment_offset(backdrop.position - original_backdrop_position)
	_extend_camera_to_backdrop_top(backdrop)
	_align_goal_to_backdrop(backdrop)


func _align_backdrop_to_ground(backdrop: Sprite2D) -> void:
	if backdrop.texture == null:
		return

	var spawn_position := get_spawn_position()
	var texture_size := backdrop.texture.get_size()
	var half_height := texture_size.y * absf(backdrop.scale.y) * 0.5
	backdrop.position = Vector2(spawn_position.x, spawn_position.y - half_height)


func _apply_level_alignment_offset(alignment_offset: Vector2) -> void:
	if alignment_offset.is_zero_approx():
		return

	for child in get_children():
		if child.name in ["TowerBackdrop", "SpawnPoint", "Goal"]:
			continue
		if child is Node2D:
			child.position += alignment_offset
		if child.has_method("apply_alignment_offset"):
			child.apply_alignment_offset(alignment_offset)

	var camera_bottom := camera_bounds.position.y + camera_bounds.size.y
	camera_bounds.position.y += alignment_offset.y
	camera_bounds.size.y = camera_bottom - camera_bounds.position.y


func _extend_camera_to_backdrop_top(backdrop: Sprite2D) -> void:
	if backdrop.texture == null:
		return

	var texture_size := backdrop.texture.get_size()
	var half_height := texture_size.y * absf(backdrop.scale.y) * 0.5
	var backdrop_top := backdrop.position.y - half_height
	var top_padding := 96.0
	var desired_camera_top := backdrop_top - top_padding
	if desired_camera_top >= camera_bounds.position.y:
		return

	var camera_bottom := camera_bounds.position.y + camera_bounds.size.y
	camera_bounds.position.y = desired_camera_top
	camera_bounds.size.y = camera_bottom - camera_bounds.position.y


func _align_goal_to_backdrop(backdrop: Sprite2D) -> void:
	var goal := get_node_or_null("Goal") as Node2D
	if goal == null or backdrop.texture == null:
		return

	var texture_size := backdrop.texture.get_size()
	var half_height := texture_size.y * absf(backdrop.scale.y) * 0.5
	goal.position = backdrop.position + Vector2(0, -half_height) + goal_offset


func _load_backdrop_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Backdrop texture not found: %s" % path)
		return null

	var image := Image.new()
	var extension := path.get_extension().to_lower()
	var error := OK
	if extension == "svg":
		var source := FileAccess.get_file_as_string(absolute_path)
		if source.is_empty():
			push_warning("Backdrop SVG could not be read: %s" % path)
			return null
		error = image.load_svg_from_string(source)
	else:
		error = image.load(absolute_path)

	if error != OK:
		push_warning("Backdrop texture could not be loaded: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
