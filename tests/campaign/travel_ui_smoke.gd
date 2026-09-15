extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var runtime = root.get_node("CampaignRuntime")
	runtime.start_new_campaign()
	# Use a private map so this test is independent of random event rolls.
	runtime.campaign_definition = runtime.campaign_definition.duplicate(true)
	for route in runtime.get_world_map_definition().routes:
		route.travel_event_profile = null
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	sandbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sandbox._show_view(sandbox.View.WORLD_MAP)
	await process_frame
	var panel = sandbox._world_map_panel
	panel._on_node_selected(&"debug_city")
	if panel._travel_button.disabled or not panel._selection_label.text.contains("Малое село"):
		push_error("Multi-leg destination preview is unavailable")
		quit(1)
		return
	var before: int = runtime.campaign_state.current_minute_of_day
	panel._on_travel_pressed()
	await create_timer(1.0).timeout
	if runtime.campaign_state.current_minute_of_day == before or runtime.pending_travel.progress <= 0:
		push_error("Clock does not advance during animation")
		quit(1)
		return
	await create_timer(10.0).timeout
	if runtime.has_pending_travel() or runtime.campaign_state.current_world_node_id != &"debug_city":
		push_error("UI failed to finish multi-leg trip")
		quit(1)
		return
	print("TRAVEL UI SMOKE: GREEN")
	sandbox.queue_free()
	await process_frame
	quit(0)
