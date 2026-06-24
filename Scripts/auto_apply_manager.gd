extends Node2D

signal auto_apply_complete

var auto_apply_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	setup_auto_apply()
	GlobalData.currency_changed.connect(refresh_auto_apply)

func setup_auto_apply() -> void:
	auto_apply_timer = Timer.new()
	auto_apply_timer.one_shot = false
	auto_apply_timer.timeout.connect(on_auto_apply)
	add_child(auto_apply_timer)
	refresh_auto_apply()

func has_auto_apply_upgrade() -> bool:
	for upgrade in GlobalData.upgrades_bought:
		if upgrade.id == "Auto Apply": return true
	return false

func refresh_auto_apply() -> void:
	if not has_auto_apply_upgrade():
		auto_apply_timer.stop()
		return
	
	var time = GlobalData.stats["auto_apply_time"]
	if auto_apply_timer.is_stopped(): auto_apply_timer.start()
	else: auto_apply_timer.wait_time = time

func on_auto_apply() -> void:
	GlobalData.total_apps += 1
	for i in range(GlobalData.num_results):
		if randf() < GlobalData.stats["pass_chance"] / 5.0: GlobalData.experience += 1
	GlobalData.currency_changed.emit()
	
	auto_apply_complete.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
