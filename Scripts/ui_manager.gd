extends Node2D


@onready var app_num_label = $CanvasLayer/AppsLabel
@onready var exp_label = $CanvasLayer/ExpLabel
@onready var auto_apps_overlay = $CanvasLayer/AutoAppsOverlay
@onready var auto_exp_overlay = $CanvasLayer/AutoExpOverlay

var app_overlay_tween: Tween
var exp_overlay_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalData.apps_changed.connect(update_label_text)
	GlobalData.exp_changed.connect(update_label_text)
	GlobalData.upgrade_purchased.connect(update_app_overlay_visibility)
	GlobalData.upgrade_purchased.connect(update_exp_overlay_visibility)
	GlobalData.passive_exp_ticked.connect(start_exp_overlay_shrink)
	update_label_text()
	update_app_overlay_visibility()
	update_exp_overlay_visibility()

func update_exp_overlay_visibility() -> void:
	var has_upgrade = GlobalData.has_upgrade("5. Passive EXP")
	
	if has_upgrade and not auto_exp_overlay.visible:
		auto_exp_overlay.visible = true
		start_exp_overlay_shrink()
	elif not has_upgrade:
		auto_exp_overlay.visible = false
		if exp_overlay_tween: exp_overlay_tween.kill()

func start_exp_overlay_shrink() -> void:
	if not auto_exp_overlay.visible: return
	if exp_overlay_tween: exp_overlay_tween.kill()
	auto_exp_overlay.scale.x = 1.0
	exp_overlay_tween = auto_exp_overlay.create_tween()
	exp_overlay_tween.tween_property(auto_exp_overlay, "scale:x", 0.0, GlobalData.PASSIVE_EXP_INTERVAL)

func update_app_overlay_visibility() -> void:
	var has_upgrade = GlobalData.has_upgrade("7. Auto Apply")
	
	if has_upgrade and not auto_apps_overlay.visible:
		auto_apps_overlay.visible = true
		start_overlay_shrink()
	elif not has_upgrade:
		auto_apps_overlay.visible = false
		if app_overlay_tween: app_overlay_tween.kill()

func start_overlay_shrink() -> void:
	if app_overlay_tween: app_overlay_tween.kill()
	auto_apps_overlay.scale.x = 1.0
	app_overlay_tween = auto_apps_overlay.create_tween()
	app_overlay_tween.tween_property(auto_apps_overlay, "scale:x", 0.0, GlobalData.stats["auto_apply_time"])

func update_label_text() -> void:
	app_num_label.text = "%d" % GlobalData.total_apps
	exp_label.text = "%d" % GlobalData.experience

func _on_auto_apply_complete() -> void:
	var app_tween = app_num_label.create_tween()
	var exp_tween = exp_label.create_tween()
	app_tween.tween_property(app_num_label, "modulate", Color(0.5, 0.8, 1.0), 0.15)
	exp_tween.tween_property(exp_label, "modulate", Color(0.5, 0.8, 1.0), 0.15)
	app_tween.tween_property(app_num_label, "modulate", Color.WHITE, 0.15)
	exp_tween.tween_property(exp_label, "modulate", Color.WHITE, 0.15)
	
	start_overlay_shrink()
