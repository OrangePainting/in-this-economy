extends Control

signal upgrade_is_maxed(name)

@onready var name_label = $HBoxContainer/InfoContainer/NameLabel
@onready var desc_label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var app_cost_label = $HBoxContainer/CostLabelContainer/AppCostLabel
@onready var exp_cost_label = $HBoxContainer/CostLabelContainer/ExpCostLabel
@onready var max_label = $HBoxContainer/CostLabelContainer/MaxLabel

var upgrade
var tween: Tween

var was_affordable = false

func get_current_level() -> int:
	return GlobalData.upgrades_bought.get(upgrade.id, 0)

func next_level() -> void:
	if tween: tween.kill()
	tween = create_tween()
	if GlobalData.can_buy(upgrade, get_current_level()):
		GlobalData.buy_upgrade(upgrade, get_current_level())
		update_labels_and_button()
		update_label_colors()
		var final_color = Color(1, 1, 1, 0.5) if is_maxed() else Color.WHITE
		tween.tween_property(self, "modulate", Color.YELLOW_GREEN, 0.1)
		tween.tween_property(self, "modulate", final_color, 0.1)
		
		spawn_float_label("Upgraded!" if not is_maxed() else "MAXED!")
		if not is_maxed(): pulse_next_available()
		
		if is_maxed(): upgrade_is_maxed.emit(upgrade.display_name)
	else:
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func spawn_float_label(message: String) -> void:
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 20)
	label.position = Vector2(size.x / 2.0 - 40, 0)
	label.modulate = Color.GREEN_YELLOW
	add_child(label)
	
	var t = create_tween().set_parallel(true)
	t.tween_property(label, "position:y", -50, 0.8)
	t.tween_property(label, "modulate:a", 0, 0.8)
	t.tween_callback(label.queue_free).set_delay(0.8)

func pulse_next_available() -> void:
	if is_maxed(): return
	var t = create_tween()
	t.tween_property($ColorRect, "modulate", Color(0, 1, 0.5, 0.8), 0.2)
	t.tween_property($ColorRect, "modulate", Color.WHITE, 0.2)
	t.tween_property($ColorRect, "modulate", Color(0, 1, 0.5, 0.8), 0.2)
	t.tween_property($ColorRect, "modulate", Color.WHITE, 0.2)
	t.tween_property($ColorRect, "modulate", Color(0, 1, 0.5, 0.8), 0.2)
	t.tween_property($ColorRect, "modulate", Color.WHITE, 0.2)


func is_maxed() -> bool:
	return get_current_level() + 1 > len(upgrade.app_costs) or get_current_level() + 1 > len(upgrade.exp_costs)

func can_buy_next_level() -> bool:
	if is_maxed(): return false
	
	if GlobalData.total_apps < upgrade.app_costs[get_current_level()]:
		return false
	if GlobalData.experience < upgrade.exp_costs[get_current_level()]:
		return false
	return true

func update_labels_and_button():
	name_label.text = upgrade.display_name + ("\nLevel %d" % (get_current_level() + 1) if not is_maxed() else "\nSOLD OUT")
	if is_maxed():
		if GlobalData.apps_changed.is_connected(update_label_colors): GlobalData.apps_changed.disconnect(update_label_colors)
		if GlobalData.exp_changed.is_connected(update_label_colors): GlobalData.exp_changed.disconnect(update_label_colors)
		self.disabled = true # these two lines are for the same purpose
		self.modulate.a = 0.5 # these two lines are for the same purpose
		max_label.text = "MAX"
		$HBoxContainer/CostSpritesContainer/AppSprite.visible = false
		$HBoxContainer/CostSpritesContainer/ExpSprite.visible = false
		app_cost_label.text = ""
		exp_cost_label.text = ""
		desc_label.text = upgrade.descriptions[len(upgrade.descriptions) - 1]
		return
	$HBoxContainer/CostSpritesContainer/AppSprite.visible = true
	$HBoxContainer/CostSpritesContainer/ExpSprite.visible = true
	max_label.text = ""
	self.disabled = false # these two lines are for the same purpose
	self.modulate.a = 1.0 # these two lines are for the same purpose
	desc_label.text = upgrade.descriptions[get_current_level()]
	app_cost_label.text = "%d" % upgrade.app_costs[get_current_level()]
	exp_cost_label.text = "%d" % upgrade.exp_costs[get_current_level()]

func setup(upgrade_info: UpgradeInfo) -> void:
	upgrade = upgrade_info
	visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.apps_changed.connect(update_label_colors)
	GlobalData.exp_changed.connect(update_label_colors)
	update_labels_and_button()
	update_label_colors()

func update_label_colors():
	if is_maxed(): return
	
	var affordable = GlobalData.total_apps >= upgrade.app_costs[get_current_level()] and GlobalData.experience >= upgrade.exp_costs[get_current_level()]
	
	if affordable and not was_affordable:
		pulse_next_available()
	was_affordable = affordable

	if GlobalData.total_apps < upgrade.app_costs[get_current_level()]:
		app_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
		modulate = Color.WHITE
	else:
		app_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))
	
	if GlobalData.experience < upgrade.exp_costs[get_current_level()]:
		exp_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
	else:
		exp_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))
	
	if GlobalData.total_apps >= upgrade.app_costs[get_current_level()] and GlobalData.experience >= upgrade.exp_costs[get_current_level()]:
		$ColorRect.visible = true
	else:
		$ColorRect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
