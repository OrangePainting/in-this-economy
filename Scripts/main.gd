extends Node2D

@onready var button = $SpinButton

var envelope_layer: CanvasLayer

const Envelope = preload("res://Scenes/envelope.tscn")
var envelopes: Array = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	envelope_layer = CanvasLayer.new()
	envelope_layer.layer = 2
	add_child(envelope_layer)
	
	modulate = Color.BLACK
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5)
	
	randomize()
	AudioController.play_in_game_music()
	
	var t = Timer.new()
	t.wait_time = GlobalData.PASSIVE_EXP_INTERVAL
	t.timeout.connect(on_passive_exp_tick)
	add_child(t)
	t.start()

func on_passive_exp_tick() -> void:
	if GlobalData.stats["passive_exp_rate"] > 0:
		GlobalData.experience += GlobalData.stats["passive_exp_rate"]
		GlobalData.currency_changed.emit()
	GlobalData.passive_exp_ticked.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GlobalData.total_time += delta # Change later to use Time.get_ticks_msec()
	Time.get_ticks_msec()

func _on_spin_button_pressed() -> void:
	button.disabled = true
	button.modulate = Color(1.0, 0.2, 0.2, 0.2)
	AudioController.play_apply()
	
	var win_screen = $WinScreenLayer/WinScreenBackground/WinScreen
	
	for env in envelopes:
		var t = create_tween()
		t.tween_property(env, "modulate", Color(1, 1, 1, 0), 1.5)
		t.tween_callback(env.queue_free)

	envelopes.clear()
	
	var envelope = Envelope.instantiate()
	envelope_layer.add_child(envelope)
	envelope.button = button
	envelope.win_screen = win_screen
	envelopes.append(envelope)
	envelope.apply()


func _on_spin_button_mouse_entered() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3) * 1.1, 0.1)


func _on_spin_button_mouse_exited() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3), 0.1)
