extends Node2D

@export var grid: Node2D

var goal_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_pos(x, y) -> void:
	goal_pos = Vector2(x, y)
	position = goal_pos * grid.CELL_SIZE
