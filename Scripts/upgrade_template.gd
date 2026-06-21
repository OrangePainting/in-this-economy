extends Control

var next_upgrade_level = 1

@onready var name_label = $HBoxContainer/InfoContainer/NameLabel
@onready var desc_label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var app_cost_label = $HBoxContainer/CostLabelContainer/AppCostLabel
@onready var exp_cost_label = $HBoxContainer/CostLabelContainer/ExpCostLabel
@onready var max_label = $HBoxContainer/CostLabelContainer/MaxLabel

var upgrade

func next_level() -> void:
	var t = create_tween()
	if GlobalData.can_buy(upgrade, next_upgrade_level - 1):
		GlobalData.buy_upgrade(upgrade, next_upgrade_level - 1)
		next_upgrade_level += 1
		update_labels_and_button()
		t.tween_property(self, "modulate", Color.YELLOW_GREEN, 0.1)
		t.tween_property(self, "modulate", Color.WHITE, 0.1)
	else:
		t.tween_property(self, "modulate", Color.RED, 0.1)
		t.tween_property(self, "modulate", Color.WHITE, 0.3)

func can_buy_next_level() -> bool:
	if GlobalData.total_apps < upgrade.app_costs[next_upgrade_level - 1]:
		return false
	if GlobalData.experience < upgrade.exp_costs[next_upgrade_level - 1]:
		return false
	return true

func update_labels_and_button():
	name_label.text = upgrade.display_name
	desc_label.text = upgrade.descriptions[next_upgrade_level - 1]
	app_cost_label.text = "%d" % upgrade.app_costs[next_upgrade_level - 1]
	exp_cost_label.text = "%d" % upgrade.exp_costs[next_upgrade_level - 1]
	
	if next_upgrade_level > len(upgrade.app_costs) or next_upgrade_level > len(upgrade.exp_costs):
		self.disabled = true
		max_label.text = "MAX"
	else:
		self.disabled = false
		max_label.text = ""

func setup(upgrade_info: UpgradeInfo) -> void:
	upgrade = upgrade_info

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels_and_button()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GlobalData.total_apps < upgrade.app_costs[next_upgrade_level - 1]:
		app_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
	else:
		app_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))
	
	if GlobalData.experience < upgrade.exp_costs[next_upgrade_level - 1]:
		exp_cost_label.set_modulate(Color(1.0, 0.2, 0.2, 1.0))
	else:
		exp_cost_label.set_modulate(Color(0.2, 1.0, 0.2, 1.0))
