extends Node2D

var spike_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_pos(x, y, CELL_SIZE) -> void:
	spike_pos = Vector2(x, y)
	position = spike_pos * CELL_SIZE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
