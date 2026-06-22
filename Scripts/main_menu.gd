extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioController.play_menu_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_game_button_pressed() -> void:
	AudioController.stop_menu_music()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
