extends Node2D


@onready var app_num_label = $AppsLabel
@onready var exp_label = $ExpLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	app_num_label.text = "%d" % GlobalData.total_apps
	exp_label.text = "%d" % GlobalData.experience
