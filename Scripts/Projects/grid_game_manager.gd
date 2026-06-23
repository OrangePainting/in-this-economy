extends Control

@export var grid: Node2D
@export var goal: Node2D
@export var person: Node2D
@export var spinner: Node2D
@export var button: Button

var current_direction = 0 # Up, then clockwise
var spin_delay = 0.4

const PADDING = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	button.position = Vector2.DOWN * grid.GRID_SIZE * grid.CELL_SIZE + Vector2.ONE * PADDING
	spinner.position = Vector2.RIGHT * grid.GRID_SIZE * grid.CELL_SIZE + Vector2.RIGHT * PADDING
	
	person.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
	goal.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
	while person.player_pos.distance_to(goal.goal_pos) < 3:
		person.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
		goal.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_callback(change_direction).set_delay(spin_delay)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_direction() -> void:
	current_direction = (current_direction + 1) % 4
	spinner.rotate_spinner()

func _on_button_pressed() -> void:
	person.button_pressed(current_direction)
