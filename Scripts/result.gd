extends Node2D

@onready var fail_sprite = $FailSprite
@onready var pass_sprite = $PassSprite


var current_visible_sprite: int = 1 # in process will change which sprite is visible depending on this value, should randomize later
	# 0 = none, 1 = fail, 2 = pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_visible_sprite(current_visible_sprite)

func set_visible_sprite(sprite_num: int) -> void:
	if sprite_num == 1: # fail
		fail_sprite.set_visible(true)
		pass_sprite.set_visible(false)
	elif sprite_num == 2: # pass
		fail_sprite.set_visible(false)
		pass_sprite.set_visible(true)
	else: # none
		fail_sprite.set_visible(false)
		pass_sprite.set_visible(false)

func spin_to_win(passed: bool,  timings: Array = [0.1, 0.3, 0.5, 0.7, 0.9]) -> void:
	for time in timings.slice(0, -1):
		var partial_timer = Timer.new()
		add_child(partial_timer)
		partial_timer.set_wait_time(time)
		partial_timer.one_shot = true
		partial_timer.start()
		partial_timer.timeout.connect(flip_sprite)
		print(time)
	
	var switch_timer = Timer.new()
	add_child(switch_timer)
	switch_timer.set_wait_time(timings[-1])
	switch_timer.one_shot = true
	switch_timer.start()
	switch_timer.timeout.connect(func(): on_switch_timer_timeout(passed))

func flip_sprite() -> void:
	if current_visible_sprite == 1: current_visible_sprite = 2
	elif current_visible_sprite == 2: current_visible_sprite = 1

func on_switch_timer_timeout(passed: bool) -> void:
	if passed: current_visible_sprite = 2
	else: current_visible_sprite = 1
