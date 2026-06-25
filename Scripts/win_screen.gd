extends Control

@export var main: Node2D
@export var document: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%InfoLabel.text = "You just landed your dream job in the %s industry after applying %s times for %s minutes! Now GO get that job in real life!" % [GlobalData.industry_name, str(GlobalData.global_total_apps) ,str(snappedf(GlobalData.total_time / 60.0, 0.01))] 
	%WinScreenBackground.hide()
	%PanelContainer.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_game_over() -> void:
	%WinScreenBackground.show()
	%PanelContainer.show()
	%PanelContainer.scale = Vector2.ZERO
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(%PanelContainer, "scale", Vector2.ONE, 0.5)
	GlobalData.finished_game = true


func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
	GlobalData.reset_game()

func _on_keep_playing_button_pressed() -> void:
	%WinScreenBackground.visible = false
