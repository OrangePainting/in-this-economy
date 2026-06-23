extends TextureButton

var total_time: float
var time_left: float
var timer_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func setup_timer(time: float) -> void:
	total_time = time
	time_left = time
	if timer_tween: timer_tween.kill()
	timer_tween = create_tween()
	timer_tween.tween_callback(func(): queue_free()).set_delay(time) # timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	%ProgressBar.scale.x = time_left / total_time

func display_text(text: String) -> void:
	%NameLabel.text = text

func _on_pressed() -> void:
	pass # Replace with function body.
