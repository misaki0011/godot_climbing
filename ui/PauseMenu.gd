extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")

signal restart_pressed
signal level_select_pressed
signal resume_pressed

var music_on_icon: Texture2D = null
var music_off_icon: Texture2D = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBoxContainer/TopRow/RestartButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		restart_pressed.emit()
	)
	$Panel/VBoxContainer/BackButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		level_select_pressed.emit()
	)
	$Panel/VBoxContainer/ResumeButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		resume_pressed.emit()
	)
	$Panel/VBoxContainer/TopRow/MusicButton.pressed.connect(func() -> void:
		AudioManager.handle_music_toggle_interaction()
	)
	music_on_icon = _load_ui_texture("res://assets/music_on.svg")
	music_off_icon = _load_ui_texture("res://assets/music_off.svg")
	AudioManager.music_muted_changed.connect(_update_music_button_icon)
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()
	_update_music_button_icon(AudioManager.is_music_muted())


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $Panel
	panel.custom_minimum_size = Vector2(204, 214) * scale_factor
	panel.offset_left = 24.0 * scale_factor
	panel.offset_top = -302.0 * scale_factor
	panel.offset_right = 228.0 * scale_factor
	panel.offset_bottom = -88.0 * scale_factor

	var box: VBoxContainer = $Panel/VBoxContainer
	box.offset_left = 0.0
	box.offset_top = 0.0
	box.offset_right = 0.0
	box.offset_bottom = 0.0
	box.add_theme_constant_override("separation", int(round(10 * scale_factor)))
	$Panel/VBoxContainer/TopRow.add_theme_constant_override("separation", int(round(10 * scale_factor)))

	$Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(28 * scale_factor)))
	$Panel/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, 18) * scale_factor
	var top_row: HBoxContainer = $Panel/VBoxContainer/TopRow
	top_row.custom_minimum_size = Vector2(204, 62) * scale_factor

	var resume_button: Button = $Panel/VBoxContainer/ResumeButton
	resume_button.custom_minimum_size = Vector2(204, 62) * scale_factor
	resume_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	BUTTON_STYLES.apply_button_style(resume_button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	var restart_button: Button = $Panel/VBoxContainer/TopRow/RestartButton
	restart_button.custom_minimum_size = Vector2(130, 62) * scale_factor
	restart_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	BUTTON_STYLES.apply_button_style(restart_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var music_button: Button = $Panel/VBoxContainer/TopRow/MusicButton
	music_button.custom_minimum_size = Vector2(64, 62) * scale_factor
	BUTTON_STYLES.apply_button_style(music_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var back_button: Button = $Panel/VBoxContainer/BackButton
	back_button.custom_minimum_size = Vector2(204, 62) * scale_factor
	back_button.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))
	BUTTON_STYLES.apply_button_style(back_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)
	_update_music_button_icon(AudioManager.is_music_muted())


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


func _load_ui_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("UI texture could not be loaded: %s" % path)
		return null

	if path.get_extension().to_lower() == "svg":
		var svg_text := FileAccess.get_file_as_string(absolute_path)
		if svg_text.is_empty():
			push_warning("UI texture could not be loaded: %s" % path)
			return null
		var svg_image := Image.new()
		var svg_error := svg_image.load_svg_from_string(svg_text)
		if svg_error != OK:
			push_warning("UI texture could not be loaded: %s" % path)
			return null
		return ImageTexture.create_from_image(svg_image)

	var image := Image.new()
	var error := image.load(absolute_path)
	if error != OK:
		push_warning("UI texture could not be loaded: %s" % path)
		return null
	return ImageTexture.create_from_image(image)


func _update_music_button_icon(is_muted: bool) -> void:
	var music_button: Button = $Panel/VBoxContainer/TopRow/MusicButton
	var show_muted := is_muted or not AudioManager.is_music_audible()
	music_button.icon = music_off_icon if show_muted else music_on_icon
	music_button.expand_icon = true
	music_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
