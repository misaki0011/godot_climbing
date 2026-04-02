extends CanvasLayer

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")
const UI_METRICS := preload("res://ui/UIMetrics.gd")
var debug_button_enabled: bool = false

signal debug_skip_pressed
signal pause_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	debug_button_enabled = OS.is_debug_build()
	$DebugSkipButton.visible = debug_button_enabled
	if debug_button_enabled:
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
	$PauseButton.text = "PAUSE"
	$PauseButton.visible = not is_paused
	$DebugSkipButton.visible = debug_button_enabled and not is_paused


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var metrics: Dictionary = UI_METRICS.HUD
	var margin: MarginContainer = $MarginContainer
	margin.offset_left = float(metrics["margin_left"]) * scale_factor
	margin.offset_top = float(metrics["margin_top"]) * scale_factor
	margin.offset_right = float(metrics["margin_right"]) * scale_factor
	margin.offset_bottom = float(metrics["margin_bottom"]) * scale_factor

	$MarginContainer/VBoxContainer/StageLabel.add_theme_font_size_override("font_size", int(round(float(metrics["title_font_size"]) * scale_factor)))
	$MarginContainer/VBoxContainer/TimerLabel.add_theme_font_size_override("font_size", int(round(float(metrics["body_font_size"]) * scale_factor)))
	$MarginContainer/VBoxContainer/TargetLabel.add_theme_font_size_override("font_size", int(round(float(metrics["body_font_size"]) * scale_factor)))
	$MarginContainer/VBoxContainer/DeathsLabel.add_theme_font_size_override("font_size", int(round(float(metrics["body_font_size"]) * scale_factor)))

	var skip_button: Button = $DebugSkipButton
	skip_button.offset_left = float(metrics["debug_left"]) * scale_factor
	skip_button.offset_top = float(metrics["debug_top"]) * scale_factor
	skip_button.offset_right = float(metrics["debug_right"]) * scale_factor
	skip_button.offset_bottom = float(metrics["debug_bottom"]) * scale_factor
	skip_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(skip_button, scale_factor, BUTTON_STYLES.ROLE_DEBUG)

	var pause_button: Button = $PauseButton
	pause_button.offset_left = float(metrics["pause_left"]) * scale_factor
	pause_button.offset_top = float(metrics["pause_top"]) * scale_factor
	pause_button.offset_right = float(metrics["pause_right"]) * scale_factor
	pause_button.offset_bottom = float(metrics["pause_bottom"]) * scale_factor
	pause_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(pause_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)


func _get_mobile_scale() -> float:
	return UI_METRICS.get_ui_scale(get_window().size)
