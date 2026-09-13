class_name HomeStars
extends Control

@export var star_count: int = 90
@export var min_radius: float = 0.7
@export var max_radius: float = 1.5
@export var vertical_fill: float = 0.58
@export var random_seed: int = 17341

class StarData:
	var pos_norm: Vector2
	var radius: float
	var base_color: Color
	var phase: float
	var twinkle_speed: float
	var twinkle_amount: float

var _stars: Array[StarData] = []
var _timer: Timer
var _internal_time: float = 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	generate_stars()
	_setup_twinkle_timer()


func generate_stars() -> void:
	_stars.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	for i in range(star_count):
		var star := StarData.new()
		# Position normalized: x in [0.01, 0.99], y in [0.02, vertical_fill]
		var nx := rng.randf_range(0.01, 0.99)
		var ny := rng.randf_range(0.02, clampf(vertical_fill, 0.1, 1.0))
		star.pos_norm = Vector2(nx, ny)

		# Radius: mostly smaller, few larger
		var t_size := rng.randf()
		# Biased slightly towards min_radius
		t_size = t_size * t_size
		star.radius = lerpf(min_radius, max_radius, t_size)

		# Color: subtle tints
		# Base color: subtle warm, cold, or neutral white
		var tint_roll := rng.randf()
		var col: Color
		if tint_roll < 0.65:
			# Neutral soft white
			col = Color(0.95, 0.96, 1.0)
		elif tint_roll < 0.85:
			# Slightly cool / blueish
			col = Color(0.88, 0.92, 1.0)
		else:
			# Slightly warm / golden
			col = Color(1.0, 0.97, 0.90)

		# Base alpha ~ 0.50 .. 0.82
		col.a = rng.randf_range(0.50, 0.82)
		star.base_color = col

		# Twinkle parameters
		star.phase = rng.randf_range(0.0, TAU)
		star.twinkle_speed = rng.randf_range(0.8, 2.5)
		star.twinkle_amount = rng.randf_range(0.08, 0.18)

		_stars.append(star)

	queue_redraw()


func _setup_twinkle_timer() -> void:
	if _timer != null:
		return
	_timer = Timer.new()
	_timer.wait_time = 0.1 # ~10 updates per sec
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_on_twinkle_tick)
	add_child(_timer)


func _on_twinkle_tick() -> void:
	if not is_visible_in_tree() or modulate.a <= 0.001:
		return
	_internal_time += 0.1
	queue_redraw()


func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return

	for star in _stars:
		var pos := Vector2(star.pos_norm.x * s.x, star.pos_norm.y * s.y)
		var factor: float = sin(_internal_time * star.twinkle_speed + star.phase) * star.twinkle_amount
		var col := star.base_color
		col.a = clampf(col.a + factor, 0.0, 1.0)
		draw_circle(pos, star.radius, col)


func get_stars_count() -> int:
	return _stars.size()


func get_star_data(index: int) -> StarData:
	if index >= 0 and index < _stars.size():
		return _stars[index]
	return null
