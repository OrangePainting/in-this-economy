extends Node2D

var projects_hidden = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TabContainer.set_tab_hidden(1, true)
	%TabContainer.current_tab = 2
	GlobalData.upgrade_purchased.connect(check_unlock_projects)

func check_unlock_projects() -> void:
	if GlobalData.has_upgrade("3. Unlock Projects"):
		var now_unlocked = %TabContainer.is_tab_hidden(1) and projects_hidden
		%TabContainer.set_tab_hidden(1, false)
		if now_unlocked:
			projects_hidden = false
			animate_tab_unlocking()
		if GlobalData.upgrade_level("3. Unlock Projects") == 4:
			$TabContainer/Projects/InfoLabel.visible = false

func animate_tab_unlocking() -> void:
	var label = Label.new()
	label.text = "Projects Unlocked!"
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color.GREEN_YELLOW
	label.position = %TabContainer.position + Vector2(80, -40)
	get_parent().add_child(label)
	
	var t = create_tween().set_parallel(true)
	t.tween_property(label, "position:y", label.position.y - 60, 1.5)
	t.tween_property(label, "modulate:a", 0.0, 1.5)
	t.tween_callback(label.queue_free).set_delay(1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$TabContainer/Projects/TimeLabel.text = "Next Project In: %d seconds" % snappedf($TabContainer/Projects/ScrollContainer/ProjectContainer.time_until_next(), 0.1)
