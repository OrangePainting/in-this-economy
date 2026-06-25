extends Node2D


@export var mute: bool = false
@export var music_tracks: Array[AudioStream] = []
@export var paper_sounds: Array[AudioStream] = []

var current_track = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Music.finished.connect(on_music_finished)

func play_menu_music() -> void:
	if not mute: $MenuMusic.play()

func stop_menu_music() -> void:
	if not mute: $MenuMusic.stop()

func play_in_game_music() -> void:
	if mute or music_tracks.is_empty(): return
	$Music.stream = music_tracks[current_track]
	$Music.play()

func on_music_finished() -> void:
	current_track = (current_track + 1) % len(music_tracks)
	play_in_game_music()

func play_click() -> void:
	if not mute: $Click.play()

func play_buy() -> void:
	if not mute: $Buy.play()

func play_apply() -> void:
	if not mute: $Apply.play()

func play_spin_tick() -> void:
	if not mute: $SpinTick.play()

func play_spin_pass() -> void: # play when > 0 are pass
	if not mute: $SpinPass.play()

func play_spin_all_pass() -> void: # play when all are pass
	if not mute: $SpinAllPass.play()

func play_spin_fail() -> void: # play when none are pass
	if not mute: $SpinFail.play()

func play_open_letter() -> void:
	if mute or paper_sounds.is_empty(): return
	$OpenLetter.stream = paper_sounds[randi_range(0, len(music_tracks) - 1)]
	$OpenLetter.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
