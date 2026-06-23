extends VBoxContainer

const ProjectButton = preload("res://Scenes/project_template.tscn")
const GridGame = preload("res://Scenes/Projects/grid_game_manager.tscn")
var overlay: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button = ProjectButton.instantiate()
	button.display_text("Grid Spin")
	button.pressed.connect(func(): launch_grid_game(button))
	add_child(button)
	button.setup_timer(10)
	

func launch_grid_game(button) -> void:
	if overlay: return
	overlay = CanvasLayer.new()
	overlay.layer = 10
	get_tree().root.add_child(overlay)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	overlay.add_child(bg)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.position = Vector2(10, 10)
	close_button.pressed.connect(close)
	overlay.add_child(close_button)
	
	var game: Control = GridGame.instantiate()
	game.position = Vector2(50, 60)
	game.project_completed.connect(close)
	overlay.add_child(game)
	
	button.queue_free()
	

func close() -> void:
	if overlay:
		overlay.queue_free()
		overlay = null # just in case
		# Add experience gain here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
