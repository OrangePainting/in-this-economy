extends Node2D

@onready var button = $SpinButton

const Envelope = preload("res://Scenes/envelope.tscn")
var envelopes: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	AudioController.play_in_game_music()
	
	var t = Timer.new()
	t.wait_time = 2.0
	t.timeout.connect(on_passive_exp_tick)
	add_child(t)
	t.start()

func on_passive_exp_tick() -> void:
	if GlobalData.stats["passive_exp_rate"] > 0:
		GlobalData.experience += GlobalData.stats["passive_exp_rate"]
		GlobalData.currency_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GlobalData.total_time += delta # Change later to use Time.get_ticks_msec()
	Time.get_ticks_msec()

func _on_spin_button_pressed() -> void:
	button.disabled = true
	button.modulate = Color(1.0, 0.2, 0.2, 0.2)
	AudioController.play_apply()
	
	var win_screen = $WinScreenBackground/WinScreen
	
	for env in envelopes:
		var t = create_tween()
		t.tween_property(env, "modulate", Color(1, 1, 1, 0), 1.5)
		t.tween_callback(env.queue_free)

	envelopes.clear()
	
	var envelope = Envelope.instantiate()
	add_child(envelope)
	envelope.button = button
	envelope.win_screen = win_screen
	envelopes.append(envelope)
	envelope.apply()


func _on_spin_button_mouse_entered() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3) * 1.1, 0.1)


func _on_spin_button_mouse_exited() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3), 0.1)
