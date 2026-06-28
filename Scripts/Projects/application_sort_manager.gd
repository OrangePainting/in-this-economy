extends Control

signal project_completed

const NUM_SEGMENTS = 12
const PASS_COUNT = 4
const RADIUS = 200.0
const CENTER = Vector2.ONE * (RADIUS + 55.0)
const START_TIME = 60.0
const BASE_SPEED = 200.0 # deg/sec
const DECEL_RATE = 45.0 # deg

const PASS_COLOR = Color(0.18, 0.78, 0.3)
const FAIL_COLOR = Color(0.82, 0.22, 0.22)
const POINTER_COLOR = Color(1.0, 0.92, 0.22)
const BG_COLOR = Color(0.06, 0.06, 0.1)

enum State { SPINNING, DECEL, RESULT }

var state: State = State.SPINNING
var wheel_angle: float = 0.0
var spin_speed: float = BASE_SPEED

var passes_needed: int = 1
var passes_got: int = 0
var done: bool = false
var total_time: float = 0.0
var last_display: float = -1.0

var result_text: String = ""
var result_color: Color = Color.WHITE
var result_timer: float = 0.0

var segments: Array[bool] = [] # pass = true

@onready var time_label = %TimeLabel

func setup_layout() -> void:
	%InfoLabel.position = Vector2(RADIUS * 2.0 + 70.0, 20.0)
	%ActionButton.position = %InfoLabel.position + Vector2.DOWN * (%InfoLabel.size.y + 20.0)
	%TimeLabel.position = Vector2(0.0, RADIUS * 2.0 + 52.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	randomize()
	call_deferred("setup_layout")
	
	for i in PASS_COUNT: segments.append(true)
	for i in NUM_SEGMENTS - PASS_COUNT: segments.append(false)
	segments.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_time += delta
	queue_redraw()
	
	var left = START_TIME - total_time
	var display = snappedf(left, 0.01)
	if display != last_display:
		last_display = display
		time_label.text = "Time: %.2f" % maxf(display, 0.0)
	
	if left <= 0.0 and not done:
		done = true
		%ActionButton.disabled = true
		%ActionButton.text = "Time's Up!"
	
	if done: return
	
	match state:
		State.SPINNING: wheel_angle = fmod(wheel_angle + spin_speed * delta, 360.0)
		State.DECEL:
			spin_speed = max(0.0, spin_speed - DECEL_RATE * delta)
			wheel_angle = fmod(wheel_angle + spin_speed * delta, 360.0)
			if spin_speed == 0.0:
				state = State.RESULT
				result_timer = 1.6
				solve_outcome()
		State.RESULT:
			result_timer -= delta
			if result_timer <= 0.0:
				result_text = ""
				state = State.SPINNING
				spin_speed = randf_range(BASE_SPEED, BASE_SPEED + 160.0)

func solve_outcome():
	var semgent_degrees = 360.0 / NUM_SEGMENTS
	var rel = fmod(270.0 - wheel_angle + 3600.0, 360.0)
	var index = int(rel / semgent_degrees) % NUM_SEGMENTS
	
	if segments[index]:
		passes_got += 1
		result_text = "PASS!"
		result_color = PASS_COLOR
		if passes_got >= passes_needed:
			done = true
			project_completed.emit()
	else:
		result_text = "FAIL"
		result_color = FAIL_COLOR

func _draw() -> void:
	var segment_degrees = 360.0 / NUM_SEGMENTS
	var font = ThemeDB.fallback_font
	var font_size = 11
	
	draw_circle(CENTER, RADIUS  + 6.0, BG_COLOR)
	
	for i in NUM_SEGMENTS:
		var angle0 = deg_to_rad(wheel_angle + i * segment_degrees)
		var angle1 = deg_to_rad(wheel_angle + (i + 1) * segment_degrees)
		var color = PASS_COLOR if segments[i] else FAIL_COLOR
		
		var points = PackedVector2Array()
		points.append(CENTER)
		for s in range(24):
			var angle = lerp(angle0, angle1, float(s) / 23.0)
			points.append(CENTER + Vector2(cos(angle), sin(angle)) * RADIUS)
		draw_colored_polygon(points, color)
		
		draw_line(CENTER, CENTER + Vector2(cos(angle0), sin(angle0)) * RADIUS, Color(0.04, 0.04, 0.08), 2.0)
		
		var middle_angle = 0.5 * (angle0 + angle1)
		var label_position = CENTER + Vector2(cos(middle_angle), sin(middle_angle)) * RADIUS * 0.65
		var label = "PASS" if segments[i] else "FAIL"
		var tw = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		draw_string(font, label_position + Vector2(-tw * 0.5, font.get_ascent(font_size) * 0.5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	if state == State.RESULT:
		var rel = fmod(270.0 - wheel_angle + 3600.0, 360.0)
		var index = int(rel / segment_degrees) % NUM_SEGMENTS
		var highlight_angle_0 = deg_to_rad(wheel_angle + index * segment_degrees)
		var highlight_angle_1 = deg_to_rad(wheel_angle + (index + 1) * segment_degrees)
		var highlight_points = PackedVector2Array()
		for s in range(24):
			var angle = lerp(highlight_angle_0, highlight_angle_1, float(s) / 23.0)
			highlight_points.append(CENTER + Vector2(cos(angle), sin(angle)) * RADIUS)
		var alpha = clamp(result_timer / 1.6, 0.0, 0.55)
		draw_colored_polygon(highlight_points, Color(1.0, 1.0, 1.0, alpha)) # slowly fades over time
	
	draw_arc(CENTER, RADIUS, 0.0, TAU, 80, Color.SILVER, 3.5)
	
	#var ball_angle = deg_to_rad(wheel_angle + 180)
	#var ball_pos = CENTER + Vector2(cos(ball_angle), sin(ball_angle)) * (RADIUS + 16)
	#draw_circle(ball_pos, 12.0, Color(0.12, 0.12, 0.18))
	#draw_circle(ball_pos, 8.5, Color(0.95, 0.90, 0.45))
	#draw_circle(ball_pos + Vector2(-2.5, -2.5), 2.5, Color(1.0, 1.0, 0.8, 0.7)) # small shading
	
	draw_circle(CENTER, 20.0, Color(0.18, 0.18, 0.26))
	draw_circle(CENTER, 11.0, Color.SILVER)
	draw_circle(CENTER, 5.0, Color(0.12, 0.12, 0.18))
	
	var pointer_tip = CENTER + Vector2(0.0, -(RADIUS + 3.0))
	var pointer_left = CENTER + Vector2(-11, -(RADIUS + 26.0))
	var pointer_right = CENTER + Vector2(11, -(RADIUS + 26.0))
	draw_colored_polygon(PackedVector2Array([pointer_tip, pointer_left, pointer_right]), POINTER_COLOR)
	draw_arc(CENTER, RADIUS + 24.0, deg_to_rad(252.0), deg_to_rad(288.0), 12, POINTER_COLOR, 3.5)
	
	if result_text != "" and result_timer > 0.0:
		var alpha = clamp(result_timer / 1.6, 0.0, 1.0)
		var font_color = Color(result_color.r, result_color.g, result_color.b, alpha)
		var big = 30
		var rtw = font.get_string_size(result_text, HORIZONTAL_ALIGNMENT_LEFT, -1, big).x
		draw_string(font, CENTER + Vector2(-rtw * 0.5, font.get_ascent(big)* 0.5), result_text, HORIZONTAL_ALIGNMENT_LEFT, -1, big, font_color)
		
	var dot_gap = 28.0
	var dot_start = CENTER + Vector2(-(passes_needed * dot_gap) * 0.5 + dot_gap * 0.5, RADIUS + 32.0)
	for i in passes_needed:
		var color = PASS_COLOR if i < passes_got else Color(0.28, 0.28, 0.28)
		draw_circle(dot_start + Vector2(i * dot_gap, 0.0), 10.0, color)
		if i < passes_got: draw_arc(dot_start + Vector2(i * dot_gap, 0.0), 12.0, 0.0, TAU, 20, Color(0.5, 1.0, 0.5, 0.5), 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_on_action_button_pressed()
			get_viewport().set_input_as_handled()

func _on_action_button_pressed() -> void:
	if done: return
	if state == State.SPINNING: state = State.DECEL
