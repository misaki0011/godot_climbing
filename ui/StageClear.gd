extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")
const UI_METRICS := preload("res://ui/UIMetrics.gd")

signal next_pressed
signal retry_pressed
signal back_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/NextButton.pressed.connect(func() -> void: next_pressed.emit())
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/RetryButton.pressed.connect(func() -> void: retry_pressed.emit())
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
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
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TitleLabel.text = "Tower Cleared" if is_final_level else "%s Clear" % stage_name
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/RewardLabel.text = "Reward: %.1f gems" % stage_reward
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/ClearRewardLabel.text = "+%.1f" % clear_reward
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyLabel.text = "Deaths x%d" % deaths
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyValueLabel.text = "-%.1f" % death_penalty
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusLabel.text = "Time %s/%s" % [time_text, target_time_text]
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusValueLabel.text = "+%.1f" % speed_bonus
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/NextButton.disabled = is_final_level


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var metrics: Dictionary = UI_METRICS.STAGE_CLEAR
	var window_size: Vector2 = Vector2(get_window().size)
	var outer_margin := float(metrics["outer_margin"]) * scale_factor
	var desired_panel_size: Vector2 = (metrics["panel_size"] as Vector2) * scale_factor
	var panel_size := Vector2(
		minf(desired_panel_size.x, maxf(metrics["panel_min"].x * scale_factor, window_size.x - outer_margin * 2.0)),
		minf(desired_panel_size.y, maxf(metrics["panel_min"].y * scale_factor, window_size.y - outer_margin * 2.0))
	)
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = panel_size
	var margin: MarginContainer = $CenterContainer/Panel/MarginContainer
	var horizontal_padding := minf(float(metrics["padding_x"]) * scale_factor, panel_size.x * 0.1)
	var top_padding := minf(float(metrics["padding_top"]) * scale_factor, panel_size.y * 0.06)
	var bottom_padding := minf(float(metrics["padding_bottom"]) * scale_factor, panel_size.y * 0.08)
	margin.add_theme_constant_override("margin_left", int(round(horizontal_padding)))
	margin.add_theme_constant_override("margin_top", int(round(top_padding)))
	margin.add_theme_constant_override("margin_right", int(round(horizontal_padding)))
	margin.add_theme_constant_override("margin_bottom", int(round(bottom_padding)))

	var box: VBoxContainer = $CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer
	box.custom_minimum_size = Vector2(maxf(float(metrics["content_min_width"]) * scale_factor, minf(panel_size.x - horizontal_padding * 2.0, float(metrics["content_max_width"]) * scale_factor)), 0.0)
	box.add_theme_constant_override("separation", int(round(float(metrics["content_spacing"]) * scale_factor)))

	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(float(metrics["title_font_size"]) * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/RewardLabel.add_theme_font_size_override("font_size", int(round(float(metrics["reward_font_size"]) * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownDivider.add_theme_font_size_override("font_size", int(round(float(metrics["divider_font_size"]) * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, float(metrics["back_gap"])) * scale_factor

	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid.add_theme_constant_override("h_separation", int(round(float(metrics["grid_h_spacing"]) * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid.add_theme_constant_override("v_separation", int(round(float(metrics["grid_v_spacing"]) * scale_factor)))

	for label_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/ClearValueLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/ClearRewardLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyValueLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusValueLabel",
	]:
		var label: Label = get_node(label_path) as Label
		label.add_theme_font_size_override("font_size", int(round(float(metrics["grid_font_size"]) * scale_factor)))

	for left_label_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/ClearValueLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusLabel",
	]:
		var left_label: Label = get_node(left_label_path) as Label
		left_label.custom_minimum_size = Vector2(float(metrics["grid_left_width"]), 0) * scale_factor

	for value_label_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/ClearRewardLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/DeathsPenaltyValueLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BreakdownGrid/TimeBonusValueLabel",
	]:
		var value_label: Label = get_node(value_label_path) as Label
		value_label.custom_minimum_size = Vector2(float(metrics["grid_value_width"]), 0) * scale_factor

	for button_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/NextButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	for button_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/RetryButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var back_button: Button = $CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackButton
	back_button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
	back_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(back_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)


func _get_mobile_scale() -> float:
	return UI_METRICS.get_menu_scale(get_window().size)
