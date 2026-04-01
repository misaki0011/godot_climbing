extends SceneTree

const SOURCE_PATH := "res://assets/cat_ninja_tower_title.png"
const TITLE_OUTPUT_PATH := "res://assets/cat_ninja_tower_title_v2.png"
const ICON_OUTPUT_PATH := "res://assets/ninja_cat_tower_icon.png"
const ICON_CROP := Rect2i(450, 650, 360, 360)
const ICON_SIZE := Vector2i(512, 512)


func _initialize() -> void:
	var source: Image = Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		push_error("Failed to load source image: %s" % SOURCE_PATH)
		quit(1)
		return

	var title_image: Image = source.duplicate()
	_apply_title_grade(title_image)
	var title_error: int = title_image.save_png(TITLE_OUTPUT_PATH)
	if title_error != OK:
		push_error("Failed to save title image: %s" % TITLE_OUTPUT_PATH)
		quit(1)
		return

	var icon_image: Image = Image.create(
		ICON_CROP.size.x,
		ICON_CROP.size.y,
		source.has_mipmaps(),
		source.get_format()
	)
	icon_image.blit_rect(source, ICON_CROP, Vector2i.ZERO)
	_apply_icon_grade(icon_image)
	icon_image.resize(ICON_SIZE.x, ICON_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var icon_error: int = icon_image.save_png(ICON_OUTPUT_PATH)
	if icon_error != OK:
		push_error("Failed to save icon image: %s" % ICON_OUTPUT_PATH)
		quit(1)
		return

	print("Generated %s and %s" % [TITLE_OUTPUT_PATH, ICON_OUTPUT_PATH])
	quit()


func _apply_title_grade(image: Image) -> void:
	_apply_grade(image, 1.06, 1.12, 0.02, Vector2(0.5, 0.36), 0.08)


func _apply_icon_grade(image: Image) -> void:
	_apply_grade(image, 1.08, 1.14, 0.02, Vector2(0.5, 0.3), 0.1)


func _apply_grade(
	image: Image,
	contrast: float,
	saturation: float,
	brightness: float,
	glow_center: Vector2,
	glow_strength: float
) -> void:
	var width := image.get_width()
	var height := image.get_height()
	for y in height:
		for x in width:
			var color := image.get_pixel(x, y)
			var rgb := Vector3(color.r, color.g, color.b)
			var gray := (rgb.x + rgb.y + rgb.z) / 3.0
			rgb = Vector3(
				((rgb.x - 0.5) * contrast + 0.5) + brightness,
				((rgb.y - 0.5) * contrast + 0.5) + brightness,
				((rgb.z - 0.5) * contrast + 0.5) + brightness
			)
			rgb = Vector3(
				gray + (rgb.x - gray) * saturation,
				gray + (rgb.y - gray) * saturation,
				gray + (rgb.z - gray) * saturation
			)

			var uv := Vector2(float(x) / maxf(1.0, float(width - 1)), float(y) / maxf(1.0, float(height - 1)))
			var dist := uv.distance_to(glow_center)
			var glow := maxf(0.0, 1.0 - dist / 0.75) * glow_strength
			rgb += Vector3(glow, glow, glow * 1.15)

			image.set_pixel(
				x,
				y,
				Color(
					clampf(rgb.x, 0.0, 1.0),
					clampf(rgb.y, 0.0, 1.0),
					clampf(rgb.z, 0.0, 1.0),
					color.a
				)
			)
