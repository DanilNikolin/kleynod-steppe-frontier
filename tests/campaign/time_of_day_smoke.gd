extends SceneTree

var failures: int = 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	for minute in [1380, 720, 180]:
		runtime.campaign_state.current_minute_of_day = minute
		sandbox._show_view(sandbox.View.LOCAL_LOCATION)
		var panel = sandbox._shell._immersive_content_host.get_child(0)
		var debug_panel = panel.find_child("DebugTimePanel", true, false)
		debug_panel.get_parent().remove_child(debug_panel)
		debug_panel.queue_free()
		await process_frame
		var controllers = panel._canvas._world_root.find_children("*", "LocalTimeOfDayVisual", true, false)
		check(not controllers.is_empty(), "HOME has lighting controller")
		for controller in controllers:
			check(controller.get_current_minute_of_day() == minute, "Entry uses campaign time without debug UI")
			var expected: Color = controller.world_color_cycle.sample(float(minute) / 1440.0)
			check(controller.world_modulate.color.is_equal_approx(expected), "Entry immediately applies authored lighting")
			if controller.stars_root != null:
				check(controller.stars_root.visible == (minute != 720), "Stars follow day/night on entry")
		sandbox._show_view(sandbox.View.WORLD_MAP)
		await process_frame
	# Explicit pre-tree initialization also works without a panel or debug controls.
	var stage = load("res://scenes/campaign/local_location/home_visual_stage.tscn").instantiate()
	var controller = stage.find_children("*", "LocalTimeOfDayVisual", true, false)[0]
	controller.set_time_of_day(1380, true)
	root.add_child(stage)
	check(controller.world_modulate.color.is_equal_approx(controller.world_color_cycle.sample(1380.0 / 1440.0)), "Pre-ready time replayed after initialization")
	stage.queue_free()
	sandbox.queue_free()
	await process_frame
	print("TIME OF DAY SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
