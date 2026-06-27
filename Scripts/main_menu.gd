extends Control

signal click

@onready var title_label = $TitleLabel
@onready var play_button = $VBoxContainer/PlayGameButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var background_panel = $Background

var total_time = 0
var skip_intro = false
var starting_y = 167

var play_button_rotate = false
var credits_button_rotate = false
var title_hovered = false

var background_zoom_factor = 3

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed: click.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	await get_tree().process_frame
	
	await play_intro_animation()
	
	title_label.pivot_offset = title_label.size / 2.0
	starting_y = title_label.position.y
	
	setup_button_hover(play_button)
	setup_button_hover(credits_button)
	setup_scrolling_background()

func play_intro_animation() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$ClickLabel.visible = true
	$SkipButton.visible = false
	$"Credits Info".visible = false
	title_label.visible = false
	play_button.visible = false
	credits_button.visible = false
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
		["Idk", " what to", " say"],
		["Don't", " take this", " seriously :)"],
		["Yet", " another", " clicker game"],
		["I", " am", " bored"],
		["Can you beat", "\nthis game in", "\nfifteen minutes?"],
		["Go", " touch", " grass"],
		["I", " like", " Godot"],
		["This", " text is", " randomized"]
		]
	var bottom_label_text = possible_lines[randi_range(0, len(possible_lines) - 1)]
	
	await click
	
	$SkipButton.visible = true
	$ClickLabel.visible = false
	
	AudioController.play_menu_music()
	$InfoLabelTop.visible = true
	$InfoLabelTop.text = "Entry For:"
	await  beat(1.17)
	$InfoLabelTop.text = "Entry For: \n The Very Serious"
	await  beat(0.66)
	$InfoLabelTop.text = "Entry For: \n The Very Serious \n Juniper Dev Game Jam"
	await  beat(1)
	$InfoLabelTop.visible = false
	await  beat(1.03)
	
	$InfoLabelBottom.visible = true
	$InfoLabelBottom.text = "Made"
	$Logo.visible = true
	$Logo.position = Vector2(640, -200)
	$Logo.rotation_degrees = 180
	create_tween().tween_property($Logo, "position", Vector2(640, 200), 1.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	create_tween().tween_property($Logo, "rotation_degrees", 0, 1.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await  beat(0.78)
	$InfoLabelBottom.text = "Made By:"
	await  beat(0.67)
	$InfoLabelBottom.text = "Made By: OrangePainting"
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
	
	$SkipButton.visible = false
	title_label.visible = true
	play_button.visible = true
	credits_button.visible = true
	$Particles.emitting = true
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.51)
	#await  beat(0.4)
	
	
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT

func beat(seconds: float) -> void:
	if skip_intro: return
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

func tween_button(node, target: float) -> void:
	create_tween().tween_property(node, "scale", Vector2.ONE * target, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	
	title_label.rotation_degrees = sin(total_time / 2.0) * 3.0
	
	var s = 1.0 + 0.01 * sin(total_time)
	if not title_hovered: title_label.scale = Vector2.ONE * s
	
	var hue = fmod(total_time * 0.1, 1.0)
	title_label.modulate = Color.from_hsv(hue, 0.4, 1.0)
	
	title_label.position.y = starting_y + sin(total_time / 2.0) * 16.0
	
	if play_button_rotate: play_button.rotation_degrees = sin(total_time / 1.5) * 5.0
	if credits_button_rotate: credits_button.rotation_degrees = sin(total_time / 1.5) * 5.0

func scroll_credits() -> void:
	var credits_wait_time = 30
	$"Credits Info".visible = true
	$"Credits Info".position = Vector2(1280, 0)
	credits_button.disabled = true
	create_tween().tween_property($"Credits Info", "position", Vector2(-8500, 0), credits_wait_time)
	await get_tree().create_timer(credits_wait_time).timeout
	credits_button.disabled = false
	
	

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

func _on_credits_button_pressed() -> void:
	scroll_credits()

func _on_credits_button_mouse_entered() -> void:
	tween_button(credits_button, 1.05)
	credits_button_rotate = true

func _on_credits_button_mouse_exited() -> void:
	tween_button(credits_button, 1.0)
	credits_button_rotate = false
	create_tween().tween_property(credits_button, "rotation_degrees", 0, 0.1)

func _on_title_label_mouse_entered() -> void:
	title_hovered = true
	tween_button($TitleLabel, 1.05)


func _on_title_label_mouse_exited() -> void:
	title_hovered = false
	tween_button($TitleLabel, 1.0)


func _on_skip_button_pressed() -> void:
	skip_intro = true
	click.emit()
