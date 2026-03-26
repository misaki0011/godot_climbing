extends Control

signal level_selected(level_index: int)
signal back_pressed


func _ready() -> void:
	$CenterContainer/Panel/VBoxContainer/Level1Button.pressed.connect(func() -> void: level_selected.emit(0))
	$CenterContainer/Panel/VBoxContainer/Level2Button.pressed.connect(func() -> void: level_selected.emit(1))
	$CenterContainer/Panel/VBoxContainer/Level3Button.pressed.connect(func() -> void: level_selected.emit(2))
	$CenterContainer/Panel/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func set_unlocked_levels(unlocked_levels: int) -> void:
	$CenterContainer/Panel/VBoxContainer/Level1Button.disabled = unlocked_levels < 1
	$CenterContainer/Panel/VBoxContainer/Level2Button.disabled = unlocked_levels < 2
	$CenterContainer/Panel/VBoxContainer/Level3Button.disabled = unlocked_levels < 3


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(460, 350) * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = 40.0 * scale_factor
	box.offset_top = 28.0 * scale_factor
	box.offset_right = 420.0 * scale_factor
	box.offset_bottom = 318.0 * scale_factor
	box.add_theme_constant_override("separation", int(round(12 * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(32 * scale_factor)))

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/Level1Button",
		"CenterContainer/Panel/VBoxContainer/Level2Button",
		"CenterContainer/Panel/VBoxContainer/Level3Button",
		"CenterContainer/Panel/VBoxContainer/BackButton",
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
