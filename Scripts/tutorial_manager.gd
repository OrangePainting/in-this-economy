class_name TutorialManager
extends CanvasLayer

@onready var dim: ColorRect = $Dim
@onready var box: Panel = $Box
@onready var tip_background: ColorRect = $TipBackground
@onready var tip: Label = $Tip
@onready var arrow: Label = $Arrow
@onready var skip_button: Button = $SkipButton

var step: int = 0
var pulse_tween: Tween
var spin_button: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skip_button.pressed.connect(finish)

func start() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	do_step(0)

func do_step(s: int) -> void:
	step = s
	if pulse_tween: pulse_tween.kill()
	match step:
		0: step_apply()
		1: step_upgrades_tab()
		2: step_first_upgrade()
		_: finish()

func fade_in() -> void:
	create_tween().tween_property(dim, "color", Color(0, 0, 0, 0.65), 0.3)

func fade_out() -> void:
	create_tween().tween_property(dim, "color", Color(0, 0, 0, 0), 0.25)

func point_at(rect: Rect2, text: String, above: bool = true) -> void:
	var pad = 10
	box.position = rect.position - Vector2.ONE * pad
	box.size = rect.size + Vector2.ONE * pad * 2
	box.visible = true
	tip.text = text
	arrow.text = "v" if above else "^"
	tip.visible = true
	arrow.visible = true

	await get_tree().process_frame
	await get_tree().process_frame
	
	var center_x = rect.position.x + rect.size.x * 0.5
	var arrow_x = clamp(center_x - arrow.size.x * 0.5, 4.0, 1276.0)
	var tip_x = clamp(center_x - tip.size.x * 0.5, 4.0, 1276.0 - tip.size.x)
	var arrow_y: float
	var tip_y: float
	if above:
		arrow_y = rect.position.y - 52
		tip_y = arrow_y - tip.size.y - 6
	else:
		arrow_y = rect.position.y + rect.size.y + 8
		tip_y = arrow_y + 46
	
	arrow.position = Vector2(arrow_x, arrow_y)
	tip.position = Vector2(tip_x, tip_y)
	tip_background.position = Vector2(tip_x - 8, tip_y - 6)
	tip_background.size = tip.size + Vector2(16, 12)
	tip_background.visible = true
	
	if pulse_tween: pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(arrow, "position:y", arrow_y + 10, 0.45).set_trans(Tween.TRANS_SINE)
	pulse_tween.tween_property(arrow, "position:y", arrow_y, 0.45).set_trans(Tween.TRANS_SINE)

func clear() -> void:
	if pulse_tween: pulse_tween.kill()
	box.visible = false
	tip.visible = false
	tip_background.visible = false
	arrow.visible = false

func step_apply() -> void:
	fade_in()
	await get_tree().create_timer(0.4).timeout
	await point_at(spin_button.get_global_rect(), "Press APPLY to submit an application.", true)
	await spin_button.pressed
	clear()
	fade_out()
	await get_tree().create_timer(0.4).timeout
	do_step(1)

func step_upgrades_tab() -> void:
	var tab_container = get_tab_container()
	if not tab_container:
		finish()
		return
	fade_in()
	await get_tree().create_timer(0.4).timeout
	var tab_local = Rect2(117, 5, 85, 15)
	var tab_rect = Rect2(tab_container.get_global_position() + tab_local.position, tab_local.size)
	await point_at(tab_rect, "Open the Upgrades tab", false)
	tab_container.tab_changed.connect(on_tab)

func on_tab(index: int) -> void:
	if index != 0: return
	var tab_container = get_tab_container()
	if tab_container and tab_container.tab_changed.is_connected(on_tab):
		tab_container.tab_changed.disconnect(on_tab)
	clear()
	fade_out()
	get_tree().create_timer(0.4).timeout.connect(func(): do_step(2))

func step_first_upgrade() -> void:
	var upgrade_container = get_upgrade_container()
	if not upgrade_container: return
	var first = first_visible(upgrade_container)
	if not first:
		tip.text = "Click the envelope\nto open an application!"
		tip.visible = true
		await get_tree().process_frame
		tip.position = Vector2(790, 300)
		tip_background.position = Vector2(tip.position.x - 8, tip.position.y - 6)
		await get_tree().process_frame
		tip_background.size = tip.size + Vector2(16, 12)
		tip_background.visible = true
		GlobalData.currency_changed.connect(poll_upgrade)
		return
	#if GlobalData.currency_changed.is_connected(poll_upgrade):
		#GlobalData.currency_changed.disconnect(poll_upgrade)
	#tip.visible = false
	#tip_background.visible = false
	highlight_upgrade(first)

func poll_upgrade() -> void:
	var upgrade_container = get_upgrade_container()
	if not upgrade_container: return
	var first = first_visible(upgrade_container)
	if not first: return
	if GlobalData.currency_changed.is_connected(poll_upgrade):
		GlobalData.currency_changed.disconnect(poll_upgrade)
	tip.visible = false
	tip_background.visible = false
	highlight_upgrade(first)

func highlight_upgrade(node: Control) -> void:
	fade_in()
	await get_tree().create_timer(0.4).timeout
	await point_at(node.get_global_rect(), "Click to buy this upgrade :O", false)
	if not GlobalData.currency_changed.is_connected(on_bought):
		GlobalData.currency_changed.connect(on_bought)

func on_bought() -> void:
	if GlobalData.num_upgrades_bought <= 0: return
	if GlobalData.currency_changed.is_connected(on_bought):
		GlobalData.currency_changed.disconnect(on_bought)
	clear()
	fade_out()
	get_tree().create_timer(0.5).timeout.connect(func(): finish())

func cleanup() -> void:
	var tab_container = get_tab_container()
	if tab_container and tab_container.tab_changed.is_connected(on_tab): tab_container.tab_changed.disconnect(on_tab)
	if GlobalData.currency_changed.is_connected(poll_upgrade): GlobalData.currency_changed.disconnect(poll_upgrade)
	if GlobalData.currency_changed.is_connected(on_bought): GlobalData.currency_changed.disconnect(on_bought)
	

func finish() -> void:
	cleanup()
	clear()
	fade_out()
	GlobalData.tutorial_done = true
	await get_tree().create_timer(0.4).timeout
	queue_free()

func get_tab_container() -> TabContainer:
	return get_tree().root.find_child("TabContainer", true, false) as TabContainer

func get_upgrade_container() -> VBoxContainer:
	return get_tree().root.find_child("UpgradeContainer", true, false) as VBoxContainer

func first_visible(container: Node) -> Control:
	for child in container.get_children():
		if child is Control and (child as Control).visible: return child as Control
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
