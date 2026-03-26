extends Node

signal sfx_requested(event_name: String)


func play_sfx(event_name: String) -> void:
	# Placeholder audio hook. Real samples can be attached later without touching callers.
	sfx_requested.emit(event_name)

