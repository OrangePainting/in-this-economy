extends Node2D


@export var mute: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func play_menu_music() -> void:
	if not mute: $MenuMusic.play()

func play_in_game_music() -> void:
	if not mute: $Music.play()

func play_click() -> void:
	if not mute: $Click.play()

func play_buy() -> void:
	if not mute: $Buy.play()

func play_apply() -> void:
	if not mute: $Buy.play()

func play_spin_tick() -> void:
	if not mute: $SpinTick.play()

func play_spin_pass() -> void: # play when > 0 are pass
	if not mute: $SpinPass.play()

func play_spin_all_pass() -> void: # play when all are pass
	if not mute: $SpinAllPass.play()

func play_spin_fail() -> void: # play when none are pass
	if not mute: $SpinFail.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
