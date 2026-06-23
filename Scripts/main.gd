extends Node2D

@onready var button = $SpinButton
var documents: Array = [SpinnerDocument]

const SpinnerDocument = preload("res://Scenes/spinner_document.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	AudioController.play_in_game_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GlobalData.total_time += delta # Change later to use Time.get_ticks_msec()
	Time.get_ticks_msec()


func _on_spin_button_pressed() -> void:
	button.disabled = true
	button.modulate = Color(1.0, 0.2, 0.2, 0.3)
	AudioController.play_apply()
	
	GlobalData.total_apps += 1
	GlobalData.currency_changed.emit()
	
	var win_screen = $WinScreenBackground/WinScreen
	for doc in documents:
		if not is_instance_valid(doc): continue
		if doc.game_over.is_connected(win_screen.on_game_over):
			doc.game_over.disconnect(win_screen.on_game_over)
		var t = doc.create_tween()
		t.tween_property(doc, "modulate", Color(1, 1, 1, 0), 1.5)
		t.tween_callback(doc.queue_free)
	
	documents.clear()
	
	var doc = SpinnerDocument.instantiate()
	add_child(doc)
	doc.button = button
	doc.game_over.connect(win_screen.on_game_over)
	documents.append(doc)
	doc.apply()

func _on_spin_button_mouse_entered() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3) * 1.1, 0.1)


func _on_spin_button_mouse_exited() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3), 0.1)
