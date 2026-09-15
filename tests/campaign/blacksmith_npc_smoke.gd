extends SceneTree

func _init() -> void:
	call_deferred("run")

func run() -> void:
	print("--- Running Blacksmith NPC Verification ---")
	var stage_scene := load("res://scenes/campaign/local_location/home_visual_stage.tscn")
	assert(stage_scene != null, "home_visual_stage.tscn must load")
	var stage: Node2D = stage_scene.instantiate()
	root.add_child(stage)

	var blacksmith_npc := stage.get_node_or_null("WorldContent/NPCs/BlacksmithNpc") as LocalResidentNpcVisual
	assert(blacksmith_npc != null, "BlacksmithNpc must exist in stage")
	assert(blacksmith_npc.resident_id == &"resident_blacksmith_ostap", "resident_id must be resident_blacksmith_ostap")

	var visual := blacksmith_npc.get_node_or_null("Visual") as Node2D
	assert(visual != null, "Visual node must exist")
	var body := visual.get_node_or_null("Body") as AnimatedSprite2D
	assert(body != null, "Body AnimatedSprite2D must exist")
	assert(body.sprite_frames != null, "SpriteFrames must exist")
	assert(body.sprite_frames.has_animation(&"idle"), "idle animation must exist")
	assert(body.sprite_frames.has_animation(&"work"), "work animation must exist")
	assert(body.sprite_frames.get_animation_loop(&"idle") == true, "idle must loop")
	assert(body.sprite_frames.get_animation_loop(&"work") == false, "work must not loop")

	var intermittent := body.get_node_or_null("IntermittentController") as IntermittentDetailAnimation
	assert(intermittent != null, "IntermittentController must exist")
	assert(intermittent.base_animation_name == &"idle", "base_animation_name must be idle")
	assert(intermittent.animation_names == [&"work"], "animation_names must be [work]")
	assert(intermittent.continuous_event_when_base_empty == true, "continuous_event_when_base_empty must be true")

	# Test continuous work triggering when base idle is empty
	assert(intermittent._should_continuously_play_event(body) == true, "Should continuously play work when idle is empty")

	# Test automatic fallback when idle frames are added
	body.sprite_frames.add_frame(&"idle", GradientTexture2D.new())
	assert(intermittent._has_base_idle(body) == true, "Should detect base idle when frame exists")
	assert(intermittent._should_continuously_play_event(body) == false, "Should not continuously play work when idle has frames")
	body.sprite_frames.clear(&"idle")
	assert(intermittent._should_continuously_play_event(body) == true, "Should return to continuous work when idle frames removed")

	const BlacksmithWorkLightControllerScript = preload("res://presentation/campaign/local_location/blacksmith_work_light_controller.gd")
	var light_anchor = blacksmith_npc.get_node_or_null("WorkLightAnchor")
	assert(light_anchor != null, "WorkLightAnchor with BlacksmithWorkLightController must exist")
	assert(light_anchor.get_script() == BlacksmithWorkLightControllerScript, "Must have blacksmith_work_light_controller.gd script")
	var work_light := light_anchor.get_node_or_null("WorkLight") as PointLight2D
	assert(work_light != null, "WorkLight PointLight2D must exist")
	assert(work_light.enabled == false, "WorkLight must be disabled initially")

	var click_area := blacksmith_npc.get_node_or_null("ClickArea") as Button
	assert(click_area != null, "ClickArea Button must exist")
	assert(click_area.flat == true, "ClickArea must be flat")

	const BlacksmithNpcVisualScript = preload("res://presentation/campaign/local_location/blacksmith_npc_visual.gd")
	assert(blacksmith_npc.get_script() == BlacksmithNpcVisualScript, "BlacksmithNpc must use BlacksmithNpcVisual script")
	assert(body.sprite_frames.has_animation(&"Sitting"), "Sitting animation must exist")
	assert(body.sprite_frames.get_animation_loop(&"Sitting") == true, "Sitting must loop")

	# Test presence
	blacksmith_npc.set_present(false)
	assert(blacksmith_npc.visible == false, "NPC must be hidden when absent")

	blacksmith_npc.set_present(true)
	assert(blacksmith_npc.visible == true, "NPC must be visible when present")

	# Test waiting for workplace (Sitting during construction)
	blacksmith_npc.set_waiting_for_workplace(true)
	assert(intermittent.is_active() == false, "IntermittentController must be disabled during Sitting")
	assert(body.animation == &"Sitting", "Body animation must be Sitting when waiting for workplace")
	assert(body.is_playing() == true, "Body must be playing Sitting")

	# WorkLight must remain disabled during Sitting
	light_anchor._process(0.016)
	assert(work_light.enabled == false, "WorkLight must be disabled during Sitting")

	# Resuming normal mode after construction completes
	blacksmith_npc.set_waiting_for_workplace(false)
	assert(intermittent.is_active() == true, "IntermittentController must reactivate after construction")

	# Test light controller logic on idle vs work
	body.animation = &"idle"
	body.play()
	light_anchor._process(0.016)
	assert(work_light.enabled == false, "WorkLight must be disabled when animation is idle")

	body.animation = &"work"
	body.play()
	light_anchor._process(0.016)
	assert(work_light.enabled == true, "WorkLight must be enabled when animation is work")
	assert(work_light.energy > 0.3, "WorkLight energy must be around base_energy + flicker")

	# Check Forge scene
	var forge_scene := load("res://scenes/campaign/local_location/objects/forge.tscn")
	assert(forge_scene != null, "forge.tscn must load")
	var forge: Node2D = forge_scene.instantiate()
	root.add_child(forge)

	var furnace_anchor := forge.get_node_or_null("Built/Visual/FurnaceLightAnchor")
	assert(furnace_anchor != null, "FurnaceLightAnchor must exist under Built/Visual")
	const AmbientFlickerLightScript = preload("res://presentation/campaign/local_location/ambient_flicker_light.gd")
	assert(furnace_anchor.get_script() == AmbientFlickerLightScript, "Must have AmbientFlickerLight script")
	var furnace_light := furnace_anchor.get_node_or_null("FurnaceLight") as PointLight2D
	assert(furnace_light != null, "FurnaceLight PointLight2D must exist")

	const LocalBuildSiteViewScript = preload("res://presentation/campaign/local_location/local_build_site_view.gd")
	forge.set_build_state(LocalBuildSiteViewScript.BuildVisualState.BUILT)
	furnace_anchor._process(0.016)
	assert(furnace_light.enabled == true, "Furnace light must be enabled when built visual is visible")
	assert(furnace_light.energy > 0.3, "Furnace light energy must be around base_energy")

	print("BLACKSMITH VERIFICATION SUCCESSFUL")
	quit(0)
