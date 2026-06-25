extends Control

signal project_completed

@export var grid: Node2D
@export var goal: Node2D
@export var person: Node2D
@export var spinner: Node2D
@export var button: Button

var total_time: float = 0
var current_direction = 0 # Up, then clockwise
var spin_delay = 0.4

var done = false

const Spike = preload("res://Scenes/Projects/spike.tscn")
var num_spikes: int
var spikes: Array = []

var starting_time = 30.0
var last_display = -1.0

const PADDING = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	person.person_moved.connect(check_obstacle_collision)
	
	spinner.position = Vector2.RIGHT * grid.GRID_SIZE * grid.CELL_SIZE + Vector2.RIGHT * PADDING
	button.position = spinner.position + Vector2.DOWN * spinner.spinner_size.y + Vector2.ONE * PADDING
	%InfoLabel.position = button.position + Vector2.DOWN * button.size.y + Vector2.DOWN * PADDING
	%TimeLabel.position = Vector2.DOWN * grid.GRID_SIZE * grid.CELL_SIZE + Vector2.ONE * PADDING

	num_spikes = grid.GRID_SIZE
	for i in num_spikes:
		var s = Spike.instantiate()
		add_child(s)
		spikes.append(s)
	
	randomize_positions()
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_callback(change_direction).set_delay(spin_delay)

func randomize_positions() -> void:
	var reset = true
	while reset:
		reset = false
		var spike_cells: Array[Vector2] = []
		for s in spikes:
			var pos = Vector2(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
			s.set_pos(pos.x, pos.y, grid.CELL_SIZE)
			if pos in spike_cells: reset = true
			else: spike_cells.append(pos)

		# while person is too close to goal or spikes overlaps with player or goal, randomize positions again
		person.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
		goal.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
		
		if person.player_pos.distance_to(goal.goal_pos) < 3: reset = true
		if person.player_pos in spike_cells: reset = true
		if goal.goal_pos in spike_cells: reset = true
		if not has_path(person.player_pos, goal.goal_pos, spike_cells): reset = true
		
	person.starting_pos = person.player_pos
	grid.highlight_cell(person.player_pos, Color(0.31, 0.46, 0.009, 1.0))

func has_path(start: Vector2, end: Vector2, walls: Array) -> bool:
	var queue: Array[Vector2] = [start]
	var visited = {start: true}
	var dirs = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	while not queue.is_empty():
		var cur = queue.pop_front()
		if cur == end: return true
		for d in dirs:
			var next = cur + d
			if next.x < 0 or next.x >= grid.GRID_SIZE or next.y < 0 or next.y >= grid.GRID_SIZE: continue
			if visited.has(next) or next in walls: continue
			visited[next] = true
			queue.append(next)
	return false

func check_obstacle_collision() -> void:
	if goal.goal_pos == person.player_pos:
		project_completed.emit()
		return
	
	for s in spikes:
		if s.spike_pos == person.player_pos:
			person.reset_to_start()
			var tween = create_tween()
			tween.tween_property(person, "modulate", Color.RED, 0.1)
			tween.tween_property(person, "modulate", Color.WHITE, 0.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if done:
		$Button.disabled = true
		$Button.text = "Time's Up!"
		return
	total_time += delta
	var display = snappedf(starting_time - total_time, 0.01)
	if display != last_display: 
		last_display = display
		%TimeLabel.text = "Time Left: %.2f" % maxf(display, 0)
	
	if display <= 0: done = true

func change_direction() -> void:
	if not done:
		current_direction = (current_direction + 1) % 4
		spinner.rotate_spinner()

func _on_button_pressed() -> void:
	person.button_pressed(current_direction)
