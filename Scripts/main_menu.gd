extends Control

@onready var title_label = $TitleLabel
@onready var play_button = $VBoxContainer/PlayGameButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var background_panel = $Background

var total_time = 0

var starting_y

var play_button_rotate = false
var quit_button_rotate = false

var background_zoom_factor = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	AudioController.play_menu_music()
	await get_tree().process_frame
	
	title_label.pivot_offset = title_label.size / 2.0
	starting_y = title_label.position.y
	
	# Goals
	setup_button_hover(play_button)
	setup_button_hover(quit_button)
	setup_scrolling_background()

func setup_scrolling_background() -> void:
	# zoom the background in by a factor
	# move from position a to position b with a tween
	# repeat this forever
	background_panel.scale *= background_zoom_factor
	while true:
		var position_to_move_to = Vector2(randi_range(340, 1020) - 1280, randi_range(180, 540) - 720)
		var wait_time = clamp(background_panel.position.distance_to(position_to_move_to) / 300 * 6, 4, 8)
		print(background_panel.position.distance_to(position_to_move_to))
		var t = create_tween()
		t.tween_property(background_panel, "position", position_to_move_to, wait_time)
		t.set_ease(t.EASE_IN_OUT)
		await get_tree().create_timer(wait_time).timeout
		

func setup_button_hover(button: Button) -> void:
	button.pivot_offset = button.size / 2.0

func tween_button(button: Button, target: float) -> void:
	create_tween().tween_property(button, "scale", Vector2.ONE * target, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	
	#title_label.rotation_degrees = sin(total_time / 2.0) * 3.0
	
	var s = 1.0 + 0.01 * sin(total_time)
	title_label.scale = Vector2.ONE * s
	
	var hue = fmod(total_time * 0.1, 1.0)
	title_label.modulate = Color.from_hsv(hue, 0.4, 1.0)
	
	title_label.position.y = starting_y + sin(total_time / 2.0) * 16.0
	
	if play_button_rotate: play_button.rotation_degrees = sin(total_time / 1.5) * 5.0
	if quit_button_rotate: quit_button.rotation_degrees = sin(total_time / 1.5) * 5.0

func _on_play_game_button_pressed() -> void:
	AudioController.stop_menu_music()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_play_game_button_mouse_entered() -> void:
	tween_button(play_button, 1.05)
	play_button_rotate = true
	

func _on_play_game_button_mouse_exited() -> void:
	tween_button(play_button, 1.0)
	play_button_rotate = false
	create_tween().tween_property(play_button, "rotation_degrees", 0, 0.1)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_quit_button_mouse_entered() -> void:
	tween_button(quit_button, 1.05)
	quit_button_rotate = true

func _on_quit_button_mouse_exited() -> void:
	tween_button(quit_button, 1.0)
	quit_button_rotate = false
	create_tween().tween_property(quit_button, "rotation_degrees", 0, 0.1)
	
