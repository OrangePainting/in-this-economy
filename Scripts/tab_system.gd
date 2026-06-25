extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TabContainer.set_tab_hidden(1, true)
	%TabContainer.current_tab = 2
	GlobalData.currency_changed.connect(check_unlock_projects)

func check_unlock_projects() -> void:
	for upgrade in GlobalData.upgrades_bought:
		if upgrade.id == "3. Unlock Projects": 
			%TabContainer.set_tab_hidden(1, false)
			if GlobalData.upgrades_bought[upgrade] == 3:
				$TabContainer/Projects/InfoLabel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
