extends Node

signal currency_changed

var finished_game: bool = false

var total_apps: int = 10000
var experience: int = 10000

var upgrades_bought: Dictionary[UpgradeInfo, int] # key = upgrade, value = highest level bought


const BASE_STATS = {"spin_time": 2.0, # reco don't put less than 0.5
					"pass_chance": 0.05,
					"auto_apply_time": 5.0,
					"auto_apply_pass_chance": 0.01}

var stats = BASE_STATS.duplicate()

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

var num_results: int = 8
var result_locations: Array[Vector2] = [Vector2(484, 116),
										Vector2(404, 166),
										Vector2(300, 214),
										Vector2(376, 262),
										Vector2(428, 312),
										Vector2(348, 356),
										Vector2(500, 356),
										Vector2(308, 410)]
# Current Result Placements:
# - 484, 116
# - 404, 166
# - 300, 214
# - 376, 262
# - 428, 312
# - 348, 356
# - 500, 356
# - 308, 410

func can_buy(upgrade: UpgradeInfo, level: int) -> bool:
	if total_apps < upgrade.app_costs[level]: return false
	if experience < upgrade.exp_costs[level]: return false
	return true

func buy_upgrade(upgrade: UpgradeInfo, level: int) -> void:
	total_apps -= upgrade.app_costs[level]
	experience -= upgrade.exp_costs[level]
	upgrades_bought[upgrade] = level + 1 # level + 1 = highest level bought
	apply_upgrade(upgrade) # reload all the upgrade effects to update with newly bought upgrade
	stats = BASE_STATS.duplicate()
	apply_upgrades()
	currency_changed.emit()
	AudioController.play_buy()

func apply_upgrades() -> void:
	for upgrade in upgrades_bought: apply_upgrade(upgrade)

func apply_upgrade(upgrade: UpgradeInfo) -> void:
	if not upgrade: return
	var highest_level_bought = upgrades_bought[upgrade]
	apply_effect(upgrade, highest_level_bought)

func apply_effect(upgrade: UpgradeInfo, level: int) -> void:
	for effect in upgrade.effects:
		stats[effect] = upgrade.effects[effect][level - 1] # 0 indexed, but the level is 1 indexed, so subtract 1
		# add more upgrades here when necessary
		#print("applied effect: " + effect)
		#print(upgrade.effects[effect][level])

func reset_game() -> void:
	stats = GlobalData.BASE_STATS.duplicate()
	upgrades_bought.clear()
	experience = 10000 # CHANGE THIS TO SOMETHING ELSE WHEN FINALLY DONE WITH THE GAME
	total_apps = 10000
	finished_game = false
