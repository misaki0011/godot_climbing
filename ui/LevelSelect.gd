extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")

signal level_selected(level_index: int)
signal back_pressed

var pending_unlocked_levels := 1
var pending_total_gems := 0.0
var pending_level_rewards := [0.0, 0.0, 0.0]
const LOCKED_GEM_COLOR := Color(0.55, 0.55, 0.58, 1.0)
const UNLOCKED_GEM_COLOR := Color(0.95, 0.95, 0.97, 1.0)


func _ready() -> void:
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1Button.pressed.connect(func() -> void: level_selected.emit(0))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2Button.pressed.connect(func() -> void: level_selected.emit(1))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3Button.pressed.connect(func() -> void: level_selected.emit(2))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_pending_data()
	_apply_layout_scale()


func set_unlocked_levels(unlocked_levels: int) -> void:
	pending_unlocked_levels = unlocked_levels
	if not is_inside_tree():
		return
	_apply_unlocked_levels()


func set_total_gems(total_gems: float) -> void:
	pending_total_gems = total_gems
	if not is_inside_tree():
		return
	_apply_total_gems()


func set_level_rewards(reward_values: Array) -> void:
	pending_level_rewards = reward_values.duplicate()
	if not is_inside_tree():
		return
	_apply_level_rewards()


func _apply_pending_data() -> void:
	_apply_unlocked_levels()
	_apply_total_gems()
	_apply_level_rewards()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var window_size: Vector2 = Vector2(get_window().size)
	var outer_margin := 24.0 * scale_factor
	var desired_panel_size := Vector2(560, 620) * scale_factor
	var panel_size := Vector2(
		minf(desired_panel_size.x, maxf(280.0 * scale_factor, window_size.x - outer_margin * 2.0)),
		minf(desired_panel_size.y, maxf(360.0 * scale_factor, window_size.y - outer_margin * 2.0))
	)
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = panel_size
	var margin: MarginContainer = $CenterContainer/Panel/MarginContainer
	var horizontal_padding := minf(48.0 * scale_factor, panel_size.x * 0.1)
	var top_padding := minf(28.0 * scale_factor, panel_size.y * 0.06)
	var bottom_padding := minf(32.0 * scale_factor, panel_size.y * 0.05)
	margin.add_theme_constant_override("margin_left", int(round(horizontal_padding)))
	margin.add_theme_constant_override("margin_top", int(round(top_padding)))
	margin.add_theme_constant_override("margin_right", int(round(horizontal_padding)))
	margin.add_theme_constant_override("margin_bottom", int(round(bottom_padding)))

	var box: VBoxContainer = $CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer
	box.custom_minimum_size = Vector2(maxf(320.0 * scale_factor, minf(panel_size.x - horizontal_padding * 2.0, 440.0 * scale_factor)), 0.0)
	box.add_theme_constant_override("separation", int(round(12 * scale_factor)))

	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(32 * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow.add_theme_constant_override("separation", int(round(8 * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow/TotalGemLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow/TotalGemColonLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow/TotalGemValueLabel.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow/TotalGemIcon.custom_minimum_size = Vector2(24, 24) * scale_factor
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, 22) * scale_factor

	for button_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1Button",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2Button",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3Button",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 74) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	for button_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level4Row/Level4Button",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 74) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	var back_button: Button = $CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/BackButton
	back_button.custom_minimum_size = Vector2(0, 74) * scale_factor
	back_button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	BUTTON_STYLES.apply_button_style(back_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)

	for label_path in [
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1RewardLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2RewardLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3RewardLabel",
		"CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level4Row/Level4RewardLabel",
	]:
		var label: Label = get_node(label_path) as Label
		label.custom_minimum_size = Vector2(56, 0) * scale_factor
		label.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))


func _apply_unlocked_levels() -> void:
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1Button.disabled = pending_unlocked_levels < 1
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2Button.disabled = pending_unlocked_levels < 2
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3Button.disabled = pending_unlocked_levels < 3
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level4Row/Level4Button.disabled = true

	var reward_labels := [
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level4Row/Level4RewardLabel,
	]
	for level_index in reward_labels.size():
		var reward_label: Label = reward_labels[level_index]
		if level_index == 3:
			reward_label.modulate = LOCKED_GEM_COLOR
		else:
			reward_label.modulate = UNLOCKED_GEM_COLOR if pending_unlocked_levels >= level_index + 1 else LOCKED_GEM_COLOR


func _apply_total_gems() -> void:
	$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/TotalGemRow/TotalGemValueLabel.text = "%.1f" % pending_total_gems


func _apply_level_rewards() -> void:
	var reward_labels := [
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level1Row/Level1RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level2Row/Level2RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level3Row/Level3RewardLabel,
		$CenterContainer/Panel/MarginContainer/InnerCenter/VBoxContainer/Level4Row/Level4RewardLabel,
	]
	for level_index in reward_labels.size():
		if level_index >= 3:
			reward_labels[level_index].text = "-"
			continue
		var reward_value := GameManager.get_stage_reward(level_index)
		if level_index < pending_level_rewards.size():
			reward_value = maxf(reward_value, float(pending_level_rewards[level_index]))
		reward_labels[level_index].text = "%.1f" % reward_value


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
	return clampf(base_scale * 2.0, 2.0, 9.0)
