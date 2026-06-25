extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	modulate = Color.BLACK
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5)
	$%StartButton.disabled = true
	await get_tree().create_timer(0.5).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	AudioController.stop_menu_music()
	create_tween().tween_property(self, "modulate", Color.BLACK, 0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_line_edit_text_changed(new_text: String) -> void:
	if len(new_text) > 0: $%StartButton.disabled = false
	else: $%StartButton.disabled = true
