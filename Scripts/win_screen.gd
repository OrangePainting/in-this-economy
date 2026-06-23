extends Control

@export var main: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%WinScreenBackground.hide()
	%PanelContainer.hide()
	main.game_over.connect(on_game_over)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_game_over() -> void:
	%WinScreenBackground.show()
	%PanelContainer.show()
	GlobalData.finished_game = true
