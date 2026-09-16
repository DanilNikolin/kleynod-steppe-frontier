extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func run() -> void:
	# 1. Environment component check
	var env_scene := load("res://scenes/battle/environments/deep_forest_environment.tscn") as PackedScene
	check(env_scene != null, "deep_forest_environment.tscn loaded")
	var env := env_scene.instantiate() as BattleEnvironment
	root.add_child(env)
	await process_frame

	check(env.has_time_of_day_visual(), "Environment has time of day visual")
	var visual: LocalTimeOfDayVisual = env.get_time_of_day_visual()
	check(visual != null, "get_time_of_day_visual() returns LocalTimeOfDayVisual")
	check(visual.world_modulate != null, "WorldModulate CanvasModulate exists")

	env.set_time_of_day(720, true)
	await process_frame
	var noon_color: Color = visual.world_modulate.color

	env.set_time_of_day(0, true)
	await process_frame
	var night_color: Color = visual.world_modulate.color

	check(env.get_minute_of_day() == 0, "Controller minute changes to 0")
	check(noon_color != night_color, "Day and night world modulate colors differ (noon=%s, night=%s)" % [noon_color, night_color])

	env.queue_free()
	await process_frame

	# 2. BattleScreen F6 standalone behavior
	var screen := load("res://scenes/battle/battle_screen.tscn").instantiate() as BattleScreen
	screen.auto_start_battle = false
	root.add_child(screen)
	await process_frame

	var panel := screen.get_node_or_null("BattleUI/Root/DebugTimePanel")
	check(panel != null, "DebugTimePanel exists in BattleUI/Root")
	var slider := panel.find_child("TimeSlider", true, false) as HSlider
	var label := panel.find_child("TimeLabel", true, false) as Label
	check(slider != null, "TimeSlider exists")
	check(label != null, "TimeLabel exists")

	check(slider.min_value == 0.0, "Slider min_value == 0")
	check(slider.max_value == 1439.0, "Slider max_value == 1439")
	check(slider.step == 10.0, "Slider step == 10")
	check(slider.value == 720.0, "Standalone default slider value is 720")
	check("12:00" in label.text, "Label displays 12:00 initially")

	# Move slider to 1200 (20:00)
	slider.value = 1200.0
	await process_frame
	check("20:00" in label.text, "Label updates to 20:00 on slider change (got: %s)" % label.text)
	check(screen.environment != null and screen.environment.get_minute_of_day() == 1200,
		"Battle environment updated to 1200 via slider")

	screen.queue_free()
	await process_frame

	# 3. Campaign initialization & non-mutation test
	var runtime := root.get_node_or_null("CampaignRuntime") as CampaignRuntimeService
	if runtime == null:
		runtime = CampaignRuntimeService.new()
		runtime.name = "CampaignRuntime"
		root.add_child(runtime)

	check(runtime.start_new_campaign(), "Start new campaign for time check")
	var initial_minute := 1110 # 18:30
	runtime.get_campaign_state().current_minute_of_day = initial_minute

	check(runtime.start_location(&"debug_deep_forest"), "Launch deep forest campaign location")
	await scene_changed
	var campaign_screen := current_scene as BattleScreen
	check(campaign_screen != null, "Campaign battle screen loaded")

	check(campaign_screen._visual_minute_of_day == initial_minute,
		"BattleScreen visual minute initialized to campaign state minute 1110 (got: %d)" % campaign_screen._visual_minute_of_day)
	check(campaign_screen.environment != null and campaign_screen.environment.get_minute_of_day() == initial_minute,
		"Environment initialized to 18:30")

	var c_panel := campaign_screen.get_node_or_null("BattleUI/Root/DebugTimePanel")
	var c_slider := c_panel.find_child("TimeSlider", true, false) as HSlider
	var c_label := c_panel.find_child("TimeLabel", true, false) as Label
	check(c_slider != null and c_slider.value == float(initial_minute), "Campaign slider initialized to 1110")
	check("18:30" in c_label.text, "Campaign label text shows 18:30")

	# CRITICAL NON-MUTATION TEST: Drag slider to 0 (midnight)
	c_slider.value = 0.0
	await process_frame
	check(campaign_screen._visual_minute_of_day == 0, "Battle visual is midnight 00:00")
	check("00:00" in c_label.text, "Label text updated to 00:00")
	check(runtime.get_campaign_state().current_minute_of_day == initial_minute,
		"CRITICAL: CampaignState.current_minute_of_day was NOT mutated by slider (expected %d, got %d)" % [initial_minute, runtime.get_campaign_state().current_minute_of_day])

	print("BATTLE TIME OF DAY SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
