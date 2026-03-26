extends AnimatableBody2D

@export var travel_offset := Vector2(220, 0)
@export var speed := 90.0

var start_position := Vector2.ZERO
var progress := 0.0
var direction := 1.0


func _ready() -> void:
	start_position = position
	sync_to_physics = true


func _physics_process(delta: float) -> void:
	progress += direction * speed * delta / max(travel_offset.length(), 1.0)
	if progress >= 1.0:
		progress = 1.0
		direction = -1.0
	elif progress <= 0.0:
		progress = 0.0
		direction = 1.0
	position = start_position.lerp(start_position + travel_offset, progress)

