extends Node2D

signal game_completed
signal person_moved

@export var grid: Node2D
@export var goal: Node2D

@export_group("Movement Properties")
@export var move_length: float

var player_pos = Vector2.ZERO
var starting_pos = Vector2.ZERO
var draw_pos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = grid.position

func button_pressed(direction: int) -> void:
	var dir = Vector2.ZERO
	match direction:
		0: dir = Vector2.UP
		1: dir = Vector2.RIGHT
		2: dir = Vector2.DOWN
		3: dir = Vector2.LEFT
	
	move(dir)

func set_pos(x, y) -> void:
	player_pos = Vector2(x, y)
	position = player_pos * grid.CELL_SIZE

func move(dir):
	var next = player_pos + dir
	if next.x < 0 or next.x >= grid.GRID_SIZE or next.y < 0 or next.y >= grid.GRID_SIZE: return
	player_pos = next
	person_moved.emit()
	
	if check_reached_goal(): game_completed.emit()
	
	var target = grid.position + player_pos * grid.CELL_SIZE
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", target, move_length)

func check_reached_goal() -> bool:
	return goal.goal_pos == player_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
