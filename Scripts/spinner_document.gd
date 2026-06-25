extends Node2D

signal game_over

const Result = preload("res://Scenes/result.tscn")
var result_nodes: Array = []

@export var button: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instantiate_result_nodes()

func instantiate_result_nodes():
	for i in range(GlobalData.num_results): # maybe later make it alwwys the same and not have to creatre new ones each time by putting them in _ready()
			var r = Result.instantiate()
			r.add_to_group("Results")
			r.position = (GlobalData.result_locations[i] - Vector2(150, 215)) / 4
			add_child(r)
			result_nodes.append(r)

func apply():
	position = Vector2(30, 25)
	modulate = Color(0.0, 0.0, 0.0, 0.0)
	rotation_degrees = 0
	scale = Vector2.ZERO
	
	var results = generate_results(GlobalData.num_results)
	var spin_time = GlobalData.stats["spin_time"]
	var is_all_pass = results.count(true) == GlobalData.num_results
	
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
	
	play_document_animation()
	
	if is_all_pass:
		await get_tree().create_timer(spin_time * 0.65, true, false, false).timeout
		print("hi")
		Engine.time_scale = 0.25
		print("hi")
		await get_tree().create_timer(spin_time * 0.35, true, false, false).timeout
		print("hi")
		Engine.time_scale = 1.0
	else:
		await get_tree().create_timer(spin_time).timeout

	if results.count(true) == 0: AudioController.play_spin_fail()
	elif results.count(true) == GlobalData.num_results:
		AudioController.play_spin_all_pass()
		if not GlobalData.finished_game: game_over.emit()
	else: AudioController.play_spin_pass()
	
	button.disabled = false
	button.modulate = Color.WHITE
	

func play_document_animation():
	# fall down to original position
	# tween to slight rotation angle
	var spin_time = GlobalData.stats["spin_time"]
	var t = create_tween().set_parallel(true)
	t.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), spin_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "rotation_degrees", 360, spin_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, spin_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

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
	var guaranteed = mini(GlobalData.stats["guaranteed_passes"], num_results)
	for i in guaranteed: to_return.append(true)
	for i in num_results - guaranteed: to_return.append(randf() < GlobalData.stats["pass_chance"])
	to_return.shuffle()
	return to_return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
