extends RefCounted

const ROLE_PRIMARY := "primary"
const ROLE_EXIT := "exit"
const ROLE_UTILITY := "utility"
const ROLE_DEBUG := "debug"

const PRIMARY_BG := Color(0.34, 0.45, 0.62, 1.0)
const PRIMARY_BORDER := Color(0.62, 0.75, 0.95, 1.0)
const PRIMARY_HOVER := Color(0.4, 0.52, 0.72, 1.0)
const PRIMARY_PRESSED := Color(0.27, 0.38, 0.55, 1.0)

const EXIT_BG := Color(0.22, 0.28, 0.36, 1.0)
const EXIT_BORDER := Color(0.43, 0.54, 0.66, 1.0)
const EXIT_HOVER := Color(0.28, 0.35, 0.45, 1.0)
const EXIT_PRESSED := Color(0.18, 0.24, 0.31, 1.0)

const UTILITY_BG := Color(0.42, 0.56, 0.74, 1.0)
const UTILITY_BORDER := Color(0.8, 0.9, 0.99, 1.0)
const UTILITY_HOVER := Color(0.49, 0.64, 0.82, 1.0)
const UTILITY_PRESSED := Color(0.32, 0.45, 0.61, 1.0)

const DEBUG_BG := Color(0.46, 0.31, 0.18, 1.0)
const DEBUG_BORDER := Color(0.83, 0.67, 0.42, 1.0)
const DEBUG_HOVER := Color(0.56, 0.38, 0.22, 1.0)
const DEBUG_PRESSED := Color(0.35, 0.24, 0.14, 1.0)

const DISABLED_BG := Color(0.14, 0.16, 0.19, 0.9)
const DISABLED_BORDER := Color(0.24, 0.27, 0.31, 0.95)
const DISABLED_FONT := Color(0.46, 0.49, 0.54, 1.0)


static func apply_button_style(button: Button, scale_factor: float, role: String) -> void:
	var corner_radius := int(round(16 * scale_factor))
	var border_width := int(round(maxf(2.0, 2.0 * scale_factor)))
	var normal := StyleBoxFlat.new()
	var hover_color := PRIMARY_HOVER
	var pressed_color := PRIMARY_PRESSED

	match role:
		ROLE_EXIT:
			normal.bg_color = EXIT_BG
			normal.border_color = EXIT_BORDER
			hover_color = EXIT_HOVER
			pressed_color = EXIT_PRESSED
		ROLE_UTILITY:
			normal.bg_color = UTILITY_BG
			normal.border_color = UTILITY_BORDER
			hover_color = UTILITY_HOVER
			pressed_color = UTILITY_PRESSED
		ROLE_DEBUG:
			normal.bg_color = DEBUG_BG
			normal.border_color = DEBUG_BORDER
			hover_color = DEBUG_HOVER
			pressed_color = DEBUG_PRESSED
		_:
			normal.bg_color = PRIMARY_BG
			normal.border_color = PRIMARY_BORDER

	normal.set_corner_radius_all(corner_radius)
	normal.set_border_width_all(border_width)
	normal.content_margin_left = 18 * scale_factor
	normal.content_margin_right = 18 * scale_factor
	normal.content_margin_top = 12 * scale_factor
	normal.content_margin_bottom = 12 * scale_factor

	var hover := normal.duplicate()
	hover.bg_color = hover_color

	var pressed := normal.duplicate()
	pressed.bg_color = pressed_color

	var disabled := normal.duplicate()
	disabled.bg_color = DISABLED_BG
	disabled.border_color = DISABLED_BORDER

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	button.add_theme_color_override("font_disabled_color", DISABLED_FONT)
