extends Node2D

signal game_over

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
	
	AudioController.play_in_game_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spin_button_pressed() -> void:
	button.disabled = true # Add disabled button sprite here too
	button.modulate = Color(1.0, 0.2, 0.2, 0.3)
	AudioController.play_apply()
	
	GlobalData.total_apps += 1
	GlobalData.currency_changed.emit()
	
	var results = generate_results(GlobalData.num_results)
	var spin_time = GlobalData.stats["spin_time"]
	
	var num_flips = clamp(int(spin_time * 8.0), 8, 60)
	var base_timings = generate_base_timings(num_flips, spin_time)
	
	#base_timings.sort() # no need to sort again because we sort in the loop
	var noise_amount = spin_time * 0.04
	for i in range(GlobalData.num_results):
		var noisy_times = base_timings.slice(0, -1).map(
			func(t): return clamp(t + randf_range(-noise_amount, noise_amount), 0.0, spin_time))
		noisy_times.append(spin_time + randf_range(-noise_amount * 2, noise_amount * 2))
		noisy_times.sort()
		result_nodes[i].spin_to_win(results[i], noisy_times)
	
	await get_tree().create_timer(spin_time).timeout
	if results.count(true) == 0: AudioController.play_spin_fail()
	elif results.count(true) == 8:
		AudioController.play_spin_all_pass()
		game_over.emit()
	else: AudioController.play_spin_pass()
	button.disabled = false
	button.modulate = Color.WHITE

# used log function previously, but a power function is probably better and cleaner here
# goal is to make a lot of flips at the beginning, flips become more sparse when nearing the end
func generate_base_timings(num_flips: int, spin_time: float) -> Array[float]:
	var timings: Array[float] = []
	var power = 2.0
	
	for i in range(1, num_flips + 1):
		var linear_split = float(i) / float(num_flips)
		var power_split = pow(linear_split, power)
		timings.append(spin_time * power_split)
	
	return timings

func generate_results(num_results: int) -> Array[bool]:
	var to_return: Array[bool] = []
	for i in range(num_results): to_return.append(randf() < GlobalData.stats["pass_chance"])
	return to_return
