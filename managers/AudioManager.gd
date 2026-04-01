extends Node

signal sfx_requested(event_name: String)
signal music_muted_changed(is_muted: bool)

const BGM_PATH := "res://assets/cat_ninja_tower_music.mp3"
const DEBUG_MUSIC := true

var bgm_player: AudioStreamPlayer = null
var music_muted := false
var interaction_unlocked := false


func _ready() -> void:
	if OS.has_feature("web"):
		music_muted = true
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BgmPlayer"
	add_child(bgm_player)
	bgm_player.bus = "Master"
	bgm_player.stream = _load_bgm_stream(BGM_PATH)
	_debug_log("ready stream_loaded=%s web=%s" % [str(bgm_player.stream != null), str(OS.has_feature("web"))])
	_sync_music_playback()


func play_sfx(event_name: String) -> void:
	# Placeholder audio hook. Real samples can be attached later without touching callers.
	sfx_requested.emit(event_name)


func toggle_music_muted() -> void:
	set_music_muted(not music_muted)


func handle_music_toggle_interaction() -> void:
	var wants_audible := not is_music_audible()
	_debug_log(
		"handle_music_toggle_interaction before muted=%s unlocked=%s playing=%s wants_audible=%s"
		% [str(music_muted), str(interaction_unlocked), str(_is_bgm_playing()), str(wants_audible)]
	)
	if wants_audible:
		if music_muted:
			set_music_muted(false)
		notify_user_interaction()
	else:
		set_music_muted(true)


func set_music_muted(is_muted: bool) -> void:
	if music_muted == is_muted:
		_debug_log("set_music_muted skipped muted=%s" % str(is_muted))
		return
	music_muted = is_muted
	_debug_log("set_music_muted muted=%s unlocked=%s playing_before_sync=%s" % [str(music_muted), str(interaction_unlocked), str(_is_bgm_playing())])
	_sync_music_playback()
	_sync_web_audio_context()
	_debug_log("set_music_muted finished muted=%s playing_after_sync=%s" % [str(music_muted), str(_is_bgm_playing())])
	music_muted_changed.emit(music_muted)


func is_music_muted() -> bool:
	return music_muted


func is_music_audible() -> bool:
	if bgm_player == null or bgm_player.stream == null:
		return false
	if music_muted:
		return false
	if OS.has_feature("web") and not interaction_unlocked:
		return false
	return _is_bgm_playing()


func notify_user_interaction() -> void:
	interaction_unlocked = true
	_debug_log("notify_user_interaction muted=%s playing_before_sync=%s" % [str(music_muted), str(_is_bgm_playing())])
	_sync_music_playback()
	_sync_web_audio_context()
	_debug_log("notify_user_interaction finished playing_after_sync=%s" % str(_is_bgm_playing()))
	music_muted_changed.emit(music_muted)


func _load_bgm_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		var imported_stream := load(path)
		if imported_stream is AudioStream:
			_set_stream_loop(imported_stream)
			return imported_stream

	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		push_warning("Background music not found: %s" % path)
		return null

	var stream := AudioStreamMP3.new()
	stream.data = FileAccess.get_file_as_bytes(absolute_path)
	_set_stream_loop(stream)
	return stream


func _set_stream_loop(stream: AudioStream) -> void:
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true


func _sync_music_playback() -> void:
	if bgm_player == null:
		_debug_log("_sync_music_playback skipped no_player")
		return
	if music_muted:
		_debug_log("_sync_music_playback muted -> stop playing=%s" % str(bgm_player.playing))
		if bgm_player.playing:
			bgm_player.stop()
		return

	if bgm_player.stream == null:
		_debug_log("_sync_music_playback skipped no_stream")
		return
	if OS.has_feature("web") and not interaction_unlocked:
		_debug_log("_sync_music_playback waiting_for_interaction")
		return
	if not bgm_player.playing:
		_debug_log("_sync_music_playback play()")
		bgm_player.play()
	else:
		_debug_log("_sync_music_playback already_playing")


func _sync_web_audio_context() -> void:
	if not OS.has_feature("web"):
		return
	var is_muted_js := "true" if music_muted else "false"
	_debug_log("_sync_web_audio_context muted=%s" % is_muted_js)
	JavaScriptBridge.eval("if (window.__nctSetMusicMuted) { window.__nctSetMusicMuted(%s); }" % is_muted_js)


func _is_bgm_playing() -> bool:
	return bgm_player != null and bgm_player.playing


func _debug_log(message: String) -> void:
	if DEBUG_MUSIC:
		print("[AudioManager] %s" % message)
