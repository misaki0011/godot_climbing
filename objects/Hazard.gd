extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("is_respawning") and body.is_respawning():
		return
	var level_manager := get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.kill_player()
