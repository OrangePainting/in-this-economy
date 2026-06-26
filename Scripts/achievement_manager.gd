extends Node2D

const Achievement = preload("res://Scenes/acheivement_background.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.document_opened.connect(on_document_opened)

func on_document_opened(pass_num: int):
	if pass_num <= GlobalData.current_best: return
	create_achievement(pass_num)

func create_achievement(pass_num: int):
	var a = Achievement.preload()
	a.position = Vector2(0, 640)
	add_child(a)
	create_tween().tween_property(a, "position", Vector2(0, 500), 1.5)
	create_tween().tween_property(a, "modulate", Color(0,0,0,0), 1.5)
	a.set_text()
	remove_child(a)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
