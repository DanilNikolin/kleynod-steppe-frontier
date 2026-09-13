class_name LocalTimeOfDayVisual
extends Node

@export var world_modulate: CanvasModulate
@export var sky_gradient_rect: TextureRect

@export var world_color_cycle: Gradient
@export var sky_top_color_cycle: Gradient
@export var sky_bottom_color_cycle: Gradient

@export var transition_duration: float = 0.8

var _is_first_sync: bool = true
var _tween: Tween
var _current_minute_of_day: int = -1

# Cached working resources for sky
var _cached_sky_gradient: Gradient
var _cached_sky_texture: GradientTexture2D


func _ready() -> void:
	if world_modulate == null:
		world_modulate = get_node_or_null("WorldModulate") as CanvasModulate
	if sky_gradient_rect == null:
		sky_gradient_rect = get_node_or_null("../SkyLayer/SkyGradient") as TextureRect

	_ensure_default_gradients()
	_prepare_sky_gradient()


func set_time_of_day(minute_of_day: int, immediate: bool = false) -> void:
	var should_be_immediate := immediate or _is_first_sync
	_is_first_sync = false

	if _current_minute_of_day == minute_of_day and not should_be_immediate:
		return

	_current_minute_of_day = minute_of_day
	var time01 := float(posmod(minute_of_day, 1440)) / 1440.0

	var target_world_color := _sample_world_color(time01)
	var target_sky_top_color := _sample_sky_top_color(time01)
	var target_sky_bottom_color := _sample_sky_bottom_color(time01)

	if _tween != null and _tween.is_valid():
		_tween.kill()
		_tween = null

	if should_be_immediate or not is_inside_tree():
		_apply_colors(target_world_color, target_sky_top_color, target_sky_bottom_color)
		return

	# Smooth tween transition
	var current_world := world_modulate.color if world_modulate != null else target_world_color
	var current_sky_top := target_sky_top_color
	var current_sky_bottom := target_sky_bottom_color

	if _cached_sky_gradient != null and _cached_sky_gradient.get_point_count() >= 2:
		current_sky_top = _cached_sky_gradient.get_color(0)
		current_sky_bottom = _cached_sky_gradient.get_color(1)

	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_tween.tween_method(
		func(t: float) -> void:
			var w := current_world.lerp(target_world_color, t)
			var st := current_sky_top.lerp(target_sky_top_color, t)
			var sb := current_sky_bottom.lerp(target_sky_bottom_color, t)
			_apply_colors(w, st, sb),
		0.0,
		1.0,
		transition_duration
	)


func get_current_minute_of_day() -> int:
	return _current_minute_of_day


func _sample_world_color(time01: float) -> Color:
	if world_color_cycle != null:
		return world_color_cycle.sample(time01)
	return Color.WHITE


func _sample_sky_top_color(time01: float) -> Color:
	if sky_top_color_cycle != null:
		return sky_top_color_cycle.sample(time01)
	return Color(0.24, 0.49, 0.75, 1.0)


func _sample_sky_bottom_color(time01: float) -> Color:
	if sky_bottom_color_cycle != null:
		return sky_bottom_color_cycle.sample(time01)
	return Color(0.72, 0.86, 0.96, 1.0)


func _apply_colors(world_color: Color, sky_top: Color, sky_bottom: Color) -> void:
	if world_modulate != null:
		world_modulate.color = world_color

	if _cached_sky_gradient != null and _cached_sky_gradient.get_point_count() >= 2:
		_cached_sky_gradient.set_color(0, sky_top)
		_cached_sky_gradient.set_color(1, sky_bottom)


func _prepare_sky_gradient() -> void:
	if sky_gradient_rect == null:
		return

	var original_tex := sky_gradient_rect.texture as GradientTexture2D
	if original_tex != null:
		_cached_sky_texture = original_tex.duplicate(true) as GradientTexture2D
		if _cached_sky_texture != null and _cached_sky_texture.gradient != null:
			_cached_sky_gradient = _cached_sky_texture.gradient.duplicate(true)
			_cached_sky_texture.gradient = _cached_sky_gradient
		sky_gradient_rect.texture = _cached_sky_texture
	elif sky_gradient_rect.texture == null:
		_cached_sky_gradient = Gradient.new()
		_cached_sky_gradient.set_color(0, Color(0.24, 0.49, 0.75, 1.0))
		_cached_sky_gradient.set_color(1, Color(0.72, 0.86, 0.96, 1.0))
		_cached_sky_texture = GradientTexture2D.new()
		_cached_sky_texture.gradient = _cached_sky_gradient
		_cached_sky_texture.fill_to = Vector2(0, 1)
		sky_gradient_rect.texture = _cached_sky_texture


func _ensure_default_gradients() -> void:
	if world_color_cycle == null:
		world_color_cycle = _create_default_world_gradient()
	if sky_top_color_cycle == null:
		sky_top_color_cycle = _create_default_sky_top_gradient()
	if sky_bottom_color_cycle == null:
		sky_bottom_color_cycle = _create_default_sky_bottom_gradient()


static func _create_default_world_gradient() -> Gradient:
	var g := Gradient.new()
	# Clear default points
	while g.get_point_count() > 0:
		g.remove_point(0)

	# 00:00 (0.000) - Night: cool desaturated blue-slate, readable
	g.add_point(0.000, Color(0.48, 0.52, 0.65, 1.0))
	# 04:30 (0.188) - Pre-dawn: cold twilight
	g.add_point(0.188, Color(0.55, 0.58, 0.70, 1.0))
	# 06:00 (0.250) - Sunrise: warm golden/rose tint
	g.add_point(0.250, Color(0.92, 0.75, 0.65, 1.0))
	# 08:00 (0.333) - Morning: clear, slightly warm
	g.add_point(0.333, Color(0.98, 0.95, 0.90, 1.0))
	# 12:00 (0.500) - Neutral Day: pure white (1.0, 1.0, 1.0)
	g.add_point(0.500, Color(1.00, 1.00, 1.00, 1.0))
	# 17:00 (0.708) - Evening: warm amber/ochre
	g.add_point(0.708, Color(0.98, 0.88, 0.78, 1.0))
	# 18:30 (0.771) - Sunset: dusky reddish/terracotta
	g.add_point(0.771, Color(0.85, 0.62, 0.52, 1.0))
	# 20:00 (0.833) - Twilight / Night fall: dimming blue
	g.add_point(0.833, Color(0.52, 0.55, 0.68, 1.0))
	# 24:00 (1.000) - Night
	g.add_point(1.000, Color(0.48, 0.52, 0.65, 1.0))
	return g


static func _create_default_sky_top_gradient() -> Gradient:
	var g := Gradient.new()
	while g.get_point_count() > 0:
		g.remove_point(0)

	# 00:00 (0.000) - Deep night sky top
	g.add_point(0.000, Color(0.08, 0.10, 0.18, 1.0))
	# 04:30 (0.188) - Pre-dawn
	g.add_point(0.188, Color(0.14, 0.17, 0.28, 1.0))
	# 06:00 (0.250) - Sunrise
	g.add_point(0.250, Color(0.26, 0.35, 0.52, 1.0))
	# 08:00 (0.333) - Morning
	g.add_point(0.333, Color(0.26, 0.50, 0.74, 1.0))
	# 12:00 (0.500) - Neutral day
	g.add_point(0.500, Color(0.24, 0.49, 0.75, 1.0))
	# 17:00 (0.708) - Evening
	g.add_point(0.708, Color(0.28, 0.44, 0.66, 1.0))
	# 18:30 (0.771) - Sunset
	g.add_point(0.771, Color(0.22, 0.28, 0.45, 1.0))
	# 20:00 (0.833) - Twilight
	g.add_point(0.833, Color(0.12, 0.15, 0.25, 1.0))
	# 24:00 (1.000) - Deep night
	g.add_point(1.000, Color(0.08, 0.10, 0.18, 1.0))
	return g


static func _create_default_sky_bottom_gradient() -> Gradient:
	var g := Gradient.new()
	while g.get_point_count() > 0:
		g.remove_point(0)

	# 00:00 (0.000) - Night horizon
	g.add_point(0.000, Color(0.18, 0.22, 0.32, 1.0))
	# 04:30 (0.188) - Pre-dawn horizon
	g.add_point(0.188, Color(0.32, 0.30, 0.40, 1.0))
	# 06:00 (0.250) - Sunrise peach/pink horizon
	g.add_point(0.250, Color(0.88, 0.58, 0.48, 1.0))
	# 08:00 (0.333) - Morning light blue
	g.add_point(0.333, Color(0.68, 0.82, 0.94, 1.0))
	# 12:00 (0.500) - Day light blue horizon
	g.add_point(0.500, Color(0.72, 0.86, 0.96, 1.0))
	# 17:00 (0.708) - Evening warm horizon
	g.add_point(0.708, Color(0.86, 0.72, 0.58, 1.0))
	# 18:30 (0.771) - Sunset dusk horizon
	g.add_point(0.771, Color(0.78, 0.46, 0.38, 1.0))
	# 20:00 (0.833) - Twilight dusk horizon
	g.add_point(0.833, Color(0.26, 0.26, 0.38, 1.0))
	# 24:00 (1.000) - Night horizon
	g.add_point(1.000, Color(0.18, 0.22, 0.32, 1.0))
	return g
