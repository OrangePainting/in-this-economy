extends Node

var total_apps: int = 0
var experience: int = 0

var num_results: int = 8
var spin_time: float = 2.0 # reco don't put less than 0.5
var pass_chance: float = 0.05
var auto_apply_time: float = 2.0
var auto_apply_pass_chance: float = 0.01

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

var result_locations: Array[Vector2] = [Vector2(320, 172),
										Vector2(256, 236),
										Vector2(88, 292),
										Vector2(216, 356),
										Vector2(272, 412),
										Vector2(152, 476),
										Vector2(344, 476),
										Vector2(152, 540)]
# Current Result Placements:
# - 320, 184
# - 256, 248
# - 88, 304
# - 216, 368
# - 272, 424
# - 152, 488
# - 344, 488
# - 152, 552
