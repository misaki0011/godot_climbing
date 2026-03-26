extends Area2D

@export var travel_offset := Vector2(180, 0)
@export var speed := 120.0
@export_range(0.0, 1.0, 0.01) var initial_progress := 0.0
@export var start_reversed := false

var start_position := Vector2.ZERO
var progress := 0.0
var direction := 1.0


func _ready() -> void:
	start_position = position
	progress = clampf(initial_progress, 0.0, 1.0)
	direction = -1.0 if start_reversed else 1.0
	position = start_position.lerp(start_position + travel_offset, progress)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	progress += direction * speed * delta / max(travel_offset.length(), 1.0)
	if progress >= 1.0:
		progress = 1.0
		direction = -1.0
	elif progress <= 0.0:
		progress = 0.0
		direction = 1.0
	position = start_position.lerp(start_position + travel_offset, progress)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("is_respawning") and body.is_respawning():
		return
	var level_manager := get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.kill_player()
