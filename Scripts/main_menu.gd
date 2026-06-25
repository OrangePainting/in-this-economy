extends Control

signal click

@onready var title_label = $TitleLabel
@onready var play_button = $VBoxContainer/PlayGameButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var background_panel = $Background

var total_time = 0

var starting_y = 167

var play_button_rotate = false
var quit_button_rotate = false

var background_zoom_factor = 3

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed: click.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	await get_tree().process_frame
	
	await play_intro_animation()
	
	title_label.pivot_offset = title_label.size / 2.0
	starting_y = title_label.position.y
	
	# Goals
	setup_button_hover(play_button)
	setup_button_hover(quit_button)
	setup_scrolling_background()

func play_intro_animation() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	title_label.visible = false
	play_button.visible = false
	quit_button.visible = false
	$InfoLabelTop.visible = false
	$InfoLabelBottom.visible = false
	$Logo.visible = false
	$Particles.emitting = false
	
	# Made For: | the Very Serious | Juniper Dev Game Jam
	# By: | OrangePainting | Logo.png
	# A | satirical view | on jobs
	# Have fun! 
	var possible_lines = [
		["Have", " Fun", " :)"],
		["Idk", " what to", " put here"],
		["Don't", " take this", " seriously :)"],]
	
	await click
	
	AudioController.play_menu_music()
	$InfoLabelTop.visible = true
	$InfoLabelTop.text = "Made For:"
	await  beat(1.17)
	$InfoLabelTop.text = "Made For: \n The Very Serious"
	await  beat(0.66)
	$InfoLabelTop.text = "Made For: \n The Very Serious \n Juniper Dev Game Jam"
	await  beat(1)
	$InfoLabelTop.visible = false
	await  beat(1.03)
	
	$InfoLabelBottom.visible = true
	$InfoLabelBottom.text = "By:"
	await  beat(0.78)
	$InfoLabelBottom.text = "By: OrangePainting"
	await  beat(0.67)
	$Logo.visible = true
	await  beat(1)
	$Logo.visible = false
	$InfoLabelBottom.visible = false
	await beat(0.96)
	
	$InfoLabelTop.visible = true
	$InfoLabelTop.text = "No"
	await  beat(0.85)
	$InfoLabelTop.text = "No sillyness"
	await  beat(0.65)
	$InfoLabelTop.text = "No sillyness here"
	await  beat(1)
	await beat(0.91)
	
	var bottom_label_text = possible_lines[randi_range(0, len(possible_lines) - 1)]
	$InfoLabelBottom.visible = true
	$InfoLabelBottom.text = bottom_label_text[0]
	await  beat(0.85)
	$InfoLabelBottom.text = bottom_label_text[0] + bottom_label_text[1]
	await  beat(0.66)
	$InfoLabelBottom.text = bottom_label_text[0] + bottom_label_text[1] + bottom_label_text[2]
	await  beat(1)
	$InfoLabelTop.visible = false
	$InfoLabelBottom.visible = false
	create_tween().tween_property(self, "modulate", Color.BLACK, 0.51)
	await beat(0.51)
	title_label.visible = true
	play_button.visible = true
	quit_button.visible = true
	$Particles.emitting = true
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.51)
	#await  beat(0.4)
	
	
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT

func beat(seconds: float) -> void:
	#title_label.visible = not title_label.visible
	await get_tree().create_timer(seconds, true).timeout

func setup_scrolling_background() -> void:
	# zoom the background in by a factor
	# move from position a to position b with a tween
	# repeat this forever
	background_panel.scale *= background_zoom_factor
	while true:
		var position_to_move_to = Vector2(randi_range(0, 1280) - 1280, randi_range(0, 720) - 720)
		var wait_time = clamp(background_panel.position.distance_to(position_to_move_to) / 300 * 6, 4, 8)
		var t = create_tween()
		t.tween_property(background_panel, "position", position_to_move_to, wait_time)
		t.set_trans(t.TRANS_CUBIC)
		await get_tree().create_timer(wait_time).timeout
		if not is_inside_tree(): return
		

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
	create_tween().tween_property(self, "modulate", Color.BLACK, 0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")

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
	
