extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_text() -> void:
	%NameLabel.text = "%s / %s PASSES!" % [GlobalData.current_best, GlobalData.num_results]
	$CountLabel.text = "x%s" % GlobalData.current_best

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
