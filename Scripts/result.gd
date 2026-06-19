extends Node2D

@onready var fail_sprite = $FailSprite
@onready var pass_sprite = $PassSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fail_sprite.set_visible(false)
	pass_sprite.set_visible(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spin_to_win(passed: float,  timings: Array[float]) -> void:
	var time_index: int = 0
	var current_passed_on: bool = false # in process will change which sprite is visible depending on this value, should randomize later
	
