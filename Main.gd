extends Node

const PLAYER_SCENE := preload("res://player/Player.tscn")
const TITLE_SCREEN_SCENE := preload("res://ui/TitleScreen.tscn")
const LEVEL_SELECT_SCENE := preload("res://ui/LevelSelect.tscn")
const HUD_SCENE := preload("res://ui/HUD.tscn")
const PAUSE_MENU_SCENE := preload("res://ui/PauseMenu.tscn")
const STAGE_CLEAR_SCENE := preload("res://ui/StageClear.tscn")

@onready var level_manager: Node = $LevelManager
@onready var level_root: Node = $LevelRoot
@onready var menu_root: Node = $MenuRoot
@onready var overlay_root: Node = $OverlayRoot

var current_level: Node2D = null
var current_player: CharacterBody2D = null
var current_menu: Control = null
var hud: CanvasLayer = null
var pause_menu: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_manager.process_mode = Node.PROCESS_MODE_PAUSABLE
	level_root.process_mode = Node.PROCESS_MODE_PAUSABLE
	GameManager.route_changed.connect(_on_route_changed)
	level_manager.hud_updated.connect(_on_hud_updated)
	level_manager.stage_cleared.connect(_on_stage_cleared)
	_ensure_overlay_scenes()
	GameManager.show_title()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and current_level != null:
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()


func _unhandled_input(event: InputEvent) -> void:
	if current_level == null or current_player == null or get_tree().paused:
		return
	if event is InputEventScreenTouch and event.pressed:
		current_player.try_climb()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_player.try_climb()
		get_viewport().set_input_as_handled()


func _on_route_changed(route: String, level_index: int) -> void:
	match route:
		GameManager.TITLE:
			_clear_level()
			_show_menu(TITLE_SCREEN_SCENE.instantiate())
		GameManager.LEVEL_SELECT:
			_clear_level()
			var menu := LEVEL_SELECT_SCENE.instantiate()
			menu.set_unlocked_levels(GameManager.unlocked_levels)
			menu.set_total_gems(GameManager.get_total_gems())
			menu.set_level_rewards(GameManager.get_stage_rewards())
			_show_menu(menu)
		GameManager.STAGE_CLEAR:
			_clear_level()
			var clear_menu := STAGE_CLEAR_SCENE.instantiate()
			clear_menu.set_results(
				GameManager.last_stage_stats["stage_name"],
				GameManager.last_stage_stats["time_text"],
				GameManager.last_stage_stats["deaths"],
				GameManager.last_stage_stats["target_time_text"],
				GameManager.last_stage_stats["stage_reward"],
				GameManager.is_final_level(level_index),
				GameManager.last_stage_stats["clear_reward"],
				GameManager.last_stage_stats["death_penalty"],
				GameManager.last_stage_stats["speed_bonus"]
			)
			_show_menu(clear_menu)
		GameManager.STAGE:
			_start_level(level_index)


func _show_menu(menu: Control) -> void:
	if current_menu:
		current_menu.queue_free()
	current_menu = menu
	menu_root.add_child(menu)
	if menu.has_signal("start_pressed"):
		menu.start_pressed.connect(func() -> void: GameManager.show_level_select())
	if menu.has_signal("quit_pressed"):
		menu.quit_pressed.connect(func() -> void: get_tree().quit())
	if menu.has_signal("level_selected"):
		menu.level_selected.connect(func(level_index: int) -> void: GameManager.start_level(level_index))
	if menu.has_signal("back_pressed"):
		if menu.has_signal("next_pressed") and menu.has_signal("retry_pressed"):
			menu.back_pressed.connect(func() -> void: GameManager.show_level_select())
		else:
			menu.back_pressed.connect(func() -> void: GameManager.show_title())
	if menu.has_signal("next_pressed"):
		menu.next_pressed.connect(func() -> void:
			if not GameManager.next_level():
				GameManager.show_level_select()
		)
	if menu.has_signal("retry_pressed"):
		menu.retry_pressed.connect(func() -> void: GameManager.retry_level())


func _start_level(level_index: int) -> void:
	_clear_menu()
	_clear_level()
	var scene := load(GameManager.get_level_scene(level_index))
	current_level = scene.instantiate()
	level_root.add_child(current_level)

	current_player = PLAYER_SCENE.instantiate()
	current_player.set_climb_anchor(current_level.get_spawn_position())
	current_level.add_child(current_player)
	current_player.restart_requested.connect(func() -> void: GameManager.retry_level())
	current_player.configure_camera(current_level.get_camera_bounds())

	level_manager.setup_level(
		current_level,
		current_player,
		current_level.get_stage_name(),
		current_level.get_spawn_position(),
		GameManager.get_level_target_time(level_index)
	)
	var goal := current_level.get_node_or_null("Goal")
	if goal != null and goal.has_method("arm"):
		goal.call_deferred("arm")
	hud.show()
	hud.set_pause_state(false)
	hud.update_display(
		current_level.get_stage_name(),
		"00:00.00",
		GameManager.get_level_target_time_text(level_index),
		0
	)
	pause_menu.hide()
	get_tree().paused = false


func _on_hud_updated(stage_name: String, time_text: String, target_time_text: String, deaths: int) -> void:
	hud.update_display(stage_name, time_text, target_time_text, deaths)


func _on_stage_cleared(stats: Dictionary) -> void:
	GameManager.complete_current_level()
	GameManager.record_stage_reward(GameManager.current_level_index, stats["stage_reward"])
	stats["total_gems"] = GameManager.get_total_gems()
	GameManager.show_stage_clear(stats)


func _pause_game() -> void:
	if current_level == null:
		return
	hud.set_pause_state(true)
	get_tree().paused = true
	pause_menu.show()


func _resume_game() -> void:
	get_tree().paused = false
	hud.set_pause_state(false)
	pause_menu.hide()


func _clear_menu() -> void:
	if current_menu:
		current_menu.queue_free()
		current_menu = null


func _clear_level() -> void:
	get_tree().paused = false
	pause_menu.hide()
	hud.set_pause_state(false)
	hud.hide()
	if current_level:
		current_level.queue_free()
		current_level = null
	current_player = null


func _ensure_overlay_scenes() -> void:
	hud = HUD_SCENE.instantiate()
	overlay_root.add_child(hud)
	hud.hide()
	hud.debug_skip_pressed.connect(func() -> void:
		if current_level != null and not get_tree().paused:
			level_manager.complete_level()
	)
	hud.pause_pressed.connect(func() -> void:
		if current_level == null:
			return
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()
	)

	pause_menu = PAUSE_MENU_SCENE.instantiate()
	overlay_root.add_child(pause_menu)
	pause_menu.hide()
	pause_menu.restart_pressed.connect(func() -> void:
		_resume_game()
		GameManager.retry_level()
	)
	pause_menu.level_select_pressed.connect(func() -> void:
		_resume_game()
		GameManager.show_level_select()
	)
