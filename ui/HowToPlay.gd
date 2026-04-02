extends Control

const BUTTON_STYLES := preload("res://ui/ButtonStyles.gd")
const UI_METRICS := preload("res://ui/UIMetrics.gd")

signal back_pressed


func _ready() -> void:
	$CenterContainer/Panel/VBoxContainer/BackButton.pressed.connect(func() -> void: back_pressed.emit())
	$CenterContainer/Panel/VBoxContainer/IllustrationRect.texture = _load_illustration_texture("res://assets/tap_space.png")
	get_viewport().size_changed.connect(_apply_layout_scale)
	_apply_layout_scale()


func _apply_layout_scale() -> void:
	var scale_factor: float = _get_mobile_scale()
	var metrics: Dictionary = UI_METRICS.HOW_TO_PLAY
	var panel: Panel = $CenterContainer/Panel
	panel.custom_minimum_size = metrics["panel_size"] * scale_factor

	var box: VBoxContainer = $CenterContainer/Panel/VBoxContainer
	box.offset_left = float(metrics["content_left"]) * scale_factor
	box.offset_top = float(metrics["content_top"]) * scale_factor
	box.offset_right = float(metrics["content_right"]) * scale_factor
	box.offset_bottom = float(metrics["content_bottom"]) * scale_factor

	$CenterContainer/Panel/VBoxContainer/TitleLabel.add_theme_font_size_override("font_size", int(round(float(metrics["title_font_size"]) * scale_factor)))
	for label_path in [
		"CenterContainer/Panel/VBoxContainer/IntroLabel",
		"CenterContainer/Panel/VBoxContainer/ClimbLabel",
	]:
		var label: Label = get_node(label_path) as Label
		label.add_theme_font_size_override("font_size", int(round(float(metrics["body_font_size"]) * scale_factor)))

	$CenterContainer/Panel/VBoxContainer/IllustrationRect.custom_minimum_size = Vector2(0, float(metrics["illustration_height"])) * scale_factor
	$CenterContainer/Panel/VBoxContainer/BodyGap.custom_minimum_size = Vector2(0, float(metrics["body_gap"])) * scale_factor
	$CenterContainer/Panel/VBoxContainer/BackGap.custom_minimum_size = Vector2(0, float(metrics["back_gap"])) * scale_factor

	var back_button: Button = $CenterContainer/Panel/VBoxContainer/BackButton
	back_button.custom_minimum_size = Vector2(0, float(metrics["button_height"])) * scale_factor
	back_button.add_theme_font_size_override("font_size", int(round(float(metrics["button_font_size"]) * scale_factor)))
	BUTTON_STYLES.apply_button_style(back_button, scale_factor, BUTTON_STYLES.ROLE_EXIT)


func _get_mobile_scale() -> float:
	return UI_METRICS.get_menu_scale(get_window().size)



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
