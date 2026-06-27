extends Node2D

signal auto_apply_complete

var auto_apply_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	setup_auto_apply()
	GlobalData.upgrade_purchased.connect(refresh_auto_apply)

func setup_auto_apply() -> void:
	auto_apply_timer = Timer.new()
	auto_apply_timer.one_shot = false
	auto_apply_timer.timeout.connect(on_auto_apply)
	add_child(auto_apply_timer)
	refresh_auto_apply()


func refresh_auto_apply() -> void:
	if not GlobalData.has_upgrade("7. Auto Apply"):
		auto_apply_timer.stop()
		return
	 
	auto_apply_timer.wait_time = GlobalData.stats["auto_apply_time"]
	auto_apply_timer.start()

func on_auto_apply() -> void:
	GlobalData.total_apps += GlobalData.stats["apps_per_spin"]
	GlobalData.global_total_apps += GlobalData.stats["apps_per_spin"]
	for i in range(GlobalData.num_results):
		if randf() < GlobalData.stats["pass_chance"] / 5.0: GlobalData.experience += 1
	
	GlobalData.exp_changed.emit()
	GlobalData.apps_changed.emit()
	auto_apply_complete.emit()
