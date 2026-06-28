extends Node2D

const Achievement = preload("res://Scenes/acheivement_background.tscn")

var achievement_text = [
	"The Start of A Looong Journey...",
	"You're Going Places (:",
	"Future Job Haver Over Here :V",
	"Omg Just 5 More Passes! :3",
	"Halfway There You Got This :P",
	"Your Better Than Average Yay :)",
	"C'mon Just A Little More :O",
	"Insert Ragebait Here >:)",
	"Peak :D"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.document_opened.connect(on_document_opened)

func on_document_opened(pass_num: int):
	if pass_num <= GlobalData.current_best: return
	GlobalData.current_best = pass_num 
	create_achievement(pass_num)

func create_achievement(pass_num: int):
	var a = Achievement.instantiate()
	a.position = Vector2(0, 720)
	add_child(a)
	var t = create_tween()
	t.tween_property(a, "position", Vector2(0, 720 - a.size.y * a.scale.y), 2)
	t.tween_property(a, "modulate", Color(0,0,0,0), 10)
	t.tween_callback(a.queue_free)
	a.set_text(pass_num, achievement_text[pass_num])
