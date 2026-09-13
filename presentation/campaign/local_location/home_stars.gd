class_name HomeStars
extends Node2D

@export var field_left: float = -200.0
@export var field_width: float = 6200.0
@export var stars_min_y: float = 30.0
@export var stars_max_y: float = 480.0
@export var star_count: int = 380

@export var min_radius: float = 1.0
@export var max_radius: float = 2.2
@export var random_seed: int = 17341

class StarData:
	var world_position: Vector2
	var radius: float
	var base_color: Color
	var phase: float
	var twinkle_speed: float
	var twinkle_amount: float

var _stars: Array[StarData] = []
var _timer: Timer
var _internal_time: float = 0.0


func _ready() -> void:
	generate_stars()
	_setup_twinkle_timer()


func generate_stars() -> void:
	_stars.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	for i in range(star_count):
		var star := StarData.new()
		var wx := rng.randf_range(field_left, field_left + field_width)
		var wy := rng.randf_range(stars_min_y, stars_max_y)
		star.world_position = Vector2(wx, wy)

		# Tiered distribution:
		# ~70% small & faint (1.0 .. 1.3 rad, alpha 0.45 .. 0.60)
		# ~20% medium (1.3 .. 1.7 rad, alpha 0.55 .. 0.70)
		# ~10% bright & larger (1.7 .. 2.2 rad, alpha 0.70 .. 0.82)
		var tier_roll := rng.randf()
		var base_a: float
		if tier_roll < 0.70:
			star.radius = rng.randf_range(min_radius, lerpf(min_radius, max_radius, 0.25))
			base_a = rng.randf_range(0.45, 0.60)
		elif tier_roll < 0.90:
			star.radius = rng.randf_range(lerpf(min_radius, max_radius, 0.25), lerpf(min_radius, max_radius, 0.60))
			base_a = rng.randf_range(0.55, 0.70)
		else:
			star.radius = rng.randf_range(lerpf(min_radius, max_radius, 0.60), max_radius)
			base_a = rng.randf_range(0.70, 0.82)

		# Color: subtle tints (neutral, slightly cool, or slightly warm)
		var tint_roll := rng.randf()
		var col: Color
		if tint_roll < 0.65:
			# Neutral soft white
			col = Color(0.95, 0.96, 1.0, base_a)
		elif tint_roll < 0.85:
			# Slightly cool / blueish
			col = Color(0.88, 0.92, 1.0, base_a)
		else:
			# Slightly warm / golden
			col = Color(1.0, 0.97, 0.90, base_a)

		star.base_color = col

		# Twinkle parameters (noticeable micro-fluctuations, not on/off blinking)
		star.phase = rng.randf_range(0.0, TAU)
		star.twinkle_speed = rng.randf_range(1.0, 2.8)
		star.twinkle_amount = rng.randf_range(0.08, 0.20)

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
	for star in _stars:
		var factor: float = sin(_internal_time * star.twinkle_speed + star.phase) * star.twinkle_amount
		var col := star.base_color
		col.a = clampf(col.a + factor, 0.0, 1.0)
		draw_circle(star.world_position, star.radius, col)


func get_stars_count() -> int:
	return _stars.size()


func get_star_data(index: int) -> StarData:
	if index >= 0 and index < _stars.size():
		return _stars[index]
	return null
