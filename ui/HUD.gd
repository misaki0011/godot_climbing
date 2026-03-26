extends CanvasLayer

signal climb_pressed
signal restart_pressed
signal pause_pressed

var last_debug_text := ""


func _ready() -> void:
	$TouchControls/LeftControls/RestartButton.pressed.connect(func() -> void: restart_pressed.emit())
	$TouchControls/RightControls/VBoxContainer/PauseButton.pressed.connect(func() -> void: pause_pressed.emit())
	$TouchControls/RightControls/VBoxContainer/ClimbButton.pressed.connect(func() -> void: climb_pressed.emit())
	$DebugPanel.visible = OS.has_feature("web")
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func update_display(stage_name: String, time_text: String, deaths: int) -> void:
	$MarginContainer/VBoxContainer/StageLabel.text = stage_name
	$MarginContainer/VBoxContainer/TimerLabel.text = "Time: %s" % time_text
	$MarginContainer/VBoxContainer/DeathsLabel.text = "Deaths: %d" % deaths


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale() * 2.0
	var margin: MarginContainer = $MarginContainer
	margin.offset_left = 24.0 * scale_factor
	margin.offset_top = 20.0 * scale_factor
	margin.offset_right = 360.0 * scale_factor
	margin.offset_bottom = 140.0 * scale_factor

	$MarginContainer/VBoxContainer/StageLabel.add_theme_font_size_override("font_size", int(round(24 * scale_factor)))
	$MarginContainer/VBoxContainer/TimerLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$MarginContainer/VBoxContainer/DeathsLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))

	var restart_button: Button = $TouchControls/LeftControls/RestartButton
	restart_button.custom_minimum_size = Vector2(188, 92) * scale_factor
	restart_button.add_theme_font_size_override("font_size", int(round(24 * scale_factor)))

	var right_controls: MarginContainer = $TouchControls/RightControls
	right_controls.offset_left = -276.0 * scale_factor
	right_controls.offset_top = -206.0 * scale_factor
	right_controls.offset_right = -16.0 * scale_factor
	right_controls.offset_bottom = -16.0 * scale_factor

	var pause_button: Button = $TouchControls/RightControls/VBoxContainer/PauseButton
	pause_button.custom_minimum_size = Vector2(260, 76) * scale_factor
	pause_button.add_theme_font_size_override("font_size", int(round(22 * scale_factor)))

	var climb_button: Button = $TouchControls/RightControls/VBoxContainer/ClimbButton
	climb_button.custom_minimum_size = Vector2(260, 120) * scale_factor
	climb_button.add_theme_font_size_override("font_size", int(round(34 * scale_factor)))

	_update_debug_info(scale_factor)


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


func _update_debug_info(scale_factor: float) -> void:
	if not $DebugPanel.visible:
		return

	$DebugPanel.offset_left = 12.0 * scale_factor
	$DebugPanel.offset_top = 150.0 * scale_factor
	$DebugPanel.offset_right = 300.0 * scale_factor
	$DebugPanel.offset_bottom = 250.0 * scale_factor
	$DebugPanel/DebugLabel.offset_left = 10.0 * scale_factor
	$DebugPanel/DebugLabel.offset_top = 10.0 * scale_factor
	$DebugPanel/DebugLabel.offset_right = 278.0 * scale_factor
	$DebugPanel/DebugLabel.offset_bottom = 88.0 * scale_factor
	$DebugPanel/DebugLabel.add_theme_font_size_override("font_size", int(round(14 * scale_factor)))

	var window_size: Vector2i = get_window().size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var orientation := "portrait" if window_size.y > window_size.x else "landscape"
	var debug_text := "window: %dx%d\nviewport: %.0fx%.0f\norientation: %s\nscale: %.2f" % [
		window_size.x,
		window_size.y,
		viewport_size.x,
		viewport_size.y,
		orientation,
		scale_factor,
	]
	$DebugPanel/DebugLabel.text = debug_text
	if debug_text != last_debug_text:
		last_debug_text = debug_text
		print("[HUD DEBUG] %s" % debug_text.replace("\n", " | "))
