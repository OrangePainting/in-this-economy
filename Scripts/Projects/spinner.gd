extends Node2D

var spinner_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spinner_size = %SpinnerBackground.get_rect().size * %SpinnerBackground.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rotate_spinner() -> void:
	%SpinnerBackground.rotation_degrees = fmod(%SpinnerBackground.rotation_degrees + 90.0, 360.0)
