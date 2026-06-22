extends Node2D


@onready var app_num_label = $CanvasLayer/AppsLabel
@onready var exp_label = $CanvasLayer/ExpLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.currency_changed.connect(update_label_text)
	update_label_text()

func update_label_text() -> void:
	app_num_label.text = "%d" % GlobalData.total_apps
	exp_label.text = "%d" % GlobalData.experience


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_auto_apply_complete() -> void:
	var app_tween = app_num_label.create_tween()
	var exp_tween = exp_label.create_tween()
	app_tween.tween_property(app_num_label, "modulate", Color(0.5, 0.8, 1.0), 0.15)
	exp_tween.tween_property(exp_label, "modulate", Color(0.5, 0.8, 1.0), 0.15)
	app_tween.tween_property(app_num_label, "modulate", Color.WHITE, 0.15)
	exp_tween.tween_property(exp_label, "modulate", Color.WHITE, 0.15)
	
