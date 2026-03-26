extends Control

signal start_pressed
signal quit_pressed


func _ready() -> void:
	$CenterContainer/Panel/VBoxContainer/StartButton.pressed.connect(func() -> void: start_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/QuitButton.pressed.connect(func() -> void: quit_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(420, 280) * scale_factor

	$CenterContainer/Panel/VBoxContainer.offset_left = 40.0 * scale_factor
	$CenterContainer/Panel/VBoxContainer.offset_top = 32.0 * scale_factor
	$CenterContainer/Panel/VBoxContainer.offset_right = 380.0 * scale_factor
	$CenterContainer/Panel/VBoxContainer.offset_bottom = 248.0 * scale_factor

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(42 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/SubtitleLabel.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/Spacer.custom_minimum_size = Vector2(0, 20) * scale_factor

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/StartButton",
		"CenterContainer/Panel/VBoxContainer/QuitButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 54) * scale_factor
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
