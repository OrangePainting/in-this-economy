extends Node

signal currency_changed

var finished_game: bool = false

var total_time: float = 0

var total_apps: int = 0
var experience: int = 0

var upgrades_bought: Dictionary[UpgradeInfo, int] # key = upgrade, value = highest level bought
var num_upgrades_bought = 0

const BASE_STATS = {"spin_time": 4.0, # reco don't put less than 0.5
					"pass_chance": 0.05,
					"projects_unlocked": 0,
					"apps_per_spin": 1,
					"auto_apply_time": 15.0,
					"guaranteed_passes": 0,
					"passive_exp_rate": 0}

var stats = BASE_STATS.duplicate()

var tree = {
		"1. Faster Spin": { 
			"exp_costs": [0, 0, 10, 50, 200], 
			"app_costs": [10, 25, 50, 100, 150], 
			"display_name": "Faster Replies", 
			"descriptions": ["Learn how to open envelopes faster", "Use a better postal service", "Message HR Managers until they reply out of fear", "Hire someone to get your mail for you", "Simply distort time"],
			"effects": {"spin_time" : [3, 2.25, 1.75, 1.25, 0.5]}
		},
		
		"2. Improve Yourself": { 
			"exp_costs": [0, 5, 20, 75, 250], 
			"app_costs": [15, 25, 100, 300, 500], 
			"display_name": "Better Pass Chance", 
			"descriptions": ["Download a better resume template", "Build a website showcasing your skills", "Bypass the ATS section by hiding keywords in white text", "Pay a professional to write your application using corporate buzzwords", "Exaggerate your Powerpoint skills on your resume"],
			"effects": {"pass_chance" : [0.05, 0.15, 0.25, 0.3, 0.35]}
		},
		
		"3. Unlock Projects": { 
			"exp_costs": [0, 40, 100], 
			"app_costs": [10, 25, 50], 
			"display_name": "Create Projects", 
			"descriptions": ["Unlock the projects tab and complete them for EXP", "Unlock another project type", "Unlock yet another project type"],
			"effects": {"projects_unlocked" : [1, 2, 3]}
		},
		
		"4. More Apps Per Spin": { 
			"exp_costs": [50, 100, 250, 500], 
			"app_costs": [100, 200, 500, 1000], 
			"display_name": "Multiple Applications", 
			"descriptions": ["Your application legally satisfies 2 different positions", "Your application legally satisfies 3 different positions", "Somehow, your application legally satisfies 5 different positions", "Submit your application to multiple parallel universes"],
			"effects": {"apps_per_spin" : [2, 3, 5, 10]}
		},
		
		"5. Passive EXP": { 
			"exp_costs": [20, 50, 200], 
			"app_costs": [25, 100, 250], 
			"display_name": "Passive experience",
			"descriptions": ["Complete more certifications for experience", "Network into startups to maximize exp efficiency", "Clone yourself to do two things at once"],
			"effects": {"passive_exp_rate" : [1, 10, 20]}
		},
		
		"6. Referral": { 
			"exp_costs": [250, 450, 850, 900], 
			"app_costs": [150, 250, 550, 700], 
			"display_name": "\"I know a guy\"",
			"descriptions": ["Get a referral so you guarantee a pass", "Get more referral to guarantee 2 passes", "Get even more referrals to guarantee 3 passes", "Know everyone at the company and guarantee 4 passes"],
			"effects": {"guaranteed_passes" : [1, 2, 3, 4]}
		},
		
		"7. Auto Apply": { 
			"exp_costs": [50, 200, 400, 800, 1000], 
			"app_costs": [25, 100, 200, 500, 750], 
			"display_name": "Auto Apply", 
			"descriptions": ["Automatically apply to online jobs", "Use more accounts to auto apply faster", "Automatically reply to do_not_reply@email.com", "Auto approve all background checks", "Apply to ghost jobs that don't exist yet"],
			"effects": {"auto_apply_time" : [10, 5, 3.75, 3, 2]}
		},
		
	}

var num_results: int = 8
var result_locations: Array[Vector2] = [Vector2(212.0, 92.0),
										Vector2(132.0, 142.0),
										Vector2(28.0, 190.0),
										Vector2(104.0, 238.0),
										Vector2(156.0, 288.0),
										Vector2(76.0, 332.0),
										Vector2(228.0, 332.0),
										Vector2(36.0, 386.0)]

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
	num_upgrades_bought += 1
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
	num_upgrades_bought = 0
	upgrades_bought.clear()
	experience = 0 # CHANGE THIS TO SOMETHING ELSE WHEN FINALLY DONE WITH THE GAME
	total_apps = 0 # CHANGE THIS TO SOMETHING ELSE WHEN FINALLY DONE WITH THE GAME
	finished_game = false
	total_time = 0


# The Goal: Make something to go into the projects tab to gain experience
# Idea: Projects are small games that the player has to focus their attention on to complete
# Each Project has a timer for a set number of seconds to complete
# - These projects are small minigames all with the theme of "spin to win"

# - Project Idea: Player has to press a button to get through a set of arcs to a center position, where touching the arcs reset you
# - There are n concentric circle arcs, and a goal at the center of all of them
# - The arcs follow the path of the circles, so they loop around forever 
# - You time the button press to go to the next closest circle
# - There is some UI for the goal, character, button, timer, and arcs, somewhat similar to the grid game project

# Think of 2 other project ideas
