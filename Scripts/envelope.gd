extends TextureButton

const SpinnerDocument = preload("res://Scenes/spinner_document.tscn")

@export var button: TextureButton
var win_screen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = true

func apply() -> void:
	position = Vector2(randi_range(0,720), -100)
	rotation_degrees = 0

	var t = create_tween().set_parallel(true)
	t.tween_property(self, "position", Vector2(480, randi_range(200, 250)), GlobalData.stats["spin_time"]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "rotation_degrees", randf_range(-5, 5), GlobalData.stats["spin_time"]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(GlobalData.stats["spin_time"] * 0.5).timeout
	disabled = false

func _pressed() -> void:
	disabled = true
	texture_disabled = texture_pressed
	AudioController.play_open_letter()
	
	var doc = SpinnerDocument.instantiate()
	add_child(doc)
	doc.button = button
	if not GlobalData.finished_game: doc.game_over.connect(win_screen.on_game_over)
	doc.apply()
	GlobalData.total_apps += GlobalData.stats["apps_per_spin"]
	GlobalData.global_total_apps += GlobalData.stats["apps_per_spin"]
	GlobalData.apps_changed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE and not disabled:
			_pressed()
			get_viewport().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
