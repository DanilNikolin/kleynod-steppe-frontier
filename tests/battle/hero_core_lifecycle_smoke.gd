extends SceneTree

var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func make_combatant() -> CombatantState:
	var hero := load("res://content/heroes/bayda/bayda_hero.tres") as HeroDefinition
	return CombatantState.new(&"bayda_lifecycle", hero.base_combatant_definition,
		&"team_player", CombatantLoadoutDefinition.new(), Vector2i.ZERO, hero.core_module)


func lifetime_probes() -> Array[WeakRef]:
	var actor := make_combatant()
	var core := actor.hero_core_runtime_state as BaydaCoreRuntimeState
	check(core.owner == actor, "Live Bayda owner resolves through the property")
	var copy := actor.create_runtime_copy()
	var copy_core := copy.hero_core_runtime_state as BaydaCoreRuntimeState
	check(copy_core != core and copy_core.owner == copy, "AI-style copy owns its own core")
	check(core.owner == actor, "Copy does not rebind the original owner")
	check(copy_core.base_max_stamina == core.base_max_stamina
		and copy_core.unbroken_available == core.unbroken_available,
		"Runtime copy preserves Bayda state")
	# All strong local references leave scope; probes must not keep either pair alive.
	return [weakref(actor), weakref(core), weakref(copy), weakref(copy_core)]


func run() -> void:
	var probes := lifetime_probes()
	await process_frame
	for probe in probes:
		check(probe.get_ref() == null, "Combatant/core pair is actually released")
	var actor := make_combatant()
	var core := actor.hero_core_runtime_state
	var actor_probe: WeakRef = weakref(actor)
	actor = null
	check(actor_probe.get_ref() == null, "Retaining the core does not retain its combatant")
	check(core.owner == null, "Expired owner safely resolves to null")
	core.owner = null
	check(core.owner == null, "Explicit null assignment remains valid")
	var replacement := make_combatant()
	core.owner = replacement
	check(core.owner == replacement, "Owner can be reassigned")
	var base_core := HeroCoreRuntimeState.new()
	base_core.initialize(null, replacement)
	var base_copy := base_core.create_runtime_copy(replacement)
	check(base_core.owner == replacement and base_copy.owner == replacement,
		"Base initialize and runtime copy preserve the owner API")
	replacement = null
	check(core.owner == null and base_core.owner == null and base_copy.owner == null,
		"All core variants hold weak owner references")
	check(base_core.get_effect_validation_failure(BattleEffect.new())
		== HeroCoreRuntimeState.FAILURE_INVALID_CORE_OWNER, "Expired owner fails validation safely")
	print("HERO CORE LIFECYCLE SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
