extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")

signal back_pressed


func _ready() -> void:
	$CenterContainer/Panel/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/IllustrationRect.texture = _load_illustration_texture("res://assets/tap_space.png")
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = Vector2(520, 520) * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = 40.0 * scale_factor
	box.offset_top = 32.0 * scale_factor
	box.offset_right = 480.0 * scale_factor
	box.offset_bottom = 488.0 * scale_factor

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(40 * scale_factor)))
	for label_path in [
		"CenterContainer/Panel/VBoxContainer/IntroLabel",
		"CenterContainer/Panel/VBoxContainer/ClimbLabel",
	]:
		var label: Label = get_node(label_path) as Label
		label.add_theme_font_size_override("font_size", int(round(18 * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/IllustrationRect.custom_minimum_size = Vector2(0, 220) * scale_factor
	$CenterContainer/Panel/VBoxContainer/BodyGap.custom_minimum_size = Vector2(0, 12) * scale_factor
	$CenterContainer/Panel/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, 22) * scale_factor

	var back_button: Button = $CenterContainer/Panel/VBoxContainer/BackButton
	back_button.custom_minimum_size = Vector2(0, 54) * scale_factor
	back_button.add_theme_font_size_override("font_size", int(round(20 * scale_factor)))
	BUTTON_STYLES.apply_button_style(back_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)


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



func _load_illustration_texture(path: String) -> Texture2D:
	var resource := load(path)
	if resource is Texture2D:
		return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("How-to-play illustration not found: %s" % path)
		return null

	var image := Image.new()
	var error := image.load(absolute_path)
	if error != OK:
		push_warning("How-to-play illustration could not be loaded: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
