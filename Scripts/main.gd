extends Node2D

const Result = preload("res://Scenes/result.tscn")
var result_nodes: Array = []

@onready var button = $SpinButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	for i in range(GlobalData.num_results): # maybe later make it alwwys the same and not have to creatre new ones each time by putting them in _ready()
			var r = Result.instantiate()
			r.add_to_group("Results")
			r.position = GlobalData.result_locations[i]
			add_child(r)
			result_nodes.append(r)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spin_button_pressed() -> void:
	# create 8 (current num) different results, have them spawn in predetermined positions
	# - use the chance which can be upgraded (so put in global_data)
	# randomize a number of flips (15 - 20)
	# randomize the timings they flip in
	# - split into chunks, add a slight waver in either direction for timing
	# total_time for it to flip can be upgraded too (so put in global_data)
	# call the spin_to_win function with these timings

	button.disabled = true # Add disabled button sprite here too
	
	GlobalData.total_apps += 1
	GlobalData.currency_changed.emit()
	
	var results = generate_results(GlobalData.num_results)
	
	var num_flips = max(8, randi_range(int(GlobalData.stats["spin_time"] * 7.5), int(GlobalData.stats["spin_time"] * 10.0)))
	var base_timings = generate_base_timings(num_flips, GlobalData.stats["spin_time"]) # need to fix so that small spin times can still work
	#base_timings.sort() # no need to sort again because we sort in the loop
	for i in range(GlobalData.num_results):
		var noisy_times = base_timings.map(func(t): return clamp(t + randf_range(-0.1, 0.1), 0, GlobalData.stats["spin_time"]))
		noisy_times.sort()
		result_nodes[i].spin_to_win(results[i], noisy_times)
	await get_tree().create_timer(GlobalData.stats["spin_time"]).timeout
	button.disabled = false

func generate_base_timings(num_flips: int, spin_time: float) -> Array[float]:
	var timings: Array[float] = []
	
	for time_index in range(num_flips):
			var linear_time = spin_time * time_index / num_flips
			var log_time = log(max(linear_time, 0) + 0.01) + spin_time
			if log_time > 0 and log_time < spin_time: timings.append(spin_time - log_time)
	
	return timings

func generate_results(num_results: int) -> Array[bool]:
	var to_return: Array[bool] = []
	for i in range(num_results): to_return.append(randf() < GlobalData.stats["pass_chance"])
	return to_return
