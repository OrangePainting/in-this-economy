extends Node

# Make the game load faster
# [FIXED] Problem with virtual keyboard
# mobile keyboard problems
# cant scroll upgrade

# B:
# oh also the font for the upgrades and alot of things look a bit weird. Ik you want a pixelated look but maybe find a different font that looks better.
#- [FIXED] the applications feel like they take forever to get any upgrades, so maybe having smaller incremental upgrades would be better
# ----
#I'm not done with the game yet but here's a couple of things I noticed:
#- music is really good
#- text in the intro is a bit hard to read, might be the drop shadow or something 
#- - Abt the applications one, I've gotten so many more exp than applications so the limiting factor for getting the upgrades is still applications
#- for the grid game you can move many times in one cycle like I managed 4 in one direction, idk if this is intended

# AA
# [Kinda Fixed] When it says test industry I can't remove the word text

# AN
# [FIXED] Quit button not working
# - Fix, replace to credits prolly
# fail/pass sfx is quieter than rest of them
# forgot to add cost to projects, will probably remove them
# story part: most of the time you can't get the fail results in real life
# currently mainly grinding for applications, not exp
# - fix: make the projects give you applications too?? How would make this work thematically??
# Put finished upgrades at the end of the list (put viable upgrades at the beginning too?)
# Need to make this better for ppl who have hand problems
# feedback from the project completion needs to exist
# Still work with the upgrades
# - At the beginning the game focuses on applications, then later it goes into exp
# background is kinda weird, cuz top down view with side perspective
# time for grid game goes into the negatives
# labels for top left ui need applications and experience
# for ui in top left, add some sort of progress bar to make the auto apply stuff be visible (same for expereince)
# add more music lol (probably also add a button in the credits)
# various paper sound effects
# add scrolling in the bottom corner about various things

signal currency_changed

var finished_game: bool = false

var industry_name: String = "test"

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
			"app_costs": [5, 12, 25, 50, 75], 
			"display_name": "Faster Replies", 
			"descriptions": ["Learn how to open envelopes faster", "Use a better postal service", "Message HR Managers until they reply out of fear", "Hire someone to get your mail for you", "Simply distort time"],
			"effects": {"spin_time" : [3, 2.25, 1.75, 1.25, 0.5]}
		},
		
		"2. Improve Yourself": { 
			"exp_costs": [0, 5, 20, 75, 250], 
			"app_costs": [8, 13, 50, 150, 250], 
			"display_name": "Better Pass Chance", 
			"descriptions": ["Download a better resume template", "Build a website showcasing your skills", "Bypass the ATS section by hiding keywords in white text", "Pay a professional to write your application using corporate buzzwords", "Exaggerate your Powerpoint skills on your resume"],
		},
		
		"3. Unlock Projects": { 
			"exp_costs": [0, 40, 100], 
			"app_costs": [5, 13, 25], 
			"display_name": "Create Projects", 
			"descriptions": ["Unlock the projects tab and complete them for EXP", "Unlock another project type", "Unlock yet another project type"],
			"effects": {"projects_unlocked" : [1, 2, 3]}
		},
		
		"4. More Apps Per Spin": { 
			"exp_costs": [50, 100, 250, 500], 
			"app_costs": [25, 80, 200, 450], 
			"display_name": "Multiple Applications", 
			"descriptions": ["Your application legally satisfies 2 different positions", "Your application legally satisfies 3 different positions", "Somehow, your application legally satisfies 5 different positions", "Submit your application to multiple parallel universes"],
			"effects": {"apps_per_spin" : [2, 3, 5, 10]}
		},
		
		"5. Passive EXP": { 
			"exp_costs": [20, 50, 200], 
			"app_costs": [13, 50, 125], 
			"display_name": "Passive experience",
			"descriptions": ["Complete more certifications for experience", "Network into startups to maximize exp efficiency", "Clone yourself to do two things at once"],
			"effects": {"passive_exp_rate" : [1, 10, 20]}
		},
		
		"6. Referral": { 
			"exp_costs": [250, 450, 850, 900], 
			"app_costs": [75, 125, 275, 350], 
			"display_name": "\"I know a guy\"",
			"descriptions": ["Get a referral so you guarantee a pass", "Get more referral to guarantee 2 passes", "Get even more referrals to guarantee 3 passes", "Know everyone at the company and guarantee 4 passes"],
			"effects": {"guaranteed_passes" : [1, 2, 3, 4]}
		},
		
		"7. Auto Apply": { 
			"exp_costs": [50, 200, 400, 800, 1000], 
			"app_costs": [13, 50, 100, 250, 375], 
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
	industry_name = "test"
