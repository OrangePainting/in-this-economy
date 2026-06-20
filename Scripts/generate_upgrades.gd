@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var gd = load("res://Scripts/Autoloads/global_data.gd").new()
	
	var directory = DirAccess.open("res://")
	if not directory.dir_exists("res://Upgrades"):
		directory.make_dir("res://Upgrades")
	
	for id in gd.tree.keys():
		var info = gd.tree[id]
		var upgrade = UpgradeInfo.new()
		upgrade.id = id
		upgrade.display_name = info["display_name"]
		upgrade.descriptions.assign(info["descriptions"])
		upgrade.exp_costs.assign(info["exp_costs"])
		upgrade.app_costs.assign(info["app_costs"])
		upgrade.effects.assign(info["effects"])
		#upgrade.icon = info["icon"]
		
		var path = "res://Upgrades/" + id.to_lower() + ".tres"
		ResourceSaver.save(upgrade, path)
		print("Saved: ", path)
	
	print("Done")
