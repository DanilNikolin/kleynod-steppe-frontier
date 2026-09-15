extends SceneTree

var failures: int = 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")
	runtime.campaign_definition = runtime.campaign_definition.duplicate(true)
	var world := runtime.get_world_map_definition()
	world.get_route(&"debug_route_village_city").travel_event_profile.event_chance = 1.0
	var service := CampaignTravelService.new()
	var path := service.get_shortest_path(world, &"debug_home", &"debug_city",
		runtime.get_home_settlement_definition(), runtime.get_home_settlement_state())
	check(path == [&"debug_home", &"debug_village", &"debug_city"], "Locked river is bypassed via village")
	var river := world.get_route(&"debug_route_home_city_river")
	river.required_home_settlement_effect_id = &""
	check(service.get_shortest_path(world, &"debug_home", &"debug_city",
		runtime.get_home_settlement_definition(), runtime.get_home_settlement_state()) == [&"debug_home", &"debug_city"], "Choose faster river when available")
	river.required_home_settlement_effect_id = &"river_transport_access"
	check(service.get_shortest_path(world, &"debug_home", &"debug_home_materials_node",
		runtime.get_home_settlement_definition(), runtime.get_home_settlement_state()).is_empty(), "Locked grove stays locked")
	check(service.get_shortest_path(world, &"debug_home", &"missing", null, null).is_empty(), "Unknown destination")
	var minutes := service.get_travel_minutes(world, &"debug_home", &"debug_village")
	check(minutes > 0 and minutes % 1440 != 0, "Distance preserves partial days")
	var initial := runtime.campaign_state.current_day * 1440 + runtime.campaign_state.current_minute_of_day
	check(runtime.begin_travel(&"debug_city"), "Begin multi-leg travel")
	check(runtime.advance_pending_travel_progress(0.5), "Live clock advances midway")
	var midway := runtime.campaign_state.current_day * 1440 + runtime.campaign_state.current_minute_of_day
	check(midway - initial == int(round(minutes * 0.5)), "Exact partial duration")
	check(runtime.advance_pending_travel_progress(0.5), "Duplicate tick is idempotent")
	check(not runtime.advance_pending_travel_progress(0.4), "Reject backward progress")
	check(runtime.advance_pending_travel_to_next_stop(), "Finish first leg")
	check(runtime.campaign_state.current_world_node_id == &"debug_village" and runtime.has_pending_travel(), "Automatically starts second leg")
	var pending := runtime.pending_travel
	if pending.has_unresolved_event():
		check(not runtime.advance_pending_travel_progress(1.0), "Cannot skip event")
		check(runtime.advance_pending_travel_to_next_stop(), "Reach event")
		check(pending.has_reached_event(), "Event pauses trip")
		check(runtime.resolve_pending_travel_event(), "Resolve event")
	check(runtime.advance_pending_travel_to_next_stop(), "Finish itinerary")
	check(runtime.campaign_state.current_world_node_id == &"debug_city" and not runtime.has_pending_travel(), "Arrive at chosen destination")
	var expected := minutes + service.get_travel_minutes(world, &"debug_village", &"debug_city")
	var final_time := runtime.campaign_state.current_day * 1440 + runtime.campaign_state.current_minute_of_day
	check(final_time - initial == expected, "No double charge at animation completion")
	runtime.free()
	print("TRAVEL SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
