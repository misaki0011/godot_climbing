extends Area2D

@onready var flag: Polygon2D = $Flag
@onready var base: Polygon2D = $Base

var activated := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if activated or not body.is_in_group("player"):
		return
	activated = true
	flag.color = Color(0.4, 1.0, 0.45)
	base.color = Color(0.95, 0.95, 0.95)
	var level_manager := get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.register_checkpoint(global_position + Vector2(0, -24))

