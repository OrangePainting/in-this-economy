extends Control

var randomized_industry_names = [
	"Game Dev",
	"Medical",
	"Job",
	"Physics",
	"Evil",
	"Money",
	"AI",
	"Lawyer",
	"Insurance",
	"Real Estate",
	"Banking",
	"Oil",
	"School",
	"Construction",
	"Nursing",
	"Trucking",
	"Transportation",
	"Architecture",
	"Systems",
	"Engineering",
	"Quantum",
	"Agriculture"
]
var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%LineEdit.gui_input.connect(func(e):
		if e is InputEventScreenTouch and e.pressed:
			%LineEdit.grab_focus()
			DisplayServer.virtual_keyboard_show(%LineEdit.text))
	
	modulate = Color.BLACK
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5)
	if len(%LineEdit.text) > 0: $%StartButton.disabled = false
	else: $%StartButton.disabled = true
	await get_tree().create_timer(0.5).timeout




func _on_start_button_pressed() -> void:
	GlobalData.industry_name = %LineEdit.text
	AudioController.stop_menu_music()
	create_tween().tween_property(self, "modulate", Color.BLACK, 0.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_line_edit_text_changed(new_text: String) -> void:
	if len(new_text) > 0: $%StartButton.disabled = false
	else: $%StartButton.disabled = true


func _on_randomize_button_pressed() -> void:
	%LineEdit.text = randomized_industry_names[current_index % len(randomized_industry_names)]
	if current_index >= len(randomized_industry_names): current_index = randi_range(0, len(randomized_industry_names) - 1) + len(randomized_industry_names) # bug where same name can apply twice (either add animation or prevent this from happening)
	else: current_index += 1
	_on_line_edit_text_changed(%LineEdit.text)
