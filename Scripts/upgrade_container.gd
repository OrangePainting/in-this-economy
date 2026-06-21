extends VBoxContainer

const Upgrade = preload("res://Scenes/upgrade_template.tscn")
var upgrade_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()

func setup() -> void:
	var directory = DirAccess.open("res://Upgrades")
	var upgrade_resources = []
	for resource_name in directory.get_files():
		var r = load("res://Upgrades/" + resource_name)
		upgrade_resources.append(r)
		create_upgrade(r)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_upgrade(upgrade_info: UpgradeInfo):
	var u = Upgrade.instantiate()
	u.setup(upgrade_info)
	add_child(u)
	upgrade_nodes.append(u)
