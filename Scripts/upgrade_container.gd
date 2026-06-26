extends VBoxContainer

const Upgrade = preload("res://Scenes/upgrade_template.tscn")
var upgrade_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	GlobalData.currency_changed.connect(refresh_visibility)

func setup() -> void:
	var directory = DirAccess.open("res://Upgrades")
	var upgrade_resources = []
	for resource_name in directory.get_files():
		var load_name = resource_name
		if resource_name.ends_with(".remap"):
			load_name = resource_name.get_basename()
		var r = load("res://Upgrades/" + load_name)
		upgrade_resources.append(r)
		create_upgrade(r)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_visibility() -> void:
	for node in upgrade_nodes:
		var info = node.upgrade
		if info == null: continue
		if GlobalData.total_apps >= info.app_costs[0] / 1.5 or GlobalData.experience  >= info.exp_costs[0] / 1.5: node.visible = true

func create_upgrade(upgrade_info: UpgradeInfo):
	var u = Upgrade.instantiate()
	u.setup(upgrade_info)
	add_child(u)
	u.upgrade_is_maxed.connect(move_to_bottom)
	upgrade_nodes.append(u)

func move_to_bottom(upgrade_name: String) -> void:
	for u in upgrade_nodes:
		if u.upgrade.display_name == upgrade_name: move_child(u, -1)
