class_name UIMetrics
extends RefCounted

const TITLE := {
	"panel_size": Vector2(580, 820),
	"panel_min": Vector2(300, 420),
	"wide_panel_size": Vector2(980, 620),
	"wide_panel_min": Vector2(760, 420),
	"outer_margin": 14.0,
	"panel_padding": 4.0,
	"wide_breakpoint_ratio": 1.15,
	"wide_gap": 18.0,
	"wide_art_width_ratio": 0.58,
	"wide_button_width_ratio": 0.34,
	"wide_music_gap": 14.0,
	"wide_column_top_padding": 10.0,
	"music_button_size": 76.0,
	"music_button_inset": 10.0,
	"art_min_size": Vector2(220, 0),
	"art_max_height": 720.0,
	"art_height_ratio": 0.78,
	"spacer_height": 8.0,
	"button_margin_x": 28.0,
	"button_margin_top": 6.0,
	"button_margin_bottom": 6.0,
	"button_spacing": 10.0,
	"exit_gap": 18.0,
	"button_height": 58.0,
	"button_font_size": 20.0,
}

const HOW_TO_PLAY := {
	"panel_size": Vector2(520, 520),
	"content_left": 28.0,
	"content_top": 24.0,
	"content_right": 492.0,
	"content_bottom": 496.0,
	"title_font_size": 40.0,
	"body_font_size": 18.0,
	"illustration_height": 240.0,
	"body_gap": 10.0,
	"back_gap": 18.0,
	"button_height": 58.0,
	"button_font_size": 20.0,
}

const LEVEL_SELECT := {
	"panel_size": Vector2(560, 620),
	"panel_min": Vector2(280, 360),
	"outer_margin": 16.0,
	"padding_x": 28.0,
	"padding_top": 20.0,
	"padding_bottom": 24.0,
	"content_min_width": 320.0,
	"content_max_width": 500.0,
	"content_spacing": 10.0,
	"title_font_size": 32.0,
	"gem_row_spacing": 8.0,
	"gem_font_size": 20.0,
	"gem_icon_size": 24.0,
	"back_gap": 18.0,
	"row_button_height": 74.0,
	"row_button_font_size": 20.0,
	"reward_label_width": 56.0,
	"reward_label_font_size": 20.0,
}

const STAGE_CLEAR := {
	"panel_size": Vector2(400, 380),
	"panel_min": Vector2(260, 280),
	"outer_margin": 16.0,
	"padding_x": 28.0,
	"padding_top": 18.0,
	"padding_bottom": 22.0,
	"content_min_width": 220.0,
	"content_max_width": 320.0,
	"content_spacing": 10.0,
	"title_font_size": 28.0,
	"reward_font_size": 22.0,
	"divider_font_size": 18.0,
	"back_gap": 14.0,
	"grid_h_spacing": 12.0,
	"grid_v_spacing": 8.0,
	"grid_font_size": 18.0,
	"grid_left_width": 190.0,
	"grid_value_width": 64.0,
	"button_height": 58.0,
	"button_font_size": 20.0,
}

const HUD := {
	"margin_left": 24.0,
	"margin_top": 20.0,
	"margin_right": 440.0,
	"margin_bottom": 180.0,
	"title_font_size": 24.0,
	"body_font_size": 20.0,
	"debug_left": -228.0,
	"debug_top": 20.0,
	"debug_right": -24.0,
	"debug_bottom": 82.0,
	"pause_left": 24.0,
	"pause_top": -150.0,
	"pause_right": 228.0,
	"pause_bottom": -88.0,
	"button_font_size": 18.0,
}

const PAUSE_MENU := {
	"panel_size": Vector2(204, 214),
	"panel_left": 24.0,
	"panel_top": -302.0,
	"panel_right": 228.0,
	"panel_bottom": -88.0,
	"content_spacing": 10.0,
	"title_font_size": 28.0,
	"back_gap": 18.0,
	"top_row_size": Vector2(204, 62),
	"resume_button_size": Vector2(204, 62),
	"restart_button_size": Vector2(130, 62),
	"music_button_size": Vector2(64, 62),
	"back_button_size": Vector2(204, 62),
	"button_font_size": 18.0,
}


static func get_ui_scale(window_size: Vector2i) -> float:
	var width: float = float(window_size.x)
	var height: float = float(window_size.y)
	if width <= 0.0 or height <= 0.0:
		return 1.0

	var base_width: float = float(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var base_height: float = float(ProjectSettings.get_setting("display/window/size/viewport_height"))
	var width_scale: float = base_width / width
	var height_scale: float = base_height / height
	var base_scale: float = maxf(width_scale, height_scale)

	if height > width:
		base_scale *= 1.22
	else:
		base_scale *= 0.95

	return clampf(base_scale, 0.9, 3.4)


static func get_menu_scale(window_size: Vector2i) -> float:
	var scale: float = get_ui_scale(window_size)
	var width: float = float(window_size.x)
	var height: float = float(window_size.y)
	if height > width:
		scale *= 1.28
	else:
		scale *= 1.12
	return clampf(scale, 1.1, 4.2)
