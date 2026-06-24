extends VBoxContainer

const ProjectButton = preload("res://Scenes/project_template.tscn")
const GridGame = preload("res://Scenes/Projects/grid_game_manager.tscn")
const ArcGame = preload("res://Scenes/arc_game_manager.tscn")
const PinGame = preload("res://Scenes/pin_drop_manager.tscn")
var overlay: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button1 = ProjectButton.instantiate()
	button1.display_text("Grid Spin")
	button1.pressed.connect(func(): launch_grid_game(button1))
	add_child(button1)
	button1.setup_timer(10)
	
	var button2 = ProjectButton.instantiate()
	button2.display_text("Arc Spin")
	button2.pressed.connect(func(): launch_arc_game(button2))
	add_child(button2)
	button2.setup_timer(15)
	
	var button3 = ProjectButton.instantiate()
	button3.display_text("Dart Spin")
	button3.pressed.connect(func(): launch_pin_drop_game(button3))
	add_child(button3)
	button3.setup_timer(20)
	

func launch_grid_game(button) -> void:
	if overlay: return
	open_overlay(button, GridGame.instantiate(), func(): close())

func launch_arc_game(button) -> void:
	if overlay: return
	var game = ArcGame.instantiate()
	game.project_completed.connect(on_arc_completed)
	open_overlay(button, game, func(): close())

func launch_pin_drop_game(button) -> void:
	if overlay: return
	var game = PinGame.instantiate()
	game.project_completed.connect(on_pin_drop_completed)
	open_overlay(button, game, func(): close())

func on_pin_drop_completed() -> void:
	GlobalData.experience += 20
	GlobalData.currency_changed.emit()
	close()

func open_overlay(button, game: Control, close_function) -> void:
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
	close_button.pressed.connect(close_function)
	overlay.add_child(close_button)
	
	game.position = Vector2(50, 60)
	game.project_completed.connect(close_function)
	overlay.add_child(game)
	
	button.queue_free()

func on_arc_completed() -> void:
	GlobalData.experience += 20
	GlobalData.currency_changed.emit()
	close()

func close() -> void:
	if overlay:
		overlay.queue_free()
		overlay = null # just in case
		
		# Add experience gain here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
