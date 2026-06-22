extends Control

@onready var title_label = $TitleLabel
@onready var play_button = $VBoxContainer/PlayGameButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var background_panel = $Background

var total_time = 0
var starting_y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioController.play_menu_music()
	await get_tree().process_frame
	
	title_label.pivot_offset = title_label.size / 2.0
	starting_y = title_label.position.y
	
	# Goals
	setup_button_hover(play_button)
	setup_button_hover(quit_button)
	#setup_scrolling_background()

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

func _on_play_game_button_pressed() -> void:
	AudioController.stop_menu_music()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_play_game_button_mouse_entered() -> void:
	tween_button(play_button, 1.05)

func _on_play_game_button_mouse_exited() -> void:
	tween_button(play_button, 1.0)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_quit_button_mouse_entered() -> void:
	tween_button(quit_button, 1.05)

func _on_quit_button_mouse_exited() -> void:
	tween_button(quit_button, 1.0)
