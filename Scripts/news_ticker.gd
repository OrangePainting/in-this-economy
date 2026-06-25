extends Control

var headlines: Array[String] = [
	"test1",
	"test2",
	"test3",
	"test4",
	"test5"
]

@onready var label = $NewsLabel
var scroll_speed: float = 120.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	await get_tree().process_frame
	scroll_next()

func scroll_next() -> void:
	if headlines.is_empty(): return
	label.text = "  :)  " + headlines[randi_range(0, len(headlines) - 1)] + "  "
	await get_tree().process_frame
	label.position.x = size.x
	var t = create_tween()
	t.tween_property(label, "position:x", - label.size.x, (size.x + label.size.x) / scroll_speed)
	t.tween_callback(scroll_next)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
