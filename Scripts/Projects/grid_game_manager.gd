extends Control

@export var grid: Node2D
@export var goal: Node2D
@export var person: Node2D
@export var spinner: Node2D
@export var button: Button

var total_time: float = 0

var current_direction = 0 # Up, then clockwise
var spin_delay = 0.4

const Spike = preload("res://Scenes/Projects/spike.tscn")

var num_spikes: int
var spikes = []

const PADDING = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	person.person_moved.connect(check_obstacle_collision)
	
	spinner.position = Vector2.RIGHT * grid.GRID_SIZE * grid.CELL_SIZE + Vector2.RIGHT * PADDING
	button.position = spinner.position + Vector2.DOWN * spinner.spinner_size.y + Vector2.DOWN * PADDING
	%InfoLabel.position = button.position + Vector2.DOWN * button.size.y + Vector2.DOWN * PADDING

	num_spikes = grid.GRID_SIZE
	for i in num_spikes:
		var s = Spike.instantiate()
		s.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1), grid.CELL_SIZE)
		add_child(s)
		spikes.append(s)
	
	var reset = true
	while reset:
		reset = false
		# while person is too close to goal or spikes overlaps with player or goal, randomize positions again
		person.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
		goal.set_pos(randi_range(0, grid.GRID_SIZE - 1), randi_range(0, grid.GRID_SIZE - 1))
		if person.player_pos.distance_to(goal.goal_pos) < 3: reset = true
		for s in spikes: 
			if s.spike_pos == person.player_pos: reset = true
	
	person.starting_pos = person.player_pos
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_callback(change_direction).set_delay(spin_delay)

func check_obstacle_collision() -> void:
	for s in spikes:
		if s.spike_pos == person.player_pos:
			person.player_pos = person.starting_pos
			var tween = create_tween()
			tween.tween_property(person, "modulate", Color.RED, 0.1)
			tween.tween_property(person, "modulate", Color.WHITE, 0.3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta

func change_direction() -> void:
	current_direction = (current_direction + 1) % 4
	spinner.rotate_spinner()

func _on_button_pressed() -> void:
	person.button_pressed(current_direction)
