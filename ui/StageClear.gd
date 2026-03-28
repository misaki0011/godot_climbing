extends Control

signal next_pressed
signal retry_pressed
signal back_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/Panel/VBoxContainer/NextButton.pressed.connect(func() -> void: next_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/RetryButton.pressed.connect(func() -> void: retry_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func set_results(
	stage_name: String,
	time_text: String,
	deaths: int,
	target_time_text: String,
	stage_reward: float,
	is_final_level: bool,
	clear_reward: float,
	death_penalty: float,
	speed_bonus: float
) -> void:
	$CenterContainer/Panel/VBoxContainer/TitleLabel.text = "Tower Cleared" if is_final_level else "%s Clear" % stage_name
	$CenterContainer/Panel/VBoxContainer/RewardLabel.text = "Reward: %.1f gems" % stage_reward
	$CenterContainer/Panel/VBoxContainer/ClearRow/ClearRewardLabel.text = "+%.1f" % clear_reward
	$CenterContainer/Panel/VBoxContainer/DeathsRow/DeathsPenaltyLabel.text = "Deaths x%d" % deaths
	$CenterContainer/Panel/VBoxContainer/DeathsRow/DeathsPenaltyValueLabel.text = "-%.1f" % death_penalty
	$CenterContainer/Panel/VBoxContainer/TimeRow/TimeBonusLabel.text = "Time %s/%s" % [time_text, target_time_text]
	$CenterContainer/Panel/VBoxContainer/TimeRow/TimeBonusValueLabel.text = "+%.1f" % speed_bonus
	$CenterContainer/Panel/VBoxContainer/NextButton.disabled = is_final_level


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale() * 2.0
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(400, 380) * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = 32.0 * scale_factor
	box.offset_top = 24.0 * scale_factor
	box.offset_right = 368.0 * scale_factor
	box.offset_bottom = 348.0 * scale_factor
	box.add_theme_constant_override("separation", int(round(12 * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(28 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/RewardLabel.add_theme_font_size_override("font_size", int(round(22 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/BreakdownDivider.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, 18) * scale_factor

	for row_path in [
		"CenterContainer/Panel/VBoxContainer/ClearRow",
		"CenterContainer/Panel/VBoxContainer/DeathsRow",
		"CenterContainer/Panel/VBoxContainer/TimeRow",
	]:
		var row: HBoxContainer = get_node(row_path) as HBoxContainer
		row.add_theme_constant_override("separation", int(round(12 * scale_factor)))

	for label_path in [
		"CenterContainer/Panel/VBoxContainer/ClearRow/ClearValueLabel",
		"CenterContainer/Panel/VBoxContainer/ClearRow/ClearRewardLabel",
		"CenterContainer/Panel/VBoxContainer/DeathsRow/DeathsPenaltyLabel",
		"CenterContainer/Panel/VBoxContainer/DeathsRow/DeathsPenaltyValueLabel",
		"CenterContainer/Panel/VBoxContainer/TimeRow/TimeBonusLabel",
		"CenterContainer/Panel/VBoxContainer/TimeRow/TimeBonusValueLabel",
	]:
		var label: Label = get_node(label_path) as Label
		label.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))

	for value_label_path in [
		"CenterContainer/Panel/VBoxContainer/ClearRow/ClearRewardLabel",
		"CenterContainer/Panel/VBoxContainer/DeathsRow/DeathsPenaltyValueLabel",
		"CenterContainer/Panel/VBoxContainer/TimeRow/TimeBonusValueLabel",
	]:
		var value_label: Label = get_node(value_label_path) as Label
		value_label.custom_minimum_size = Vector2(78, 0) * scale_factor

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/NextButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 58) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
		_apply_button_style(button, scale_factor, "primary")

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/RetryButton",
		"CenterContainer/Panel/VBoxContainer/BackButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 58) * scale_factor
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
