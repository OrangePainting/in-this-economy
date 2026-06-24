extends Control

signal project_completed

const NUM_RINGS = 5
const RING_GAP = 48.0
const CENTER = Vector2.ONE * (NUM_RINGS * RING_GAP + 50)
const GAP_DEG = 55.0
const BASE_SPEED = 100.0
const START_TIME = 30.0

const COLORS = [
	Color(0.95, 0.4, 0.4),
	Color(0.95, 0.72, 0.72),
	Color(0.4, 0.85, 0.4),
	Color(0.4, 0.6, 0.95)]

var player_ring: int = NUM_RINGS
var ring_angles: Array[float] = []
var ring_speeds: Array[float] = []
var total_time: float = 0.0
var last_display = -1.0
var done: bool = false
var flashing: bool = false

@onready var time_label = %TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in NUM_RINGS:
		ring_angles.append(randf_range(60.0, 300.0))
		var speed = BASE_SPEED + i * 27.0
		ring_speeds.append(speed if i % 2 == 0 else -speed) # alternating
	
	%InfoLabel.position = Vector2.RIGHT * RING_GAP * (NUM_RINGS + 1) * 2
	%ActionButton.position = %InfoLabel.position + Vector2.DOWN * (%InfoLabel.size.y + 20)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if done: return
	total_time += delta
	for i in NUM_RINGS: ring_angles[i] = fmod(ring_angles[i] + ring_speeds[i] * delta + 360.0, 360.0)
	queue_redraw()
	
	var display = snappedf(START_TIME - total_time, 0.0)
	if display != last_display:
		last_display = display
		time_label.text = "Time %.2f" % maxf(display, 0.0)
	
	if START_TIME - total_time <= 0.0: done = true

func _draw() -> void:
	var inactive_ring_section = (NUM_RINGS + 0.5) * RING_GAP
	draw_circle(CENTER, inactive_ring_section, Color(0.08, 0.08, 0.12))
	
	for i in range(NUM_RINGS - 1, -1, -1):
		var ring = float(i + 1) * RING_GAP
		var color = COLORS[i % len(COLORS)]
		if (i + 1) == player_ring and not done:
			color = color.lightened(0.28)
		
		var gap_start = deg_to_rad(ring_angles[i])
		var gap_end = deg_to_rad(ring_angles[i] + GAP_DEG)
		draw_arc(CENTER, ring, gap_end, gap_start + TAU, 80, color, 6.0, true)
		draw_arc(CENTER, ring, gap_start, gap_end, 20, Color(color.r, color.g, color.b, 0.2), 6.0, true)
	
	draw_line(CENTER, CENTER + Vector2(inactive_ring_section, 0.0), Color(1.0, 1.0, 1.0, 0.25), 2.0)
	
	# Goal
	draw_circle(CENTER, 14.0, Color.GOLD)
	draw_circle(CENTER, 8.0, Color.DARK_GOLDENROD)
	
	# Character
	if not done and player_ring > 0:
		var player_center = CENTER + Vector2(player_ring * RING_GAP, 0.0)
		var player_color = Color(0.3, 0.7, 1.0) if not flashing else Color.RED
		draw_circle(player_center, 10.0, player_color)
		draw_circle(player_center, 6.0, player_color.lightened(0.4))

func gap_at_zero(ring: int) -> bool:
	var index = ring - 1
	if index < 0 or index >= NUM_RINGS: return false
	var gap_start = ring_angles[index]
	var gap_end = fmod(gap_start + GAP_DEG, 360.0)
	if gap_start <= gap_end: return 0.0 >= gap_start and 0.0 <= gap_end
	return 0.0 >= gap_start or 0.0 <= gap_end

func flash() -> void:
	flashing = true
	await get_tree().create_timer(0.25).timeout
	flashing = false

func _on_action_button_pressed() -> void:
	if done: return
	if gap_at_zero(player_ring):
		player_ring -= 1
		if player_ring <= 0:
			done = true
			project_completed.emit()
	else:
		player_ring = NUM_RINGS
		flash()
