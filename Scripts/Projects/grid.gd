extends Node2D

const Square = preload("res://Scenes/Projects/square.tscn")

@export_group("Grid Properties")
@export var GRID_SIZE: int
@export var CELL_SIZE: int
var grid = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_grid() -> void:
	for row in GRID_SIZE:
		grid.append([])
		for col in GRID_SIZE:
			var s = Square.instantiate()
			s.position = Vector2(row, col) * CELL_SIZE
			add_child(s)
			grid[row].append(s)
