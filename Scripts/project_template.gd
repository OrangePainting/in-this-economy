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
	timer_tween.set_parallel(true)
	timer_tween.tween_property(%ProgressBar, "scale:x", 0.0, time)
	timer_tween.tween_callback(queue_free).set_delay(time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_text(text: String) -> void:
	%NameLabel.text = text

func display_desc_text(text: String) -> void:
	%DescriptionLabel.text = text

func return_text() -> String:
	return %NameLabel.text

func _on_pressed() -> void:
	pass # Replace with function body.
