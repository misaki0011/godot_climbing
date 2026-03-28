extends Control

signal restart_pressed
signal level_select_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBoxContainer/RestartButton.pressed.connect(func() -> void: restart_pressed.emit())
	$Panel/VBoxContainer/LevelSelectButton.pressed.connect(func() -> void: level_select_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $Panel
	panel.custom_minimum_size = Vector2(360, 152) * scale_factor
	panel.offset_left = 24.0 * scale_factor
	panel.offset_top = -396.0 * scale_factor
	panel.offset_right = 384.0 * scale_factor
	panel.offset_bottom = -170.0 * scale_factor

	var box: VBoxContainer = $Panel/VBoxContainer
	box.offset_left = 36.0 * scale_factor
	box.offset_top = 28.0 * scale_factor
	box.offset_right = 324.0 * scale_factor
	box.offset_bottom = 122.0 * scale_factor
	box.add_theme_constant_override("separation", int(round(10 * scale_factor)))

	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(28 * scale_factor)))
	$Panel/VBoxContainer/ExitGap.custom_minimum_size = Vector2(0, 18) * scale_factor

	for button_path in [
		"Panel/VBoxContainer/RestartButton",
		"Panel/VBoxContainer/LevelSelectButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 56) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
		_apply_button_style(button, scale_factor, "secondary")


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


func _apply_button_style(button: Button, scale_factor: float, role: String) -> void:
	var corner_radius := int(round(16 * scale_factor))
	var border_width := int(round(maxf(2.0, 2.0 * scale_factor)))

	var normal := StyleBoxFlat.new()
	var hover_color := Color(0.4, 0.52, 0.72, 1.0)
	var pressed_color := Color(0.27, 0.38, 0.55, 1.0)
	match role:
		"secondary":
			normal.bg_color = Color(0.22, 0.28, 0.36, 1.0)
			normal.border_color = Color(0.43, 0.54, 0.66, 1.0)
			hover_color = Color(0.28, 0.35, 0.45, 1.0)
			pressed_color = Color(0.18, 0.24, 0.31, 1.0)
		_:
			normal.bg_color = Color(0.34, 0.45, 0.62, 1.0)
			normal.border_color = Color(0.62, 0.75, 0.95, 1.0)
	normal.set_corner_radius_all(corner_radius)
	normal.set_border_width_all(border_width)
	normal.content_margin_left = 18 * scale_factor
	normal.content_margin_right = 18 * scale_factor
	normal.content_margin_top = 12 * scale_factor
	normal.content_margin_bottom = 12 * scale_factor

	var hover := normal.duplicate()
	hover.bg_color = hover_color

	var pressed := normal.duplicate()
	pressed.bg_color = pressed_color

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.14, 0.16, 0.19, 0.9)
	disabled.border_color = Color(0.24, 0.27, 0.31, 0.95)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_disabled_color", Color(0.46, 0.49, 0.54, 1.0))
