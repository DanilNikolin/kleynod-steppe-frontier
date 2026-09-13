class_name LocalTimeOfDayVisual
extends Node

@export var world_modulate: CanvasModulate
@export var sky_gradient_rect: TextureRect

@export var far_clouds_root: CanvasItem
@export var near_clouds_root: CanvasItem

@export var horizon_overlay: CanvasItem
@export var horizon_overlay_strength_cycle: Curve

@export var world_color_cycle: Gradient
@export var sky_top_color_cycle: Gradient
@export var sky_bottom_color_cycle: Gradient

@export var far_cloud_color_cycle: Gradient
@export var near_cloud_color_cycle: Gradient

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
	if far_clouds_root == null:
		far_clouds_root = get_node_or_null("../Clouds/FarClouds") as CanvasItem
	if near_clouds_root == null:
		near_clouds_root = get_node_or_null("../Clouds/NearClouds") as CanvasItem
	if horizon_overlay == null:
		horizon_overlay = get_node_or_null("../WorldContent/NightHorizonOverlay") as CanvasItem

	_ensure_default_gradients()
	_ensure_default_curve()
	_prepare_sky_gradient()

	if horizon_overlay != null:
		var c := horizon_overlay.modulate
		c.a = 0.0
		horizon_overlay.modulate = c
		horizon_overlay.visible = false


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
	var target_far_cloud_color := _sample_far_cloud_color(time01)
	var target_near_cloud_color := _sample_near_cloud_color(time01)
	var target_horizon_alpha := _sample_horizon_alpha(time01)

	if _tween != null and _tween.is_valid():
		_tween.kill()
		_tween = null

	if should_be_immediate or not is_inside_tree():
		_apply_colors(
			target_world_color,
			target_sky_top_color,
			target_sky_bottom_color,
			target_far_cloud_color,
			target_near_cloud_color,
			target_horizon_alpha
		)
		return

	# Smooth tween transition
	var current_world := world_modulate.color if world_modulate != null else target_world_color
	var current_sky_top := target_sky_top_color
	var current_sky_bottom := target_sky_bottom_color

	if _cached_sky_gradient != null and _cached_sky_gradient.get_point_count() >= 2:
		current_sky_top = _cached_sky_gradient.get_color(0)
		current_sky_bottom = _cached_sky_gradient.get_color(1)

	var current_far_cloud := far_clouds_root.modulate if far_clouds_root != null else target_far_cloud_color
	var current_near_cloud := near_clouds_root.modulate if near_clouds_root != null else target_near_cloud_color
	var current_horizon_alpha := horizon_overlay.modulate.a if horizon_overlay != null else target_horizon_alpha

	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_tween.tween_method(
		func(t: float) -> void:
			var w := current_world.lerp(target_world_color, t)
			var st := current_sky_top.lerp(target_sky_top_color, t)
			var sb := current_sky_bottom.lerp(target_sky_bottom_color, t)
			var fc := current_far_cloud.lerp(target_far_cloud_color, t)
			var nc := current_near_cloud.lerp(target_near_cloud_color, t)
			var ha := lerpf(current_horizon_alpha, target_horizon_alpha, t)
			_apply_colors(w, st, sb, fc, nc, ha),
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


func _sample_far_cloud_color(time01: float) -> Color:
	if far_cloud_color_cycle != null:
		return far_cloud_color_cycle.sample(time01)
	return Color.WHITE


func _sample_near_cloud_color(time01: float) -> Color:
	if near_cloud_color_cycle != null:
		return near_cloud_color_cycle.sample(time01)
	return Color.WHITE


func _sample_horizon_alpha(time01: float) -> float:
	if horizon_overlay_strength_cycle != null:
		return clampf(horizon_overlay_strength_cycle.sample_baked(time01), 0.0, 1.0)
	return 0.0


func _apply_colors(
	world_color: Color,
	sky_top: Color,
	sky_bottom: Color,
	far_cloud: Color = Color.WHITE,
	near_cloud: Color = Color.WHITE,
	horizon_alpha: float = 0.0
) -> void:
	if world_modulate != null:
		world_modulate.color = world_color

	if _cached_sky_gradient != null and _cached_sky_gradient.get_point_count() >= 2:
		_cached_sky_gradient.set_color(0, sky_top)
		_cached_sky_gradient.set_color(1, sky_bottom)

	if far_clouds_root != null:
		far_clouds_root.modulate = far_cloud

	if near_clouds_root != null:
		near_clouds_root.modulate = near_cloud

	if horizon_overlay != null:
		var c := horizon_overlay.modulate
		c.a = horizon_alpha
		horizon_overlay.modulate = c
		horizon_overlay.visible = (horizon_alpha > 0.001)


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
	if far_cloud_color_cycle == null:
		far_cloud_color_cycle = _create_default_far_cloud_gradient()
	if near_cloud_color_cycle == null:
		near_cloud_color_cycle = _create_default_near_cloud_gradient()


func _ensure_default_curve() -> void:
	if horizon_overlay_strength_cycle == null:
		horizon_overlay_strength_cycle = _create_default_horizon_overlay_curve()


static func _setup_gradient(g: Gradient, points_data: Array) -> Gradient:
	# Godot Gradient requires at least 1 or 2 points and throws an error if points.size() <= 1 on remove_point.
	# We update point 0 and 1 first, then add the rest.
	if points_data.size() >= 1:
		g.set_offset(0, points_data[0][0])
		g.set_color(0, points_data[0][1])
	if points_data.size() >= 2 and g.get_point_count() >= 2:
		g.set_offset(1, points_data[1][0])
		g.set_color(1, points_data[1][1])

	# Remove any extra points beyond index 1 if there were more
	while g.get_point_count() > 2:
		g.remove_point(2)

	# Add remaining points from index 2 onwards
	for i in range(2, points_data.size()):
		g.add_point(points_data[i][0], points_data[i][1])

	return g


static func _create_default_world_gradient() -> Gradient:
	var g := Gradient.new()
	return _setup_gradient(g, [
		[0.000, Color(0.48, 0.52, 0.65, 1.0)], # 00:00 - Night
		[0.188, Color(0.55, 0.58, 0.70, 1.0)], # 04:30 - Pre-dawn
		[0.250, Color(0.92, 0.75, 0.65, 1.0)], # 06:00 - Sunrise
		[0.333, Color(0.98, 0.95, 0.90, 1.0)], # 08:00 - Morning
		[0.500, Color(1.00, 1.00, 1.00, 1.0)], # 12:00 - Neutral Day
		[0.708, Color(0.98, 0.88, 0.78, 1.0)], # 17:00 - Evening
		[0.771, Color(0.85, 0.62, 0.52, 1.0)], # 18:30 - Sunset
		[0.833, Color(0.52, 0.55, 0.68, 1.0)], # 20:00 - Twilight
		[1.000, Color(0.48, 0.52, 0.65, 1.0)]  # 24:00 - Night
	])


static func _create_default_sky_top_gradient() -> Gradient:
	var g := Gradient.new()
	return _setup_gradient(g, [
		[0.000, Color(0.08, 0.10, 0.18, 1.0)], # 00:00 - Deep night sky top
		[0.188, Color(0.14, 0.17, 0.28, 1.0)], # 04:30 - Pre-dawn
		[0.250, Color(0.26, 0.35, 0.52, 1.0)], # 06:00 - Sunrise
		[0.333, Color(0.26, 0.50, 0.74, 1.0)], # 08:00 - Morning
		[0.500, Color(0.24, 0.49, 0.75, 1.0)], # 12:00 - Neutral day
		[0.708, Color(0.28, 0.44, 0.66, 1.0)], # 17:00 - Evening
		[0.771, Color(0.22, 0.28, 0.45, 1.0)], # 18:30 - Sunset
		[0.833, Color(0.12, 0.15, 0.25, 1.0)], # 20:00 - Twilight
		[1.000, Color(0.08, 0.10, 0.18, 1.0)]  # 24:00 - Deep night
	])


static func _create_default_sky_bottom_gradient() -> Gradient:
	var g := Gradient.new()
	return _setup_gradient(g, [
		[0.000, Color(0.18, 0.22, 0.32, 1.0)], # 00:00 - Night horizon
		[0.188, Color(0.32, 0.30, 0.40, 1.0)], # 04:30 - Pre-dawn horizon
		[0.250, Color(0.88, 0.58, 0.48, 1.0)], # 06:00 - Sunrise peach/pink
		[0.333, Color(0.68, 0.82, 0.94, 1.0)], # 08:00 - Morning light blue
		[0.500, Color(0.72, 0.86, 0.96, 1.0)], # 12:00 - Day light blue
		[0.708, Color(0.86, 0.72, 0.58, 1.0)], # 17:00 - Evening warm
		[0.771, Color(0.78, 0.46, 0.38, 1.0)], # 18:30 - Sunset dusk
		[0.833, Color(0.26, 0.26, 0.38, 1.0)], # 20:00 - Twilight dusk
		[1.000, Color(0.18, 0.22, 0.32, 1.0)]  # 24:00 - Night horizon
	])


static func _create_default_far_cloud_gradient() -> Gradient:
	var g := Gradient.new()
	return _setup_gradient(g, [
		[0.000, Color(0.72, 0.76, 0.88, 1.0)], # 00:00 - Night: cold slate
		[0.188, Color(0.78, 0.80, 0.90, 1.0)], # 04:30 - Pre-dawn
		[0.250, Color(0.96, 0.88, 0.85, 1.0)], # 06:00 - Sunrise: soft peach tint
		[0.333, Color(1.00, 1.00, 1.00, 1.0)], # 08:00 - Morning
		[0.500, Color(1.00, 1.00, 1.00, 1.0)], # 12:00 - Day: neutral white
		[0.708, Color(0.98, 0.94, 0.90, 1.0)], # 17:00 - Evening
		[0.771, Color(0.92, 0.82, 0.80, 1.0)], # 18:30 - Sunset: dusky glow
		[0.833, Color(0.76, 0.78, 0.88, 1.0)], # 20:00 - Twilight
		[1.000, Color(0.72, 0.76, 0.88, 1.0)]  # 24:00 - Night
	])


static func _create_default_near_cloud_gradient() -> Gradient:
	var g := Gradient.new()
	return _setup_gradient(g, [
		[0.000, Color(0.64, 0.68, 0.80, 1.0)], # 00:00 - Night: darker cool tone
		[0.188, Color(0.70, 0.73, 0.84, 1.0)], # 04:30 - Pre-dawn
		[0.250, Color(0.92, 0.82, 0.80, 1.0)], # 06:00 - Sunrise: soft rose
		[0.333, Color(1.00, 1.00, 1.00, 1.0)], # 08:00 - Morning
		[0.500, Color(1.00, 1.00, 1.00, 1.0)], # 12:00 - Day: neutral white
		[0.708, Color(0.96, 0.90, 0.85, 1.0)], # 17:00 - Evening
		[0.771, Color(0.88, 0.76, 0.74, 1.0)], # 18:30 - Sunset
		[0.833, Color(0.68, 0.70, 0.82, 1.0)], # 20:00 - Twilight
		[1.000, Color(0.64, 0.68, 0.80, 1.0)]  # 24:00 - Night
	])


static func _create_default_horizon_overlay_curve() -> Curve:
	var c := Curve.new()
	c.bake_resolution = 100
	c.min_value = 0.0
	c.max_value = 1.0

	# 00:00 (0.000) - Night: 1.00 full authored overlay intensity
	c.add_point(Vector2(0.000, 1.00))
	# 04:30 (0.188) - Pre-dawn: 0.65
	c.add_point(Vector2(0.188, 0.65))
	# 06:00 (0.250) - Sunrise: 0.10
	c.add_point(Vector2(0.250, 0.10))
	# 08:00 (0.333) - Morning: 0.00
	c.add_point(Vector2(0.333, 0.00))
	# 12:00 (0.500) - Noon: 0.00
	c.add_point(Vector2(0.500, 0.00))
	# 17:00 (0.708) - Evening: 0.00
	c.add_point(Vector2(0.708, 0.00))
	# 18:30 (0.771) - Sunset: 0.20
	c.add_point(Vector2(0.771, 0.20))
	# 20:00 (0.833) - Twilight: 0.70
	c.add_point(Vector2(0.833, 0.70))
	# 22:00 (0.917) - Late night: 1.00
	c.add_point(Vector2(0.917, 1.00))
	# 24:00 (1.000) - Night: 1.00
	c.add_point(Vector2(1.000, 1.00))
	return c
