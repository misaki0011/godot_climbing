extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")

signal start_pressed
signal how_to_play_pressed
signal quit_pressed

var music_on_icon: Texture2D = null
var music_off_icon: Texture2D = null


func _ready() -> void:
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/StartButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		start_pressed.emit()
	)
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/HowToPlayButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		how_to_play_pressed.emit()
	)
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/QuitButton.pressed.connect(func() -> void:
		AudioManager.notify_user_interaction()
		quit_pressed.emit()
	)
	$CenterContainer/Panel/MusicButton.pressed.connect(func() -> void:
		AudioManager.handle_music_toggle_interaction()
	)
	$CenterContainer/Panel/VBoxContainer/ArtCenter/TitleArtRect.texture = _load_title_texture("res://assets/cat_ninja_tower_title_v2.png")
	music_on_icon = _load_title_texture("res://assets/music_on.svg")
	music_off_icon = _load_title_texture("res://assets/music_off.svg")
	AudioManager.music_muted_changed.connect(_update_music_button_icon)
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()
	_update_music_button_icon(AudioManager.is_music_muted())


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var window_size: Vector2 = Vector2(get_window().size)
	var outer_margin := 24.0 * scale_factor
	var desired_panel_size := Vector2(580, 820) * scale_factor
	var panel_size := Vector2(
		minf(desired_panel_size.x, maxf(300.0 * scale_factor, window_size.x - outer_margin * 2.0)),
		minf(desired_panel_size.y, maxf(420.0 * scale_factor, window_size.y - outer_margin * 2.0))
	)
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = panel_size
	var panel_padding := minf(8.0 * scale_factor, panel_size.x * 0.025)
	var music_button: Button = $CenterContainer/Panel/MusicButton
	var music_button_size := minf(76.0 * scale_factor, panel_size.x * 0.16)
	var music_button_inset := maxf(10.0 * scale_factor, panel_padding + 4.0 * scale_factor)
	music_button.custom_minimum_size = Vector2(music_button_size, music_button_size)
	music_button.offset_left = -(music_button_inset + music_button_size)
	music_button.offset_top = music_button_inset
	music_button.offset_right = -music_button_inset
	music_button.offset_bottom = music_button_inset + music_button_size
	BUTTON_STYLES.apply_button_style(music_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	$CenterContainer/Panel/VBoxContainer.offset_left = panel_padding
	$CenterContainer/Panel/VBoxContainer.offset_top = panel_padding
	$CenterContainer/Panel/VBoxContainer.offset_right = panel_size.x - panel_padding
	$CenterContainer/Panel/VBoxContainer.offset_bottom = panel_size.y - panel_padding

	var art_size := Vector2(
		maxf(220.0 * scale_factor, panel_size.x - panel_padding * 2.0),
		minf(620.0 * scale_factor, panel_size.y * 0.66)
	)
	$CenterContainer/Panel/VBoxContainer/ArtCenter/TitleArtRect.custom_minimum_size = art_size
	$CenterContainer/Panel/VBoxContainer/Spacer.custom_minimum_size = Vector2(0, 12) * scale_factor
	$CenterContainer/Panel/VBoxContainer/ButtonArea.add_theme_constant_override("margin_left", int(round(minf(64.0 * scale_factor, panel_size.x * 0.12))))
	$CenterContainer/Panel/VBoxContainer/ButtonArea.add_theme_constant_override("margin_right", int(round(minf(64.0 * scale_factor, panel_size.x * 0.12))))
	$CenterContainer/Panel/VBoxContainer/ButtonArea.add_theme_constant_override("margin_top", int(round(10 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/ButtonArea.add_theme_constant_override("margin_bottom", int(round(10 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox.add_theme_constant_override("separation", int(round(14 * scale_factor)))
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/QuitGap.custom_minimum_size = Vector2(0, 18) * scale_factor

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/StartButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, 54) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	var how_to_play_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/HowToPlayButton
	how_to_play_button.custom_minimum_size = Vector2(0, 54) * scale_factor
	how_to_play_button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	BUTTON_STYLES.apply_button_style(how_to_play_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var quit_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/QuitButton
	quit_button.custom_minimum_size = Vector2(0, 54) * scale_factor
	quit_button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	BUTTON_STYLES.apply_button_style(quit_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)
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


func _load_title_texture(path: String) -> Texture2D:
	var import_metadata_path := "%s.import" % path
	if ResourceLoader.exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(import_metadata_path)):
		var resource := load(path)
		if resource is Texture2D:
			return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Title texture not found: %s" % path)
		return null

	if path.get_extension().to_lower() == "svg":
		var svg_text := FileAccess.get_file_as_string(absolute_path)
		if svg_text.is_empty():
			push_warning("Title texture could not be loaded: %s" % path)
			return null
		var svg_image := Image.new()
		var svg_error := svg_image.load_svg_from_string(svg_text)
		if svg_error != OK:
			push_warning("Title texture could not be loaded: %s" % path)
			return null
		return ImageTexture.create_from_image(svg_image)

	var image := Image.new()
	var error := image.load(absolute_path)
	if error != OK:
		push_warning("Title texture could not be loaded: %s" % path)
		return null

	return ImageTexture.create_from_image(image)


func _update_music_button_icon(is_muted: bool) -> void:
	var music_button: Button = $CenterContainer/Panel/MusicButton
	var show_muted := is_muted or not AudioManager.is_music_audible()
	music_button.icon = music_off_icon if show_muted else music_on_icon
	music_button.expand_icon = true
	music_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
