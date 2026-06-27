extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_text(pass_num: int, desc_text: String) -> void:
	%NameLabel.text = "New Best: %s / %s!" % [pass_num, GlobalData.num_results]
	$CountLabel.text = "x%s" % pass_num
	%DescriptionLabel.text = desc_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
