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
	
	for i in range(GlobalData.num_results):
		var r = result_nodes[i]
		
		var timings = []
		var num_flips = randi_range(int(GlobalData.spin_time * 7.5), int(GlobalData.spin_time * 10.0))
		for time_index in range(num_flips):
			var linear_time = GlobalData.spin_time * time_index / num_flips
			var log_time = log(max(linear_time, 0) + 0.01) + GlobalData.spin_time
			var random_time = log_time + randf_range(-0.05, 0.05)
			var final_time = clamp(random_time, 0, GlobalData.spin_time)
			if final_time > 0 and final_time < GlobalData.spin_time: timings.append(GlobalData.spin_time - final_time)
		timings.sort()
		#print(timings)
		r.spin_to_win(results[i], timings)
	await get_tree().create_timer(GlobalData.spin_time).timeout
	button.disabled = false

func generate_results(num_results: int) -> Array[bool]:
	var to_return: Array[bool] = []
	for i in range(num_results): to_return.append(randf() < GlobalData.pass_chance)
	return to_return
