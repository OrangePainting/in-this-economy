extends Node

var total_apps: int = 10
var experience: int = 10

var num_results: int = 8
var spin_time: float = 2.0 # reco don't put less than 0.5
var pass_chance: float = 0.05
var auto_apply_time: float = 2.0
var auto_apply_pass_chance: float = 0.01
var upgrades_bought: Dictionary[UpgradeInfo, int] # key = upgrade, value = highest level bought

var tree = {
		"Auto Apply": { 
			"exp_costs": [10, 20, 50], 
			"app_costs": [5, 50, 100], 
			"display_name": "Auto Apply", 
			"descriptions": ["Auto Apply to jobs using your information", "More specific information", "Upgrade Level 3"],
			"effects": {"auto_apply_pass_chance" : [0.05, 0.1, 0.2]}
		},
		
		"Web Scraper": { 
			"exp_costs": [1, 2, 3], 
			"app_costs": [1, 2, 3], 
			"display_name": "Web Scraper", 
			"descriptions": ["Find more jobs to Auto Apply to", "Upgrade Level 2", "Upgrade Level 3"],
			"effects": {"auto_apply_time" : [4, 3, 2]}
		},
		
		"Faster Spin": { 
			"exp_costs": [1, 2, 3], 
			"app_costs": [1, 2, 3], 
			"display_name": "Faster Spin", 
			"descriptions": ["Simply insert your information faster", "Upgrade Level 2", "Upgrade Level 3"],
			"effects": {"spin_time" : [1.5, 1.0, 0.5]}
		},
		
		"Improve Yourself": { 
			"exp_costs": [1, 2, 3], 
			"app_costs": [1, 2, 3], 
			"display_name": "Improve Yourself", 
			"descriptions": ["Make your information look better", "Upgrade Level 2", "Upgrade Level 3"],
			"effects": {"pass_chance" : [0.25, 0.5, 0.75]}
		},
		
	}

var result_locations: Array[Vector2] = [Vector2(256, 116),
										Vector2(176, 166),
										Vector2(72, 214),
										Vector2(148, 262),
										Vector2(200, 312),
										Vector2(120, 356),
										Vector2(278, 356),
										Vector2(80, 410)]
# Current Result Placements:
# - 256, 120
# - 176, 168
# - 72, 216
# - 144, 272
# - 200, 320
# - 120, 368
# - 288, 368
# - 80, 416

func can_buy(upgrade: UpgradeInfo, level: int) -> bool:
	if total_apps < upgrade.app_costs[level]: return false
	if experience < upgrade.exp_costs[level]: return false
	return true

func buy_upgrade(upgrade: UpgradeInfo, level: int) -> void:
	total_apps -= upgrade.app_costs[level]
	experience -= upgrade.exp_costs[level]
	upgrades_bought[upgrade] = level # level = highest level bought
	
	apply_upgrades() # reload all the upgrade effects to update with newly bought upgrade
	# it might be better to put this in _process(delta) but idk

func apply_upgrades() -> void:
	for upgrade in upgrades_bought:
		var highest_level_bought = upgrades_bought[upgrade]
		if not upgrade: continue
		for effect in upgrade.effects:
			apply_effect(effect, highest_level_bought)

func apply_effect(effect, level) -> void:
	print("Applied Effect: " + effect)
