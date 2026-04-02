extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")
const UI_METRICS := preload("res://ui/UIMetrics.gd")

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
	var title_art_rect: TextureRect = $CenterContainer/Panel/VBoxContainer/ArtCenter/TitleArtRect
	title_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_art_rect.texture = _load_title_texture("res://assets/cat_ninja_tower_title_v2.png")
	music_on_icon = _load_title_texture("res://assets/music_on.svg")
	music_off_icon = _load_title_texture("res://assets/music_off.svg")
	AudioManager.music_muted_changed.connect(_update_music_button_icon)
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()
	_update_music_button_icon(AudioManager.is_music_muted())


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var metrics: Dictionary = UI_METRICS.TITLE
	var window_size: Vector2 = Vector2(get_window().size)
	var is_wide: bool = window_size.x / maxf(1.0, window_size.y) >= float(metrics["wide_breakpoint_ratio"])
	var outer_margin := float(metrics["outer_margin"]) * scale_factor
	var panel_base_size: Vector2 = (metrics["wide_panel_size"] as Vector2) if is_wide else (metrics["panel_size"] as Vector2)
	var panel_min_size: Vector2 = (metrics["wide_panel_min"] as Vector2) if is_wide else (metrics["panel_min"] as Vector2)
	var desired_panel_size: Vector2 = panel_base_size * scale_factor
	var panel_size := Vector2(
		minf(desired_panel_size.x, maxf(panel_min_size.x * scale_factor, window_size.x - outer_margin * 2.0)),
		minf(desired_panel_size.y, maxf(panel_min_size.y * scale_factor, window_size.y - outer_margin * 2.0))
	)
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = panel_size
	var panel_padding := minf(float(metrics["panel_padding"]) * scale_factor, panel_size.x * 0.025)
	var music_button: Button = $CenterContainer/Panel/MusicButton
	var music_button_size := minf(float(metrics["music_button_size"]) * scale_factor, panel_size.x * 0.14)
	var music_button_inset := maxf(float(metrics["music_button_inset"]) * scale_factor, panel_padding + 4.0 * scale_factor)
	music_button.custom_minimum_size = Vector2(music_button_size, music_button_size)
	music_button.anchor_left = 0.0
	music_button.anchor_top = 0.0
	music_button.anchor_right = 0.0
	music_button.anchor_bottom = 0.0
	BUTTON_STYLES.apply_button_style(music_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var content_root: Control = $CenterContainer/Panel/VBoxContainer
	content_root.offset_left = panel_padding
	content_root.offset_top = panel_padding
	content_root.offset_right = panel_size.x - panel_padding
	content_root.offset_bottom = panel_size.y - panel_padding

	var art_center: CenterContainer = $CenterContainer/Panel/VBoxContainer/ArtCenter
	var spacer: Control = $CenterContainer/Panel/VBoxContainer/Spacer
	var button_area: MarginContainer = $CenterContainer/Panel/VBoxContainer/ButtonArea
	var spacer_height := float(metrics["spacer_height"]) * scale_factor
	var button_height := float(metrics["button_height"]) * scale_factor
	var button_spacing := float(metrics["button_spacing"]) * scale_factor
	var exit_gap := float(metrics["exit_gap"]) * scale_factor
	var button_margin_top := float(metrics["button_margin_top"]) * scale_factor
	var button_margin_bottom := float(metrics["button_margin_bottom"]) * scale_factor
	var button_block_height := button_height * 3.0 + button_spacing * 2.0 + exit_gap + button_margin_top + button_margin_bottom
	var button_margin_x := minf(float(metrics["button_margin_x"]) * scale_factor, panel_size.x * 0.12)
	var buttons_vbox: VBoxContainer = $CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox
	button_area.add_theme_constant_override("margin_left", int(round(button_margin_x)))
	button_area.add_theme_constant_override("margin_right", int(round(button_margin_x)))
	button_area.add_theme_constant_override("margin_top", int(round(button_margin_top)))
	button_area.add_theme_constant_override("margin_bottom", int(round(button_margin_bottom)))
	buttons_vbox.add_theme_constant_override("separation", int(round(button_spacing)))
	$CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/QuitGap.custom_minimum_size = Vector2(0, exit_gap)

	if is_wide:
		var wide_gap := float(metrics["wide_gap"]) * scale_factor
		var wide_music_gap := float(metrics["wide_music_gap"]) * scale_factor
		var wide_column_top_padding := float(metrics["wide_column_top_padding"]) * scale_factor
		var content_width := panel_size.x - panel_padding * 2.0
		var content_height := panel_size.y - panel_padding * 2.0
		var art_width := maxf(metrics["art_min_size"].x * scale_factor, content_width * float(metrics["wide_art_width_ratio"]))
		var button_width := maxf(220.0 * scale_factor, content_width * float(metrics["wide_button_width_ratio"]))
		if art_width + button_width + wide_gap > content_width:
			var overflow := art_width + button_width + wide_gap - content_width
			art_width = maxf(metrics["art_min_size"].x * scale_factor, art_width - overflow)
		art_center.offset_left = 0.0
		art_center.offset_top = 0.0
		art_center.offset_right = art_width
		art_center.offset_bottom = content_height
		spacer.visible = false
		spacer.offset_left = 0.0
		spacer.offset_top = 0.0
		spacer.offset_right = 0.0
		spacer.offset_bottom = 0.0
		var column_left := art_width + wide_gap
		var column_right := content_width
		var column_width := column_right - column_left
		var reserved_music_height := music_button_size + wide_music_gap
		var button_area_height := button_block_height
		var button_area_top := maxf(
			reserved_music_height + wide_column_top_padding,
			(content_height - button_area_height) * 0.5
		)
		button_area.offset_left = column_left
		button_area.offset_top = button_area_top
		button_area.offset_right = column_right
		button_area.offset_bottom = minf(content_height, button_area_top + button_area_height)
		music_button.offset_left = panel_padding + column_right - music_button_size
		music_button.offset_top = panel_padding + wide_column_top_padding
		music_button.offset_right = panel_padding + column_right
		music_button.offset_bottom = panel_padding + wide_column_top_padding + music_button_size
		var art_size := Vector2(
			art_width,
			minf(float(metrics["art_max_height"]) * scale_factor, content_height)
		)
		$CenterContainer/Panel/VBoxContainer/ArtCenter/TitleArtRect.custom_minimum_size = art_size
	else:
		var available_art_height := maxf(160.0 * scale_factor, panel_size.y - panel_padding * 2.0 - spacer_height - button_block_height)
		var art_size := Vector2(
			maxf(metrics["art_min_size"].x * scale_factor, panel_size.x - panel_padding * 2.0),
			minf(float(metrics["art_max_height"]) * scale_factor, minf(panel_size.y * float(metrics["art_height_ratio"]), available_art_height))
		)
		art_center.offset_left = 0.0
		art_center.offset_top = 0.0
		art_center.offset_right = panel_size.x - panel_padding * 2.0
		art_center.offset_bottom = art_size.y
		spacer.visible = true
		spacer.offset_left = 0.0
		spacer.offset_top = art_size.y
		spacer.offset_right = panel_size.x - panel_padding * 2.0
		spacer.offset_bottom = art_size.y + spacer_height
		button_area.offset_left = 0.0
		button_area.offset_top = art_size.y + spacer_height
		button_area.offset_right = panel_size.x - panel_padding * 2.0
		button_area.offset_bottom = panel_size.y - panel_padding * 2.0
		music_button.offset_left = panel_size.x - music_button_inset - music_button_size
		music_button.offset_top = music_button_inset
		music_button.offset_right = panel_size.x - music_button_inset
		music_button.offset_bottom = music_button_inset + music_button_size
		$CenterContainer/Panel/VBoxContainer/ArtCenter/TitleArtRect.custom_minimum_size = art_size

	for button_path in [
		"CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/StartButton",
	]:
		var button: Button = get_node(button_path) as Button
		button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
		button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
		BUTTON_STYLES.apply_button_style(button, scale_factor, BUTTON_STYLES.ROLE_PRIMARY)

	var how_to_play_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/HowToPlayButton
	how_to_play_button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
	how_to_play_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(how_to_play_button, scale_factor, BUTTON_STYLES.ROLE_UTILITY)

	var quit_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonArea/ButtonsVBox/QuitButton
	quit_button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
	quit_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(quit_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)
	_update_music_button_icon(AudioManager.is_music_muted())


func _get_mobile_scale() -> float:
	return UI_METRICS.get_menu_scale(get_window().size)


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
