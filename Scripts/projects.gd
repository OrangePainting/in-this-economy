extends VBoxContainer

const ProjectButton = preload("res://Scenes/project_template.tscn")
const GridGame = preload("res://Scenes/Projects/grid_game_manager.tscn")
const ArcGame = preload("res://Scenes/arc_game_manager.tscn")
const PinGame = preload("res://Scenes/pin_drop_manager.tscn")
const SortGame = preload("res://Scenes/Projects/application_sort_manager.tscn")
var overlay: CanvasLayer

var projects_names = ["Pin", "Arc", "Grid", "Spin"]
var projects_exp_gain = [60, 40, 20, 30]

var next_project_in: float = 0.0
var elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	start_tween_loop()


func start_tween_loop() -> void:
	var wait_time = 20 - clamp(GlobalData.num_upgrades_bought / 3.0, 3, 11)
	next_project_in = randf_range(wait_time * 0.9, wait_time * 1.1)
	elapsed = 0.0
	var t = create_tween()
	t.tween_callback(idk).set_delay(next_project_in)
	t.tween_callback(start_tween_loop)

func time_until_next() -> float:
	return maxf(0.0, next_project_in - elapsed)


func idk() -> void:
	if GlobalData.stats["projects_unlocked"] >= 1:
		var game = projects_names[randi_range(0, GlobalData.stats["projects_unlocked"] - 1)]
		instantiate_button(game + " Game", game, randi_range(10, 20))

		

func instantiate_button(display_text, game, time):
	var button = ProjectButton.instantiate()
	button.display_text(display_text)
	match game:
		"Grid":
			button.pressed.connect(func(): launch_grid_game(button))
			button.display_desc_text("Click to gain %d experience" % projects_exp_gain[0])
		"Arc":
			button.pressed.connect(func(): launch_arc_game(button))
			button.display_desc_text("Click to gain %d experience" % projects_exp_gain[1])
		"Pin":
			button.pressed.connect(func(): launch_pin_drop_game(button))
			button.display_desc_text("Click to gain %d experience" % projects_exp_gain[2])
		"Spin":
			button.pressed.connect(func(): launch_sort_game(button))
			button.display_desc_text("Click to gain a bunch of applications :)")
	add_child(button)
	button.setup_timer(time)

func launch_grid_game(button) -> void:
	if overlay: return
	var game = GridGame.instantiate()
	game.project_completed.connect(on_grid_completed)
	open_overlay(button, game, func(): close())

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

func launch_sort_game(button) -> void:
	if overlay: return
	var game = SortGame.instantiate()
	game.project_completed.connect(on_sort_completed)
	open_overlay(button, game, func(): close())

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
	#game.project_completed.connect(close_function)
	overlay.add_child(game)
	button.queue_free()

func on_grid_completed() -> void:
	GlobalData.experience += projects_exp_gain[0]
	#var apps_gained = projects_exp_gain[0] / 4 + randi_range(-4, 5)
	#GlobalData.total_apps += apps_gained
	#GlobalData.global_total_apps += apps_gained
	GlobalData.exp_changed.emit()
	show_success_then_close()

func on_pin_drop_completed() -> void:
	GlobalData.experience += projects_exp_gain[1]
	#var apps_gained = projects_exp_gain[1] / 4 + randi_range(-4, 5)
	#GlobalData.total_apps += apps_gained
	#GlobalData.global_total_apps += apps_gained
	GlobalData.exp_changed.emit()
	show_success_then_close()

func on_arc_completed() -> void:
	GlobalData.experience += projects_exp_gain[2]
	#var apps_gained = projects_exp_gain[2] / 4 + randi_range(-4, 5)
	#GlobalData.total_apps += apps_gained
	#GlobalData.global_total_apps += apps_gained
	GlobalData.exp_changed.emit()
	show_success_then_close()

func on_sort_completed() -> void:
	GlobalData.experience += projects_exp_gain[3]
	var apps_gained = projects_exp_gain[3] + randi_range(-5, 25)
	GlobalData.total_apps += apps_gained
	GlobalData.global_total_apps += apps_gained
	GlobalData.apps_changed.emit()
	GlobalData.exp_changed.emit()
	show_success_then_close()

func show_success_then_close() -> void:
	if not overlay: return
	
	var background = overlay.get_child(0)
	var t = create_tween()
	t.tween_property(background, "color", Color(0.1, 0.6, 0.2, 0.85), 0.2)
	t.tween_property(background, "color", Color(0, 0, 0, 0.7), 0.2)
	
	var label = Label.new()
	label.text = "PROJECT COMPLETE!"
	label.add_theme_font_size_override("font_size", 64)
	label.modulate = Color.GREEN_YELLOW
	label.set_anchors_preset(Control.PRESET_CENTER)
	overlay.add_child(label)
	
	var t2 = create_tween().set_parallel(true)
	label.position = Vector2.ZERO
	t2.tween_property(label, "scale", Vector2.ONE * 1.2, 0.15)
	t2.tween_property(label, "scale", Vector2.ONE, 0.1).set_delay(0.15)
	
	await get_tree().create_timer(1.2).timeout
	
	var fade = create_tween().set_parallel(true)
	fade.tween_property(label, "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(0.3).timeout
	
	close()

func close() -> void:
	if overlay:
		overlay.queue_free()
		overlay = null # just in case
		
		# Add experience gain here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta
