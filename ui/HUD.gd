extends CanvasLayer

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")
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
	BUTTON_STYLES.apply_button_style(skip_button, scale_factor, BUTTON_STYLES.ROLE_DEBUG)

	var pause_button: Button = $PauseButton
	pause_button.offset_left = 24.0 * scale_factor
	pause_button.offset_top = -150.0 * scale_factor
	pause_button.offset_right = 228.0 * scale_factor
	pause_button.offset_bottom = -88.0 * scale_factor
	pause_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	BUTTON_STYLES.apply_button_style(pause_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)


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
