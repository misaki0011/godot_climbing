extends Control

signal next_pressed
signal retry_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/Panel/VBoxContainer/RetryButton.pressed.connect(func() -> void: retry_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/NextButton.pressed.connect(func() -> void: next_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func set_results(stage_name: String, time_text: String, deaths: int, is_final_level: bool) -> void:
	$CenterContainer/Panel/VBoxContainer/TitleLabel.text = "Tower Cleared" if is_final_level else "%s Clear" % stage_name
	$CenterContainer/Panel/VBoxContainer/TimeLabel.text = "Time: %s" % time_text
	$CenterContainer/Panel/VBoxContainer/DeathsLabel.text = "Deaths: %d" % deaths
	$CenterContainer/Panel/VBoxContainer/NextButton.text = "Back to Select" if is_final_level else "Next Level"


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(400, 330) * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = 32.0 * scale_factor
	box.offset_top = 24.0 * scale_factor
	box.offset_right = 368.0 * scale_factor
	box.offset_bottom = 298.0 * scale_factor
	box.add_theme_constant_override("separation", int(round(12 * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(28 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/TimeLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/DeathsLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/RetryButton",
		"CenterContainer/Panel/VBoxContainer/NextButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 58) * scale_factor
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
