extends Node2D

const Result = preload("res://Scenes/result.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spin_button_pressed() -> void:
	# create 8 (current num) different results, have them spawn in determined positions
	# - use the chance which can be upgraded (so put in global_data)
	# randomize a number of flips (15 - 20)
	# randomize the timings they flip in
	# - split into chunks, add a slight waver in either direction for timing
	# total_time for it to flip can be upgraded too (so put in global_data)
	# call the spin_to_win function with these timings
	
	for child in get_children():
		print(child.is_in_group("Results"))
		if child.is_in_group("Results"):
			child.queue_free()

	var result_locations: Array[Vector2] = [Vector2(320, 172),
											Vector2(256, 236),
											Vector2(88, 292),
											Vector2(216, 356),
											Vector2(272, 412),
											Vector2(152, 476),
											Vector2(344, 476),
											Vector2(152, 540)]
	
	var results = generate_results(GlobalData.num_results)
	
	for i in range(GlobalData.num_results):
		var r = Result.instantiate()
		r.add_to_group("Results")
		r.position = result_locations[i]
		add_child(r)
		
		var timings = []
		var num_flips = randi_range(15, 20)
		for time_index in range(num_flips):
			var time = GlobalData.spin_time * time_index / num_flips
			var random_time = time + randf_range(-0.05, 0.05)
			timings.append(max(0, random_time))
		timings.sort()
		print(timings)
		r.spin_to_win(results[i], timings)

func generate_results(num_results: int) -> Array[bool]:
	var to_return: Array[bool] = []
	for i in range(num_results): to_return.append(randf() < GlobalData.pass_chance)
	return to_return
	
	
	
	
	
	
	
	
	
	
	
