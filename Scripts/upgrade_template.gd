extends Control

signal upgrade_is_maxed(name)

@onready var name_label = $HBoxContainer/InfoContainer/NameLabel
@onready var desc_label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var app_cost_label = $HBoxContainer/CostLabelContainer/AppCostLabel
@onready var exp_cost_label = $HBoxContainer/CostLabelContainer/ExpCostLabel
@onready var max_label = $HBoxContainer/CostLabelContainer/MaxLabel

var upgrade
var tween: Tween

func get_current_level() -> int:
	return GlobalData.upgrades_bought.get(upgrade, 0)

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
		if is_maxed(): upgrade_is_maxed.emit(upgrade.display_name)
	else:
		tween.tween_property(self, "modulate", Color.RED, 0.1)
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)

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
	name_label.text = upgrade.display_name
	if is_maxed():
		if GlobalData.currency_changed.is_connected(update_label_colors): GlobalData.currency_changed.disconnect(update_label_colors)
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
	GlobalData.currency_changed.connect(update_label_colors)
	update_labels_and_button()
	update_label_colors()

func update_label_colors():
	if is_maxed(): return

	if GlobalData.total_apps < upgrade.app_costs[get_current_level()]:
		app_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
	else:
		app_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))
	
	if GlobalData.experience < upgrade.exp_costs[get_current_level()]:
		exp_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
	else:
		exp_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
