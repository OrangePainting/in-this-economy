extends Node2D

@onready var button = $SpinButton
var button_rotate: bool

const SpinnerDocument = preload("res://Scenes/spinner_document.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	var document = SpinnerDocument.instantiate()
	add_child(document)
	
	AudioController.play_in_game_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GlobalData.total_time += delta


func _on_spin_button_pressed() -> void:
	button.disabled = true # Add disabled button sprite here too
	button.modulate = Color(1.0, 0.2, 0.2, 0.3)
	AudioController.play_apply()
	
	GlobalData.total_apps += 1
	GlobalData.currency_changed.emit()
	
	find_child("SpinnerDocument").apply()

func _on_spin_button_mouse_entered() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3) * 1.1, 0.1)


func _on_spin_button_mouse_exited() -> void:
	create_tween().tween_property(button, "scale", Vector2(4, 3), 0.1)
