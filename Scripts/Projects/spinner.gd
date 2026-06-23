extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rotate_spinner() -> void:
	%SpinnerBackground.rotation_degrees = fmod(%SpinnerBackground.rotation_degrees + 90.0, 360.0)
