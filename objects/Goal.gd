extends Area2D

const GEM_TEXTURE_PATH := "res://assets/gem_goal.svg"

@onready var gem_sprite: Sprite2D = $GemSprite


func _ready() -> void:
	monitoring = false
	monitorable = false
	_apply_gem_texture()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var level_manager := get_tree().get_first_node_in_group("level_manager")
	if level_manager:
		level_manager.complete_level()


func arm() -> void:
	monitoring = true
	monitorable = true


func _apply_gem_texture() -> void:
	gem_sprite.texture = _load_gem_texture(GEM_TEXTURE_PATH)


func _load_gem_texture(path: String) -> Texture2D:
	var resource := load(path)
	if resource is Texture2D:
		return resource

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Goal SVG not found: %s" % path)
		return null

	var source := FileAccess.get_file_as_string(absolute_path)
	if source.is_empty():
		push_warning("Goal SVG could not be read: %s" % path)
		return null

	var image := Image.new()
	var error := image.load_svg_from_string(source)
	if error != OK:
		push_warning("Goal SVG could not be loaded: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
