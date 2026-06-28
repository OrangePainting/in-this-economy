extends Control

@export var main: Node2D
@export var document: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%WinScreenBackground.hide()
	%PanelContainer.hide()


func format_time(seconds: int):
		return "%d:%02d" % [int(seconds / 60), seconds % 60]

func on_game_over() -> void:
	%InfoLabel.text = ("You just landed your dream job in the %s industry!\n" + 
	"Apps Submitted: %d\n" + 
	"Total Time: %s\n" + 
	"Now GO get that job in real life!") % [GlobalData.industry_name, GlobalData.global_total_apps, format_time(GlobalData.total_time)] 
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
