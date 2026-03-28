extends CanvasLayer

signal debug_skip_pressed
signal pause_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$DebugSkipButton.pressed.connect(func() -> void: debug_skip_pressed.emit())
	$PauseButton.pressed.connect(func() -> void: pause_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func update_display(stage_name: String, time_text: String, target_time_text: String, deaths: int) -> void:
	$MarginContainer/VBoxContainer/StageLabel.text = stage_name
	$MarginContainer/VBoxContainer/TimerLabel.text = "Time: %s" % time_text
	$MarginContainer/VBoxContainer/TargetLabel.text = "Target: %s" % target_time_text
	$MarginContainer/VBoxContainer/DeathsLabel.text = "Deaths: %d" % deaths


func set_pause_state(is_paused: bool) -> void:
	$PauseButton.text = "RESUME" if is_paused else "PAUSE"
	$DebugSkipButton.visible = not is_paused


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale() * 2.0
	var margin: MarginContainer = $MarginContainer
	margin.offset_left = 24.0 * scale_factor
	margin.offset_top = 20.0 * scale_factor
	margin.offset_right = 440.0 * scale_factor
	margin.offset_bottom = 180.0 * scale_factor

	$MarginContainer/VBoxContainer/StageLabel.add_theme_font_size_override("font_size", int(round(24 * scale_factor)))
	$MarginContainer/VBoxContainer/TimerLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$MarginContainer/VBoxContainer/TargetLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$MarginContainer/VBoxContainer/DeathsLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))

	var skip_button: Button = $DebugSkipButton
	skip_button.offset_left = -228.0 * scale_factor
	skip_button.offset_top = 20.0 * scale_factor
	skip_button.offset_right = -24.0 * scale_factor
	skip_button.offset_bottom = 82.0 * scale_factor
	skip_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	_apply_button_style(skip_button, scale_factor, "debug")

	var pause_button: Button = $PauseButton
	pause_button.offset_left = 24.0 * scale_factor
	pause_button.offset_top = -150.0 * scale_factor
	pause_button.offset_right = 228.0 * scale_factor
	pause_button.offset_bottom = -88.0 * scale_factor
	pause_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	_apply_button_style(pause_button, scale_factor, "secondary")


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
	var hover_color := Color(0.4, 0.52, 0.72, 0.98)
	var pressed_color := Color(0.27, 0.38, 0.55, 0.98)
	match role:
		"secondary":
			normal.bg_color = Color(0.22, 0.28, 0.36, 0.96)
			normal.border_color = Color(0.43, 0.54, 0.66, 1.0)
			hover_color = Color(0.28, 0.35, 0.45, 0.98)
			pressed_color = Color(0.18, 0.24, 0.31, 0.98)
		"debug":
			normal.bg_color = Color(0.46, 0.31, 0.18, 0.96)
			normal.border_color = Color(0.83, 0.67, 0.42, 1.0)
			hover_color = Color(0.56, 0.38, 0.22, 0.98)
			pressed_color = Color(0.35, 0.24, 0.14, 0.98)
		_:
			normal.bg_color = Color(0.34, 0.45, 0.62, 0.96)
			normal.border_color = Color(0.62, 0.75, 0.95, 1.0)
	normal.set_corner_radius_all(corner_radius)
	normal.set_border_width_all(border_width)
	normal.content_margin_left = 16 * scale_factor
	normal.content_margin_right = 16 * scale_factor
	normal.content_margin_top = 10 * scale_factor
	normal.content_margin_bottom = 10 * scale_factor

	var hover := normal.duplicate()
	hover.bg_color = hover_color

	var pressed := normal.duplicate()
	pressed.bg_color = pressed_color

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
