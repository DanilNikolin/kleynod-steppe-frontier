extends SceneTree


var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
	else:
		print("OK: ", message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var runtime := CampaignRuntimeService.new()
	check(runtime.start_new_campaign(), "Start campaign")
	var campaign := runtime.campaign_definition
	var state := runtime.campaign_state
	var settlement := campaign.home_settlement_definition
	var zone_def := settlement.get_zone(&"residential_yard")
	var building_def := zone_def.get_building(&"temporary_party_shelter")
	check(building_def != null, "Found temporary_party_shelter definition")

	# Required prerequisite: primitive_campfire unlocks primitive_camp_established
	check(runtime.construct_home_settlement_building(&"trade_yard", &"primitive_campfire"), "Build campfire prerequisite")
	check(runtime.advance_time(120), "Campfire finishes")

	state.materials = 10
	var initial_gold := state.inventory_state.gold
	var initial_materials := state.materials
	var before_day := state.current_day
	var before_minute := state.current_minute_of_day
	var before_time := before_day * 1440 + before_minute

	# Step 1: Start construction
	check(runtime.construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter"), "Start party shelter construction")

	# Check A: current campaign time == before_time
	var current_time := state.current_day * 1440 + state.current_minute_of_day
	check(current_time == before_time, "Campaign time did not advance on build start")

	# Check B: Gold / Materials deducted immediately
	check(state.inventory_state.gold == initial_gold - building_def.construction_gold_cost, "Gold deducted immediately")
	check(state.materials == initial_materials - building_def.construction_material_cost, "Materials deducted immediately")

	# Check C & D: zone.building_id still empty, has_pending_construction is true
	var zone_state := state.home_settlement_state.get_zone(&"residential_yard")
	check(zone_state.building_id == &"", "Building id is still empty while constructing")
	check(zone_state.building_level == 0, "Building level is still 0 while constructing")
	check(zone_state.has_pending_construction(), "Zone has pending construction")

	# Check E & F: pending_started_at and pending_completes_at
	check(zone_state.pending_started_at == before_time, "pending_started_at matches before_time")
	check(zone_state.pending_completes_at == before_time + building_def.construction_minutes, "pending_completes_at matches deadline")

	# Check: Cannot start second construction on same zone
	check(not runtime.can_construct_home_settlement_building(&"residential_yard", &"temporary_party_shelter"), "Cannot start second construction while pending")

	# Step 2: Visual check in LOCAL_LOCATION panel before completion (CONSTRUCTING state)
	var live := root.get_node("CampaignRuntime") as CampaignRuntimeService
	live.campaign_definition = campaign
	live.campaign_state = state
	var sandbox = load("res://scenes/campaign/campaign_sandbox.gd").new()
	root.add_child(sandbox)
	sandbox._show_view(sandbox.View.LOCAL_LOCATION)
	var panel := sandbox._shell._immersive_content_host.get_child(0) as CampaignLocalLocationPanel
	check(panel != null, "Local location panel created")

	var party_shelter_anchor := panel._canvas._anchors_by_interaction_id.get(&"home_zone_party_shelter") as LocalBuildSiteView
	check(party_shelter_anchor != null, "Found party shelter anchor")
	var buildable: LocalBuildableVisual = party_shelter_anchor.get_buildable_visual()
	check(buildable != null, "Found LocalBuildableVisual under party shelter anchor")
	var construction_node := buildable.get_node_or_null("Construction") as CanvasItem
	var stage30_node := buildable.get_node_or_null("Construction/Stage30") as CanvasItem
	var built_node := buildable.get_node_or_null("Built") as CanvasItem
	var flag_node := buildable.get_node_or_null("Built/Visual/Flag") as AnimatedSprite2D

	check(construction_node != null and construction_node.visible == true, "Construction is visible during construction")
	check(stage30_node != null and stage30_node.visible == true, "Stage30 is visible during construction")
	check(built_node != null and built_node.visible == false, "Built is hidden during construction")

	# Check CommonShelterSite uses canonical LocalBuildableVisual architecture
	var common_shelter_anchor := panel._canvas._anchors_by_interaction_id.get(&"home_zone_common_shelter") as LocalBuildSiteView
	check(common_shelter_anchor != null, "Found common shelter anchor")
	var common_buildable: LocalBuildableVisual = common_shelter_anchor.get_buildable_visual()
	check(common_buildable != null, "CommonShelterSite has LocalBuildableVisual")
	check(common_buildable.get_node_or_null("Construction/Stage30") != null, "CommonShelter has Construction/Stage30")
	check(common_buildable.get_node_or_null("Built/Visual/Shadow") != null, "CommonShelter has Built/Visual/Shadow")
	check(common_buildable.get_node_or_null("Built/Visual/Base") != null, "CommonShelter has Built/Visual/Base")
	# Check 3-state switching on CommonShelterSite
	common_shelter_anchor.set_build_state(LocalBuildSiteView.BuildVisualState.EMPTY)
	check(common_buildable.get_node_or_null("Construction").visible == false, "CommonShelter EMPTY: Construction hidden")
	check(common_buildable.get_node_or_null("Built").visible == false, "CommonShelter EMPTY: Built hidden")
	common_shelter_anchor.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.0)
	check(common_buildable.get_node_or_null("Construction").visible == true, "CommonShelter CONSTRUCTING: Construction visible")
	check(common_buildable.get_node_or_null("Construction/Stage30").visible == true, "CommonShelter CONSTRUCTING: Stage30 active")
	check(common_buildable.get_node_or_null("Built").visible == false, "CommonShelter CONSTRUCTING: Built hidden")
	common_shelter_anchor.set_build_state(LocalBuildSiteView.BuildVisualState.BUILT)
	check(common_buildable.get_node_or_null("Construction").visible == false, "CommonShelter BUILT: Construction hidden")
	check(common_buildable.get_node_or_null("Built").visible == true, "CommonShelter BUILT: Built visible")
	# Restore EMPTY state
	common_shelter_anchor.set_build_state(LocalBuildSiteView.BuildVisualState.EMPTY)

	# Step 3: Advance time partially (construction_minutes - 1)
	var partial_minutes := building_def.construction_minutes - 1
	check(runtime.advance_time(partial_minutes), "Advance time partially")
	check(zone_state.building_id == &"", "Zone still empty before deadline")
	check(zone_state.has_pending_construction(), "Pending construction still active before deadline")

	# Refresh panel during mid-construction to verify progress update maintains CONSTRUCTING state
	panel._state = state
	panel._settlement_state = state.home_settlement_state
	panel.refresh_state()
	check(construction_node.visible == true, "Construction remains visible mid-construction")
	check(built_node.visible == false, "Built remains hidden mid-construction")

	# Step 4: Save and load in the middle of construction
	var path := "user://home_construction_async_smoke_%d.json" % Time.get_ticks_usec()
	var saves := CampaignSaveService.new(path)
	check(saves.save_campaign(state).is_successful, "Save campaign mid-construction")

	var loaded := saves.load_campaign(campaign)
	check(loaded.is_successful, "Load campaign mid-construction: " + loaded.message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var loaded_state := loaded.campaign_state
	var loaded_zone := loaded_state.home_settlement_state.get_zone(&"residential_yard")
	check(loaded_zone.has_pending_construction(), "Loaded zone has pending construction")
	check(loaded_zone.pending_started_at == before_time, "Loaded pending_started_at preserved")
	check(loaded_zone.pending_completes_at == before_time + building_def.construction_minutes, "Loaded pending_completes_at preserved")
	check(loaded_zone.building_id == &"", "Loaded building_id still empty")

	# Step 5: Advance the remaining 1 minute to trigger completion
	runtime.campaign_state = loaded_state
	state = loaded_state
	zone_state = loaded_zone
	check(runtime.advance_time(1), "Advance final 1 minute to complete deadline")

	check(zone_state.building_id == &"temporary_party_shelter", "Building completed: building_id set")
	check(zone_state.building_level == 1, "Building completed: building_level is 1")
	check(not zone_state.has_pending_construction(), "Pending construction cleared after completion")

	# Step 6: Visual check after completion (BUILT state)
	# Update panel state reference and refresh
	panel._state = state
	panel._settlement_state = state.home_settlement_state
	panel.refresh_state()
	check(construction_node.visible == false, "Construction is hidden after completion")
	check(built_node.visible == true, "Built is visible after completion")
	check(flag_node != null and flag_node.is_playing() and flag_node.animation == &"idle", "Flag continues playing idle animation when built")

	# Step 7: Test Presentation systems (ConstructionAmbient & ConstructionTransitionFX)
	var party_ambient: ConstructionAmbient = buildable.ambient
	var party_transition: ConstructionTransitionFX = buildable.transition_fx
	check(party_ambient != null, "Party shelter has ConstructionAmbient")
	check(party_transition != null, "Party shelter has ConstructionTransitionFX")

	# 7.1 Lifecycle with PartyShelter
	# Current state is BUILT: ambient must be inactive
	check(not party_ambient.is_active(), "Ambient is inactive in BUILT state")

	# First state sync: new visual instance directly receiving BUILT should NOT trigger transition
	var test_visual: LocalBuildableVisual = load("res://scenes/campaign/local_location/objects/party_shelter.tscn").instantiate()
	root.add_child(test_visual)
	var fx_before: int = test_visual.transition_fx.get_transition_count()
	test_visual.set_build_state(LocalBuildSiteView.BuildVisualState.BUILT)
	check(test_visual.transition_fx.get_transition_count() == fx_before, "First state sync (BUILT) does NOT trigger TransitionFX")
	check(not test_visual.ambient.is_active(), "First state sync (BUILT) leaves ambient inactive")

	# First state sync directly receiving CONSTRUCTING should NOT trigger transition, but ambient is active
	var test_visual2: LocalBuildableVisual = load("res://scenes/campaign/local_location/objects/party_shelter.tscn").instantiate()
	root.add_child(test_visual2)
	fx_before = test_visual2.transition_fx.get_transition_count()
	test_visual2.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.2)
	check(test_visual2.transition_fx.get_transition_count() == fx_before, "First state sync (CONSTRUCTING) does NOT trigger TransitionFX")
	check(test_visual2.ambient.is_active(), "First state sync (CONSTRUCTING) activates ambient")

	# 7.2 Controlled progression on fresh instance: EMPTY -> CONSTRUCTING -> same CONSTRUCTING -> Stage change -> BUILT
	var fresh: LocalBuildableVisual = load("res://scenes/campaign/local_location/objects/party_shelter.tscn").instantiate()
	root.add_child(fresh)
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.EMPTY)
	check(fresh.transition_fx.get_transition_count() == 0, "Initial EMPTY sync has 0 transitions")
	check(not fresh.ambient.is_active(), "EMPTY has ambient inactive")

	# EMPTY -> CONSTRUCTING: should trigger exactly 1 transition and activate ambient immediately
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.0)
	check(fresh.transition_fx.get_transition_count() == 1, "EMPTY -> CONSTRUCTING triggers 1 TransitionFX")
	check(fresh.ambient.is_active(), "EMPTY -> CONSTRUCTING activates ambient")
	check(fresh.get_node("Construction/Stage30").visible == true, "Stage30 is immediately visible")

	# Repeat set_build_state with same CONSTRUCTING progress: no new transition
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.1)
	check(fresh.transition_fx.get_transition_count() == 1, "CONSTRUCTING with same stage does NOT trigger TransitionFX")

	# Add dynamic Stage50 with start_progress 0.5 to verify stage change detection
	var stage50 := Sprite2D.new()
	stage50.name = "Stage50"
	stage50.set_script(load("res://presentation/campaign/local_location/local_construction_stage_visual.gd"))
	stage50.set("start_progress", 0.5)
	fresh.get_node("Construction").add_child(stage50)

	# Progress 0.49: still Stage30, no transition
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.49)
	check(fresh.transition_fx.get_transition_count() == 1, "Progress 0.49 stays on Stage30 (no transition)")
	check(stage50.visible == false, "Stage50 hidden at progress 0.49")

	# Progress 0.50: stage changes to Stage50, triggers exactly 1 transition
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.50)
	check(fresh.transition_fx.get_transition_count() == 2, "Stage30 -> Stage50 triggers 1 TransitionFX (total 2)")
	check(stage50.visible == true, "Stage50 visible at progress 0.50")
	check(fresh.get_node("Construction/Stage30").visible == false, "Stage30 hidden at progress 0.50")

	# CONSTRUCTING -> BUILT: triggers exactly 1 transition and disables ambient
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.BUILT)
	check(fresh.transition_fx.get_transition_count() == 3, "CONSTRUCTING -> BUILT triggers 1 TransitionFX (total 3)")
	check(not fresh.ambient.is_active(), "Ambient becomes inactive when BUILT")
	check(fresh.get_node("Built").visible == true, "Built is immediately visible")
	check(fresh.get_node("Construction").visible == false, "Construction is immediately hidden")

	# Step 8: Test DetailAnimation (IntermittentDetailAnimation with AnimatedSprite2D)
	var stage30_node_ref := fresh.get_node("Construction/Stage30")
	var detail_ctrl := stage30_node_ref.get_node_or_null("DetailAnimation/IntermittentController") as IntermittentDetailAnimation
	var stage30_visual_sprite := stage30_node_ref.get_node_or_null("DetailAnimation/Visual") as AnimatedSprite2D
	check(detail_ctrl != null, "Found IntermittentDetailAnimation in Stage30")
	check(stage30_visual_sprite != null, "Found AnimatedSprite2D Visual in Stage30/DetailAnimation")

	# 8.1 In BUILT state: Stage30 detail controller must be inactive
	check(not detail_ctrl.is_active(), "DetailAnimation is inactive when BUILT")

	# 8.2 In EMPTY state: Detail controller must be inactive
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.EMPTY)
	check(not detail_ctrl.is_active(), "DetailAnimation is inactive when EMPTY")

	# 8.3 In CONSTRUCTING state on Stage30 (progress 0.0): Detail controller becomes active
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.0)
	check(detail_ctrl.is_active(), "DetailAnimation is active when Stage30 is active in CONSTRUCTING")

	# 8.4 Setup mock animated sprite with 2 frames on Stage50 to test playback, stop, and transition
	var detail50_node := Node2D.new()
	detail50_node.name = "DetailAnimation"

	var sprite50 := AnimatedSprite2D.new()
	sprite50.name = "Visual"
	var frames50 := SpriteFrames.new()
	frames50.add_animation(&"idle")
	frames50.set_animation_loop(&"idle", false)
	# create 2 dummy 1x1 image textures for testing frames
	var img1 := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex1 := ImageTexture.create_from_image(img1)
	var img2 := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex2 := ImageTexture.create_from_image(img2)
	frames50.add_frame(&"idle", tex1)
	frames50.add_frame(&"idle", tex2)
	sprite50.sprite_frames = frames50
	detail50_node.add_child(sprite50)

	var ctrl50 := IntermittentDetailAnimation.new()
	ctrl50.name = "IntermittentController"
	ctrl50.animated_sprite_path = NodePath("../Visual")
	detail50_node.add_child(ctrl50)

	var ctrl50_extra := IntermittentDetailAnimation.new()
	ctrl50_extra.name = "ExtraController"
	ctrl50_extra.animated_sprite_path = NodePath("../Visual")
	detail50_node.add_child(ctrl50_extra)
	stage50.add_child(detail50_node)

	check(not ctrl50.is_active(), "Stage50 controller initially inactive")
	check(not ctrl50_extra.is_active(), "Stage50 extra controller initially inactive")

	# Switch to progress 0.50 (Stage50 becomes active):
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.50)
	check(not detail_ctrl.is_active(), "Stage30 controller becomes inactive when stage changes to Stage50")
	check(ctrl50.is_active(), "Stage50 controller becomes active")
	check(ctrl50_extra.is_active(), "Stage50 extra controller also becomes active (multiple controllers supported)")

	# Trigger timer timeout manually to verify play
	var ctrl50_timer := ctrl50.get_node("Timer") as Timer
	check(ctrl50_timer != null and not ctrl50_timer.is_stopped(), "ctrl50 timer is running for random pause")
	ctrl50._on_timer_timeout()
	check(sprite50.is_playing(), "sprite50 started playing after timer timeout")

	# Set frame to 1 to simulate intermediate animation frame, then finish animation
	sprite50.frame = 1
	ctrl50._on_animation_finished()
	check(not sprite50.is_playing(), "sprite50 stopped after animation_finished")
	check(sprite50.frame == 0, "sprite50 reset to frame 0 after animation_finished")
	check(not ctrl50_timer.is_stopped(), "ctrl50 timer scheduled next pause after animation_finished")

	# 8.5 Switch from CONSTRUCTING to BUILT: all active stage controllers become inactive and reset
	sprite50.frame = 1
	fresh.set_build_state(LocalBuildSiteView.BuildVisualState.BUILT)
	check(not ctrl50.is_active(), "Stage50 controller becomes inactive on BUILT")
	check(not ctrl50_extra.is_active(), "Stage50 extra controller becomes inactive on BUILT")
	check(sprite50.frame == 0, "sprite50 frame reset to 0 when controller deactivated on BUILT")
	check(not sprite50.is_playing(), "sprite50 stopped playing on BUILT")

	# 8.6 Multi-animation weighted random tests
	var multi_node := Node2D.new()
	var multi_sprite := AnimatedSprite2D.new()
	multi_sprite.name = "Visual"
	var multi_frames := SpriteFrames.new()
	multi_frames.add_animation(&"idle")
	multi_frames.set_animation_loop(&"idle", false)
	multi_frames.add_frame(&"idle", tex1)
	multi_frames.add_animation(&"idle_2")
	multi_frames.set_animation_loop(&"idle_2", false)
	multi_frames.add_frame(&"idle_2", tex1)
	multi_frames.add_animation(&"idle_3")
	multi_frames.set_animation_loop(&"idle_3", false)
	multi_frames.add_frame(&"idle_3", tex1)
	# Add empty animation with 0 frames to test filtering
	multi_frames.add_animation(&"empty_anim")
	multi_frames.set_animation_loop(&"empty_anim", false)

	multi_sprite.sprite_frames = multi_frames
	multi_node.add_child(multi_sprite)

	var multi_ctrl := IntermittentDetailAnimation.new()
	multi_ctrl.name = "MultiController"
	multi_ctrl.animated_sprite_path = NodePath("../Visual")
	multi_ctrl.animation_names = [&"idle", &"idle_2", &"idle_3", &"empty_anim", &"non_existent"]
	# Weights with mismatched length and negative values to test safety
	multi_ctrl.animation_weights = PackedFloat32Array([1.0, 3.0, 2.0])
	multi_node.add_child(multi_ctrl)
	root.add_child(multi_node)

	# Test choice logic
	var chosen_counts: Dictionary = {&"idle": 0, &"idle_2": 0, &"idle_3": 0}
	for i in range(100):
		var anim_pick := multi_ctrl._choose_animation(multi_sprite)
		check(anim_pick in chosen_counts, "Chosen animation must be one of the valid animations with frames")
		chosen_counts[anim_pick] += 1

	check(chosen_counts[&"idle_2"] > 0, "Weighted picker chose idle_2")
	check(chosen_counts[&"idle_3"] > 0, "Weighted picker chose idle_3")
	check(chosen_counts[&"idle"] > 0, "Weighted picker chose idle")
	# Check idle_2 is more frequent than idle
	check(chosen_counts[&"idle_2"] > chosen_counts[&"idle"], "idle_2 weight (3.0) resulted in higher frequency than idle (1.0)")

	# Test playback of chosen animation and reset on finish
	multi_ctrl.set_active(true)
	multi_ctrl._on_timer_timeout()
	check(multi_sprite.is_playing(), "multi_sprite playing chosen animation")
	var active_anim := multi_ctrl._current_animation
	check(not active_anim.is_empty(), "_current_animation is set")
	check(multi_sprite.animation == active_anim, "Sprite animation matches _current_animation")

	multi_sprite.frame = 1
	multi_ctrl._on_animation_finished()
	check(not multi_sprite.is_playing(), "multi_sprite stopped on animation_finished")
	check(multi_sprite.animation == active_anim, "multi_sprite animation preserved as the one played")
	check(multi_sprite.frame == 0, "multi_sprite frame reset to 0 after finished")

	multi_ctrl.set_active(false)
	multi_node.free()

	# 8.7 Test continuous base_idle loop and loop-to-event transition
	var base_node := Node2D.new()
	var base_sprite := AnimatedSprite2D.new()
	base_sprite.name = "Visual"
	var base_frames := SpriteFrames.new()
	base_frames.add_animation(&"base_idle")
	base_frames.set_animation_loop(&"base_idle", true)
	base_frames.add_frame(&"base_idle", tex1)
	base_frames.add_frame(&"base_idle", tex2)

	base_frames.add_animation(&"burst")
	base_frames.set_animation_loop(&"burst", false)
	base_frames.add_frame(&"burst", tex1)
	base_frames.add_frame(&"burst", tex2)

	base_sprite.sprite_frames = base_frames
	base_node.add_child(base_sprite)

	var base_ctrl := IntermittentDetailAnimation.new()
	base_ctrl.name = "BaseController"
	base_ctrl.animated_sprite_path = NodePath("../Visual")
	base_ctrl.base_animation_name = &"base_idle"
	base_ctrl.animation_name = &"burst"
	base_node.add_child(base_ctrl)
	root.add_child(base_node)

	# When activated, base_idle starts playing continuously
	base_ctrl.set_active(true)
	check(base_sprite.is_playing(), "base_sprite playing on activate")
	check(base_sprite.animation == &"base_idle", "base_sprite starts with base_idle")

	# Timer fires: must set pending_event and NOT interrupt immediately
	base_ctrl._on_timer_timeout()
	check(base_ctrl._pending_event, "pending_event is set on timer timeout")
	check(base_sprite.animation == &"base_idle", "base_sprite still playing base_idle until loop finishes")

	# When loop completes, burst triggers
	base_ctrl._on_animation_looped()
	check(not base_ctrl._pending_event, "pending_event cleared after loop completion")
	check(base_sprite.animation == &"burst", "base_sprite switched to burst after loop finished")
	check(base_ctrl._is_playing_event, "controller marked as playing event")

	# When burst finishes, smoothly transitions back to base_idle
	base_ctrl._on_animation_finished()
	check(base_sprite.is_playing(), "base_sprite resumed playing after event finished")
	check(base_sprite.animation == &"base_idle", "base_sprite returned to base_idle after event finished")

	base_ctrl.set_active(false)
	check(not base_sprite.is_playing(), "base_sprite stopped on set_active(false)")
	check(base_sprite.animation == &"base_idle", "base_sprite reset to base_idle on stop")
	check(base_sprite.frame == 0, "base_sprite frame reset to 0 on stop")
	base_node.free()

	# 7.3 Optionality check: Visual without Ambient, TransitionFX or DetailAnimation works without errors
	var plain_buildable := LocalBuildableVisual.new()
	root.add_child(plain_buildable)
	var plain_construction := Node2D.new()
	plain_construction.name = "Construction"
	plain_buildable.add_child(plain_construction)
	var plain_built := Node2D.new()
	plain_built.name = "Built"
	plain_buildable.add_child(plain_built)
	plain_buildable.set_build_state(LocalBuildSiteView.BuildVisualState.EMPTY)
	plain_buildable.set_build_state(LocalBuildSiteView.BuildVisualState.CONSTRUCTING, 0.0)
	plain_buildable.set_build_state(LocalBuildSiteView.BuildVisualState.BUILT)
	# Step 9: Test LocalTimeOfDayVisual (Time-of-day lighting and sky cycle)
	var tod := LocalTimeOfDayVisual.new()
	var tod_modulate := CanvasModulate.new()
	var tod_sky_rect := TextureRect.new()
	var tod_gradient := Gradient.new()
	var tod_tex := GradientTexture2D.new()
	tod_tex.gradient = tod_gradient
	tod_sky_rect.texture = tod_tex

	var tod_far_clouds := Node2D.new()
	var tod_near_clouds := Node2D.new()

	var tod_horizon_overlay := Node2D.new()
	tod_horizon_overlay.position = Vector2(100, 200)

	tod.world_modulate = tod_modulate
	tod.sky_gradient_rect = tod_sky_rect
	tod.far_clouds_root = tod_far_clouds
	tod.near_clouds_root = tod_near_clouds
	tod.horizon_overlay = tod_horizon_overlay
	root.add_child(tod_modulate)
	root.add_child(tod_sky_rect)
	root.add_child(tod_far_clouds)
	root.add_child(tod_near_clouds)
	root.add_child(tod_horizon_overlay)
	root.add_child(tod)
	# 9.0 Test initial state after _ready() before any set_time_of_day: must be hidden with alpha 0
	check(tod_horizon_overlay.modulate.a <= 0.001 and not tod_horizon_overlay.visible, "_ready initializes horizon overlay as hidden with 0 alpha")

	# 9.1 Test Day (12:00 = 720 minutes) vs Night (00:00 = 0 minutes) profiles
	tod.set_time_of_day(720, true) # Noon
	check(tod_modulate.color.is_equal_approx(Color(1.0, 1.0, 1.0, 1.0)), "12:00 noon world modulate is neutral white (1, 1, 1)")
	check(tod_far_clouds.modulate.is_equal_approx(Color(1.0, 1.0, 1.0, 1.0)), "12:00 noon far clouds modulate is white (1, 1, 1)")
	check(tod_near_clouds.modulate.is_equal_approx(Color(1.0, 1.0, 1.0, 1.0)), "12:00 noon near clouds modulate is white (1, 1, 1)")
	check(tod_horizon_overlay.modulate.a <= 0.001 or not tod_horizon_overlay.visible, "12:00 noon horizon overlay is invisible / alpha 0")

	tod.set_time_of_day(0, true) # Midnight
	check(tod_modulate.color.r < 0.6 and tod_modulate.color.b > tod_modulate.color.r, "00:00 midnight world modulate is cool blueish/slate tint")
	check(tod_far_clouds.modulate.r < 0.85 and tod_far_clouds.modulate.b > tod_far_clouds.modulate.r, "00:00 midnight far clouds has cool darker tint")
	check(tod_near_clouds.modulate.r < tod_far_clouds.modulate.r, "00:00 midnight near clouds is darker than far clouds")
	check(tod_horizon_overlay.visible and tod_horizon_overlay.modulate.a >= 0.99, "00:00 midnight horizon overlay is visible with 1.0 scale alpha")

	# 9.2 Test interpolation between keys (e.g. 06:00 = 360 min sunrise, warm/rose tint)
	tod.set_time_of_day(360, true)
	check(tod_modulate.color.r > tod_modulate.color.b, "06:00 sunrise has warmer red than blue tint")

	# 9.3 Test immediate sync on first call vs smooth transition flag
	var initial_minute := state.current_minute_of_day
	tod.set_time_of_day(720, true)
	check(tod.get_current_minute_of_day() == 720, "set_time_of_day updates current minute")
	check(state.current_minute_of_day == initial_minute, "Visual time update does not mutate campaign state time")

	# 9.4 Manual movement of overlay does not affect time logic
	tod_horizon_overlay.position = Vector2(500, 600)
	tod_horizon_overlay.scale = Vector2(1.5, 1.5)
	tod.set_time_of_day(0, true)
	check(tod_horizon_overlay.visible and tod_horizon_overlay.modulate.a >= 0.99, "Horizon overlay works after manual position/scale change")

	# 9.5 Test CampaignLocalLocationCanvas set_time_of_day safe invocation
	var canvas_test := CampaignLocalLocationCanvas.new()
	root.add_child(canvas_test)
	# Safe call without world_root
	canvas_test.set_time_of_day(360, true)
	canvas_test.free()

	tod.free()
	tod_modulate.free()
	tod_sky_rect.free()
	tod_far_clouds.free()
	tod_near_clouds.free()
	tod_horizon_overlay.free()

	test_visual.free()
	test_visual2.free()
	fresh.free()
	plain_buildable.free()

	sandbox.free()
	runtime.free()

	if failures == 0:
		print("SMOKE GREEN: async home settlement construction, time preservation, save/load, deadline completion and 3-state visuals.")
		quit(0)
	else:
		print("SMOKE FAILED: %d errors" % failures)
		quit(1)
