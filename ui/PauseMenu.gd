extends Control

signal resume_pressed
signal restart_pressed
signal level_select_pressed
signal title_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/Panel/VBoxContainer/ResumeButton.pressed.connect(func() -> void: resume_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/RestartButton.pressed.connect(func() -> void: restart_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/LevelSelectButton.pressed.connect(func() -> void: level_select_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/TitleButton.pressed.connect(func() -> void: title_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(360, 300) * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = 36.0 * scale_factor
	box.offset_top = 28.0 * scale_factor
	box.offset_right = 324.0 * scale_factor
	box.offset_bottom = 270.0 * scale_factor
	box.add_theme_constant_override("separation", int(round(10 * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(28 * scale_factor)))

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/ResumeButton",
		"CenterContainer/Panel/VBoxContainer/RestartButton",
		"CenterContainer/Panel/VBoxContainer/LevelSelectButton",
		"CenterContainer/Panel/VBoxContainer/TitleButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 56) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))


func _get_mobile_scale() -> float:
	var window_size: Vector2i = get_window().size
	var width: float = float(window_size.x)
	var height: float = float(window_size.y)
	if width <= 0.0 or height <= 0.0:
		return 1.0
	var base_width: float = float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var base_height: float = float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var width_scale: float = base_width / width
	var height_scale: float = base_height / height
	var base_scale: float = maxf(1.0, maxf(width_scale, height_scale))
	if height > width:
		base_scale *= 1.25
	return clampf(base_scale, 1.0, 4.5)
