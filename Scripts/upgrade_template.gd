extends Control

var next_upgrade_level = 1

@onready var name_label = $HBoxContainer/InfoContainer/NameLabel
@onready var desc_label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var app_cost_label = $HBoxContainer/CostLabelContainer/AppCostLabel
@onready var exp_cost_label = $HBoxContainer/CostLabelContainer/ExpCostLabel

var upgrade

func next_level() -> void:
	next_upgrade_level += 1

func setup(upgrade_info: UpgradeInfo) -> void:
	upgrade = upgrade_info

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name_label.text = upgrade.display_name
	desc_label.text = upgrade.descriptions[next_upgrade_level - 1]
	app_cost_label.text = "%d" % upgrade.app_costs[next_upgrade_level - 1]
	exp_cost_label.text = "%d" % upgrade.exp_costs[next_upgrade_level - 1]


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
