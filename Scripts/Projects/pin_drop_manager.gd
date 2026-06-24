extends Control

signal project_completed

const NUM_SEGMENTS = 30
const RADIUS = 300.0
const CENTER = Vector2.ONE * (RADIUS + 20)
const START_TIME = 30.0
const SPIN_SPEED = 55.0 # degrees per second

const TYPE_NORMAL = 0
const TYPE_TARGET = 1
const TYPE_DANGER = 2

const HIT_COLOR = Color(0.18, 0.62, 0.28)

var wheel_angle: float = 0.0
var total_time: float = 0.0
var last_display: float = -1.0
var done: bool = false
var flashing: bool = false
var flash_color: Color = Color.WHITE

var segments: Array[int] = []
var hit_marks: Array[bool] = []
var targets_needed: int = 0
var targets_hit: int = 0

@onready var time_label = %TimeLabel
@onready var progress_label = %ProgressLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%InfoLabel.position = Vector2.RIGHT * RADIUS * 2.2
	%ActionButton.position = %InfoLabel.position  + Vector2.DOWN * (%InfoLabel.size.y + 20)
	%ProgressLabel.position = Vector2.DOWN * RADIUS * 2
	%TimeLabel.position = %ProgressLabel.position + Vector2.DOWN * 20
	
	segments.resize(NUM_SEGMENTS)
	hit_marks.resize(NUM_SEGMENTS)
	
	var target_count = int(NUM_SEGMENTS * 0.3)
	var danger_count = int(NUM_SEGMENTS * 0.7)

	var types = []
	for i in target_count: types.append(TYPE_TARGET)
	for i in danger_count: types.append(TYPE_DANGER)
	
	while types.size() < NUM_SEGMENTS: types.append(TYPE_NORMAL)
	types.shuffle()
	
	for i in NUM_SEGMENTS:
		segments[i] = types[i]
		hit_marks[i] = false
		if types[i] == TYPE_TARGET: targets_needed += 1
	
	update_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if done: return
	total_time += delta
	wheel_angle = fmod(wheel_angle + SPIN_SPEED * delta, 360.0)
	queue_redraw()
	var left = START_TIME - total_time
	var display = snappedf(left, 0.01)
	if display != last_display:
		last_display = display
		time_label.text = "Time: %.2f" % maxf(display, 0.0)
	
	if left <= 0.0: done = true

func _draw() -> void:
	draw_circle(CENTER, RADIUS + 22.0, Color(0.08, 0.08, 0.12))
	var segment_degrees = 360.0 / NUM_SEGMENTS
	
	for i in NUM_SEGMENTS:
		var start_angle = deg_to_rad(wheel_angle + i * segment_degrees)
		var end_angle = deg_to_rad(wheel_angle + (i + 1) * segment_degrees)
		
		var color = HIT_COLOR if segments[i] == TYPE_TARGET and hit_marks[i] else Color.DARK_GRAY
		
		var points = PackedVector2Array() # Packs data tightly, so it saves memory for large array sizes.
		points.append(CENTER)
		for s in range(13):
			var a = lerp(start_angle, end_angle, float(s) / 12.0) # middle points
			points.append(CENTER + Vector2(cos(a), sin(a)) * RADIUS)
		
		draw_colored_polygon(points, color)
		
		draw_line(CENTER, CENTER + Vector2(cos(start_angle), sin(start_angle)) * RADIUS, Color(0.04, 0.04, 0.08), 2.0)
		
		var middle_angle = deg_to_rad(wheel_angle + (i + 0.5) * segment_degrees)
		var icon_position = CENTER + Vector2(cos(middle_angle), sin(middle_angle)) * RADIUS * 0.62
		if segments[i] == TYPE_TARGET:
			if hit_marks[i]:
				draw_circle(icon_position, 9.0, Color.WHITE)
				draw_circle(icon_position, 6.0, Color.LIME_GREEN)
			else:
				draw_circle(icon_position, 8.0, Color.GOLD)
				draw_circle(icon_position, 5.0, Color.DARK_GOLDENROD)
		
		elif segments[i] == TYPE_DANGER:
			draw_line(icon_position + Vector2(-6, -6), icon_position + Vector2(6, 6), Color.LIGHT_PINK, 2.5) # cross symbol
			draw_line(icon_position + Vector2(6, -6), icon_position + Vector2(-6, 6), Color.LIGHT_PINK, 2.5)
		
	draw_arc(CENTER, RADIUS, 0, TAU, 64, Color.SILVER, 3.0)
	
	draw_line(CENTER + Vector2(RADIUS - 8.0, 0.0), CENTER + Vector2(RADIUS + 20.0, 0.0), Color(1, 1, 1, 0.25), 1.5)
	var pointer = CENTER + Vector2(RADIUS + 20.0, 0.0)
	var pointer_color = flash_color if flashing else Color.WHITE
	draw_circle(pointer, 10.0, pointer_color)
	draw_circle(pointer, 6.0, Color(0.08, 0.08, 0.14))

func _on_action_button_pressed() -> void:
	if done: return
	var index = segment_at_pointer()
	match segments[index]:
		TYPE_TARGET:
			if not hit_marks[index]:
				hit_marks[index] = true
				targets_hit += 1 # yay
				update_labels()
				flash(Color.LAWN_GREEN)
				if targets_hit >= targets_needed:
					done = true
					project_completed.emit()
		TYPE_DANGER:
			for i in NUM_SEGMENTS: hit_marks[i] = false
			targets_hit = 0
			update_labels()
			flash(Color.RED)
		TYPE_NORMAL:
			flash(Color.WEB_GRAY)

func segment_at_pointer() -> int:
	var segment_degrees = 360.0 / NUM_SEGMENTS
	var local_angle = fmod(360.0 - wheel_angle, 360.0)
	return int(local_angle / segment_degrees) % NUM_SEGMENTS

func update_labels() -> void:
	progress_label.text = "Stars: %d / %d" % [targets_hit, targets_needed]

func flash(color: Color) -> void:
	flashing = true
	flash_color = color
	await get_tree().create_timer(0.25).timeout
	flashing = false
