# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/ai/basic_melee_ai_controller.gd', 'core/battle/ai/basic_melee_ai_turn_plan.gd', 'presentation/battle/ai/basic_melee_ai_turn_runner.gd', 'presentation/battle/ai/basic_melee_ai_turn_outcome.gd', 'core/battle/session/battle_session.gd', 'core/battle/combatants/combatant_state.gd', 'core/battle/loadouts/combatant_loadout_definition.gd', 'core/battle/turns/battle_turn_controller.gd', 'scenes/debug/controllers/battle_sandbox_interaction_controller.gd', 'scenes/debug/presentation/battle_debug_log_presenter.gd']`
- Allow addons: `False`
- Included files planned: `10`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_bandage.tres
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_fire_line.tres
│   │       ├── debug_full_cleanse.tres
│   │       ├── debug_full_dispel.tres
│   │       ├── debug_guaranteed_critical.tres
│   │       ├── debug_guard_stance.tres
│   │       ├── debug_hamstring.tres
│   │       ├── debug_place_fire_surface.tres
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_rending_cut.tres
│   │       ├── debug_sabre_slash.tres
│   │       ├── debug_shield_bash.tres
│   │       ├── debug_spirit_mend.tres
│   │       ├── debug_stunning_blow.tres
│   │       ├── debug_swap_positions.tres
│   │       ├── debug_sweeping_slash.tres
│   │       └── debug_teleport.tres
│   ├── combatants
│   │   └── debug
│   │       ├── debug_protected_shaman.tres
│   │       ├── debug_steppe_raider.tres
│   │       └── debug_wooden_wall.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   ├── statuses
│   │   └── debug
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_bleeding.tres
│   │       ├── debug_cracked_defense.tres
│   │       ├── debug_immobilized.tres
│   │       ├── debug_regeneration.tres
│   │       └── debug_stunned.tres
│   └── surfaces
│       └── debug
│           └── debug_fire_surface.tres
├── core
│   └── battle
│       ├── abilities
│       │   └── ability_definition.gd
│       ├── actions
│       │   ├── battle_action_command.gd
│       │   ├── battle_action_result.gd
│       │   ├── battle_action_service.gd
│       │   └── battle_effect_result.gd
│       ├── ai
│       │   ├── basic_melee_ai_controller.gd
│       │   └── basic_melee_ai_turn_plan.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── apply_status_effect.gd
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   ├── effect_resolver.gd
│       │   ├── forced_movement_effect.gd
│       │   ├── grant_guard_effect.gd
│       │   ├── heal_effect.gd
│       │   ├── place_surface_effect.gd
│       │   ├── remove_status_effect.gd
│       │   ├── swap_positions_effect.gd
│       │   └── teleport_effect.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   ├── battle_surface_spawn_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_forced_movement_resolution.gd
│       │   ├── battle_movement_plan.gd
│       │   ├── battle_movement_service.gd
│       │   ├── battle_relocation_result.gd
│       │   ├── battle_relocation_service.gd
│       │   └── core
│       │       └── battle
│       │           └── movement
│       │               └── battle_forced_movement_service.gd
│       ├── previews
│       │   ├── battle_action_preview_result.gd
│       │   ├── battle_action_preview_service.gd
│       │   ├── battle_preview_combatant_state.gd
│       │   ├── battle_preview_grid_state.gd
│       │   ├── battle_surface_placement_preview.gd
│       │   └── battle_target_preview.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── restrictions
│       │   └── battle_action_restriction.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   ├── battle_status_instance.gd
│       │   ├── battle_status_periodic_processor.gd
│       │   ├── battle_status_periodic_trigger.gd
│       │   └── battle_status_periodic_trigger_result.gd
│       ├── surfaces
│       │   ├── battle_surface_effect_controller.gd
│       │   ├── battle_surface_effect_definition.gd
│       │   ├── battle_surface_effect_instance.gd
│       │   └── battle_surface_trigger_result.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   ├── battle
│   │   ├── abilities
│   │   │   ├── battle_ability_panel.gd
│   │   │   ├── battle_ability_panel.tscn
│   │   │   └── battle_ability_presentation_builder.gd
│   │   ├── actions
│   │   │   ├── battle_ability_presentation_profile.gd
│   │   │   ├── battle_action_outcome.gd
│   │   │   └── battle_action_runner.gd
│   │   ├── ai
│   │   │   ├── basic_melee_ai_turn_outcome.gd
│   │   │   └── basic_melee_ai_turn_runner.gd
│   │   ├── combatants
│   │   │   ├── battle_combatant_hover_panel.gd
│   │   │   ├── battle_combatant_hover_panel.tscn
│   │   │   ├── battle_combatant_presenter.gd
│   │   │   ├── combatant_view.gd
│   │   │   ├── combatant_view.tscn
│   │   │   ├── combatant_visual.gd
│   │   │   ├── placeholder_combatant_visual.tscn
│   │   │   └── statuses
│   │   │       ├── battle_status_chip.gd
│   │   │       ├── battle_status_chip.tscn
│   │   │       ├── battle_status_strip.gd
│   │   │       └── battle_status_strip.tscn
│   │   ├── grid
│   │   │   ├── battle_grid_overlay_presenter.gd
│   │   │   ├── battle_grid_view.gd
│   │   │   └── battle_grid_view.tscn
│   │   ├── movement
│   │   │   ├── battle_movement_outcome.gd
│   │   │   └── battle_movement_runner.gd
│   │   ├── previews
│   │   │   ├── battle_action_preview_badge.gd
│   │   │   ├── battle_action_preview_badge.tscn
│   │   │   ├── battle_action_preview_formatter.gd
│   │   │   └── battle_action_preview_presenter.gd
│   │   └── surfaces
│   │       ├── battle_surface_hover_panel.gd
│   │       └── battle_surface_hover_panel.tscn
│   └── common
│       └── controls
│           └── collapsible_panel_controller.gd
├── project.godot
└── scenes
    ├── debug
    │   ├── battle_grid_sandbox.gd
    │   ├── battle_grid_sandbox.tscn
    │   ├── controllers
    │   │   └── battle_sandbox_interaction_controller.gd
    │   └── presentation
    │       └── battle_debug_log_presenter.gd
    └── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `core/battle/ai/basic_melee_ai_controller.gd`
```gdscript
class_name BasicMeleeAIController
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_SESSION: StringName = &"invalid_session"
const FAILURE_INVALID_ACTOR: StringName = &"invalid_actor"
const FAILURE_INVALID_ABILITY: StringName = &"invalid_ability"
const FAILURE_UNSUPPORTED_ABILITY: StringName = &"unsupported_ability"

const FAILURE_ACTOR_DEAD: StringName = &"actor_dead"
const FAILURE_ACTOR_NOT_IN_SESSION: StringName = (
	&"actor_not_in_session"
)
const FAILURE_INVALID_MOVEMENT_COST: StringName = (
	&"invalid_movement_cost"
)

const FAILURE_NO_TARGETS: StringName = &"no_targets"
const FAILURE_NO_REACHABLE_TARGET: StringName = (
	&"no_reachable_target"
)
const FAILURE_NOT_ENOUGH_STAMINA: StringName = (
	&"not_enough_stamina"
)
const FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK: StringName = (
	&"not_enough_stamina_for_attack"
)

const FAILURE_MOVEMENT_RESTRICTED: StringName = (
	&"movement_restricted"
)

var movement_service: BattleMovementService
var action_service: BattleActionService
var targeting_service: BattleTargetingService


func _init(
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService
) -> void:
	assert(
		p_movement_service != null,
		"BasicMeleeAIController requires "
		+"a movement service."
	)

	assert(
		p_action_service != null,
		"BasicMeleeAIController requires "
		+"an action service."
	)

	assert(
		p_targeting_service != null,
		"BasicMeleeAIController requires "
		+"a targeting service."
	)

	movement_service = p_movement_service
	action_service = p_action_service
	targeting_service = p_targeting_service


func create_turn_plan(
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	stamina_cost_per_step: int = 1
) -> BasicMeleeAITurnPlan:
	var plan := BasicMeleeAITurnPlan.new()

	plan.actor = actor
	plan.ability = ability

	var validation_failure := _get_validation_failure(
		grid,
		session,
		actor,
		ability,
		stamina_cost_per_step
	)

	if validation_failure != &"":
		plan.failure_code = validation_failure
		return plan

	var targets := _get_enemy_targets(
		session,
		actor
	)

	if targets.is_empty():
		plan.failure_code = FAILURE_NO_TARGETS
		return plan

	var immediate_target := _find_immediate_target(
		session,
		actor,
		targets,
		ability
	)

	if immediate_target != null:
		plan.target = immediate_target
		plan.aim_coordinate = (
			immediate_target.grid_position
		)
		plan.expects_attack_after_movement = true
		plan.is_valid = true
		return plan

	# Если стоим рядом, но не хватает выносливости
	# на удар, двигаться уже некуда.
	var targetable_without_stamina := (
		_find_targetable_without_stamina(
			session,
			actor,
			targets,
			ability
		)
	)

	if targetable_without_stamina != null:
		plan.target = (
			targetable_without_stamina
		)

		plan.aim_coordinate = (
			targetable_without_stamina
			.grid_position
		)

		plan.failure_code = (
			FAILURE_NOT_ENOUGH_STAMINA_FOR_ATTACK
		)

		return plan

	if actor.is_movement_restricted():
		plan.failure_code = (
			FAILURE_MOVEMENT_RESTRICTED
		)

		return plan

	var maximum_steps := floori(
		float(actor.current_stamina)
		/ float(stamina_cost_per_step)
	)

	if maximum_steps <= 0:
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	# Сначала ищем нормальный маршрут до клетки,
	# с которой можно будет атаковать цель.
	var best_attack_target: CombatantState = null
	var best_attack_path: Array[Vector2i] = []
	var best_attack_destination := (
		BattleGrid.INVALID_COORDINATE
	)

	for target in targets:
		var attack_positions := (
			_get_attack_positions(
				session,
				actor,
				target,
				ability
			)
		)

		for destination in attack_positions:
			var candidate_path := (
				movement_service.find_shortest_path(
					grid,
					actor.grid_position,
					destination,
					actor.team_id
				)
			)

			if candidate_path.is_empty():
				continue

			if _is_better_attack_route(
				candidate_path,
				target,
				destination,
				best_attack_path,
				best_attack_target,
				best_attack_destination
			):
				best_attack_path = candidate_path
				best_attack_target = target
				best_attack_destination = destination

	if (
		best_attack_target != null
		and not best_attack_path.is_empty()
	):
		var attack_plan_created := (
			_apply_movement_path_to_plan(
				plan,
				grid,
				actor,
				best_attack_target,
				ability,
				best_attack_path,
				maximum_steps,
				stamina_cost_per_step,
				true
			)
		)

		if attack_plan_created:
			return plan

	# Если клетки атаки временно перекрыты союзниками
	# или узким проходом, всё равно пытаемся занять
	# лучшую доступную позицию ближе к противнику.
	var approach_plan_created := (
		_try_create_approach_plan(
			plan,
			grid,
			session,
			actor,
			targets,
			ability,
			maximum_steps,
			stamina_cost_per_step
		)
	)

	if approach_plan_created:
		return plan

	plan.failure_code = FAILURE_NO_REACHABLE_TARGET
	return plan


func _try_create_approach_plan(
	plan: BasicMeleeAITurnPlan,
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition,
	maximum_steps: int,
	stamina_cost_per_step: int
) -> bool:
	var best_target: CombatantState = null
	var best_path: Array[Vector2i] = []
	var best_destination := BattleGrid.INVALID_COORDINATE

	var best_remaining_distance: int = 1_000_000_000

	for target in targets:
		var current_distance := _get_manhattan_distance(
			actor.grid_position,
			target.grid_position
		)

		for y in range(grid.rows):
			for x in range(grid.columns):
				var destination := Vector2i(
					x,
					y
				)

				if destination == actor.grid_position:
					continue

				if not session.is_coordinate_allowed_for_team(
					actor.team_id,
					destination
				):
					continue

				var candidate_path := (
					movement_service.find_shortest_path(
						grid,
						actor.grid_position,
						destination,
						actor.team_id
					)
				)

				if candidate_path.is_empty():
					continue

				if candidate_path.size() > maximum_steps:
					continue

				var remaining_distance := (
					_get_manhattan_distance(
						destination,
						target.grid_position
					)
				)

				# Не тратим ход на движение, которое
				# вообще не приближает нас к цели.
				if remaining_distance >= current_distance:
					continue

				if _is_better_approach_route(
					candidate_path,
					target,
					destination,
					remaining_distance,
					best_path,
					best_target,
					best_destination,
					best_remaining_distance
				):
					best_path = candidate_path
					best_target = target
					best_destination = destination
					best_remaining_distance = (
						remaining_distance
					)

	if best_target == null or best_path.is_empty():
		return false

	return _apply_movement_path_to_plan(
		plan,
		grid,
		actor,
		best_target,
		ability,
		best_path,
		maximum_steps,
		stamina_cost_per_step,
		false
	)


func _apply_movement_path_to_plan(
	plan: BasicMeleeAITurnPlan,
	grid: BattleGrid,
	actor: CombatantState,
	target: CombatantState,
	ability: AbilityDefinition,
	path: Array[Vector2i],
	maximum_steps: int,
	stamina_cost_per_step: int,
	path_ends_in_attack_position: bool
) -> bool:
	if path.is_empty():
		return false

	var planned_steps := mini(
		maximum_steps,
		path.size()
	)

	if planned_steps <= 0:
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return false

	var movement_destination := (
		path[planned_steps - 1]
	)

	var movement_plan := movement_service.create_plan(
		grid,
		actor,
		movement_destination,
		stamina_cost_per_step
	)

	if not movement_plan.is_valid:
		plan.failure_code = movement_plan.failure_code
		return false

	plan.target = target
	plan.aim_coordinate = (
		target.grid_position
	)
	plan.movement_plan = movement_plan

	var reaches_path_destination := (
		planned_steps == path.size()
	)

	var total_cost_with_attack := (
		movement_plan.stamina_cost
		+ ability.stamina_cost
	)

	plan.expects_attack_after_movement = (
		path_ends_in_attack_position
		and reaches_path_destination
		and actor.current_stamina
		>= total_cost_with_attack
	)

	plan.is_valid = true
	return true


func _get_validation_failure(
	grid: BattleGrid,
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	stamina_cost_per_step: int
) -> StringName:
	if grid == null:
		return FAILURE_INVALID_GRID

	if session == null:
		return FAILURE_INVALID_SESSION

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null or not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY

	if (
		ability.targeting == null
		or not ability.targeting
		.is_single_enemy_targeting()
	):
		return FAILURE_UNSUPPORTED_ABILITY

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not session.has_combatant(
		actor.instance_id
	):
		return FAILURE_ACTOR_NOT_IN_SESSION

	if stamina_cost_per_step <= 0:
		return FAILURE_INVALID_MOVEMENT_COST

	return &""


func _get_enemy_targets(
	session: BattleSession,
	actor: CombatantState
) -> Array[CombatantState]:
	var targets: Array[CombatantState] = []

	for combatant in session.get_living_combatants():
		if combatant == actor:
			continue

		if combatant.team_id == actor.team_id:
			continue

		targets.append(
			combatant
		)

	return targets


func _find_immediate_target(
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition
) -> CombatantState:
	var best_target: CombatantState = null

	for target in targets:
		var command := BattleActionCommand.new(
			actor,
			ability,
			target.grid_position
		)

		if not action_service.can_execute(
			session,
			command
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _find_targetable_without_stamina(
	session: BattleSession,
	actor: CombatantState,
	targets: Array[CombatantState],
	ability: AbilityDefinition
) -> CombatantState:
	if actor.can_spend_stamina(
		ability.stamina_cost
	):
		return null

	var best_target: CombatantState = null

	for target in targets:
		if not targeting_service.can_target(
			session,
			actor,
			ability,
			target.grid_position
		):
			continue

		if _is_preferred_target(
			target,
			best_target
		):
			best_target = target

	return best_target


func _get_attack_positions(
	session: BattleSession,
	actor: CombatantState,
	target: CombatantState,
	ability: AbilityDefinition
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if (
		session == null
		or session.grid == null
		or actor == null
		or target == null
		or ability == null
	):
		return result

	var grid := session.grid

	for coordinate in (
		grid.get_all_coordinates()
	):
		if not session.is_coordinate_allowed_for_team(
			actor.team_id,
			coordinate
		):
			continue

		if coordinate != actor.grid_position:
			var cell := grid.get_cell(
				coordinate
			)

			if (
				cell == null
				or not cell.is_walkable()
			):
				continue

		if not targeting_service.can_target_from(
			session,
			actor,
			ability,
			coordinate,
			target.grid_position
		):
			continue

		result.append(
			coordinate
		)

	return result


func _is_preferred_target(
	candidate: CombatantState,
	current_best: CombatantState
) -> bool:
	if current_best == null:
		return true

	if (
		candidate.current_health
		!= current_best.current_health
	):
		return (
			candidate.current_health
			< current_best.current_health
		)

	return (
		String(candidate.instance_id)
		< String(current_best.instance_id)
	)


func _is_better_attack_route(
	candidate_path: Array[Vector2i],
	candidate_target: CombatantState,
	candidate_destination: Vector2i,
	best_path: Array[Vector2i],
	best_target: CombatantState,
	best_destination: Vector2i
) -> bool:
	if best_target == null:
		return true

	if candidate_path.size() != best_path.size():
		return (
			candidate_path.size()
			< best_path.size()
		)

	if (
		candidate_target.current_health
		!= best_target.current_health
	):
		return (
			candidate_target.current_health
			< best_target.current_health
		)

	var candidate_id := String(
		candidate_target.instance_id
	)

	var best_id := String(
		best_target.instance_id
	)

	if candidate_id != best_id:
		return candidate_id < best_id

	if candidate_destination.y != best_destination.y:
		return (
			candidate_destination.y
			< best_destination.y
		)

	return (
		candidate_destination.x
		< best_destination.x
	)


func _is_better_approach_route(
	candidate_path: Array[Vector2i],
	candidate_target: CombatantState,
	candidate_destination: Vector2i,
	candidate_remaining_distance: int,
	best_path: Array[Vector2i],
	best_target: CombatantState,
	best_destination: Vector2i,
	best_remaining_distance: int
) -> bool:
	if best_target == null:
		return true

	# Главное — оказаться как можно ближе к врагу.
	if (
		candidate_remaining_distance
		!= best_remaining_distance
	):
		return (
			candidate_remaining_distance
			< best_remaining_distance
		)

	# Если дистанция одинаковая, выбираем более
	# короткое и экономное перемещение.
	if candidate_path.size() != best_path.size():
		return (
			candidate_path.size()
			< best_path.size()
		)

	# Затем предпочитаем более раненую цель.
	if (
		candidate_target.current_health
		!= best_target.current_health
	):
		return (
			candidate_target.current_health
			< best_target.current_health
		)

	var candidate_id := String(
		candidate_target.instance_id
	)

	var best_id := String(
		best_target.instance_id
	)

	if candidate_id != best_id:
		return candidate_id < best_id

	if candidate_destination.y != best_destination.y:
		return (
			candidate_destination.y
			< best_destination.y
		)

	return (
		candidate_destination.x
		< best_destination.x
	)


func _get_manhattan_distance(
	from_coordinate: Vector2i,
	to_coordinate: Vector2i
) -> int:
	return (
		absi(
			from_coordinate.x
			- to_coordinate.x
		)
		+ absi(
			from_coordinate.y
			- to_coordinate.y
		)
	)
```

---

## FILE: `core/battle/ai/basic_melee_ai_turn_plan.gd`
```gdscript
class_name BasicMeleeAITurnPlan
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor: CombatantState
var target: CombatantState
var ability: AbilityDefinition

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var movement_plan: BattleMovementPlan
var expects_attack_after_movement: bool = false


func has_movement() -> bool:
	return (
		movement_plan != null
		and movement_plan.is_valid
		and movement_plan.has_path()
	)
```

---

## FILE: `core/battle/combatants/combatant_state.gd`
```gdscript
class_name CombatantState
extends RefCounted


signal health_changed(previous_value: int, current_value: int)
signal guard_changed(previous_value: int, current_value: int)
signal stamina_changed(previous_value: int, current_value: int)
signal ability_lock_changed(
	ability_id: StringName,
	previous_remaining_turns: int,
	current_remaining_turns: int
)
signal morale_changed(previous_value: int, current_value: int)
signal status_added(
	status: BattleStatusInstance
)

signal status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int
)

signal status_removed(
	status: BattleStatusInstance,
	reason: StringName
)
signal grid_position_changed(
	previous_position: Vector2i,
	current_position: Vector2i
)
signal died


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)

enum AbilityLockKind {
	NONE,
	INITIAL,
	COOLDOWN,
}
var instance_id: StringName
var definition: CombatantDefinition
var team_id: StringName
var loadout: CombatantLoadoutDefinition

var grid_position: Vector2i = INVALID_COORDINATE

var strength: int
var agility: int
var spirit: int

var max_health: int
var current_health: int

var current_guard: int

var armor: int

var max_stamina: int
var current_stamina: int
var stamina_regeneration: int

var initiative: int

var max_morale: int
var current_morale: int

var _statuses_by_id: Dictionary = {}
var _ability_lock_turns_by_id: Dictionary = {}
var _initially_locked_ability_ids: Dictionary = {}
var _cooldowns_started_this_turn: Dictionary = {}

var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_instance_id: StringName,
	p_definition: CombatantDefinition,
	p_team_id: StringName,
	p_loadout: CombatantLoadoutDefinition,
	p_grid_position: Vector2i = INVALID_COORDINATE
) -> void:
	assert(
		p_instance_id != &"",
		"CombatantState requires a non-empty instance ID."
	)

	assert(
		p_definition != null,
		"CombatantState requires a CombatantDefinition."
	)

	assert(
		p_loadout != null,
		"CombatantState requires a CombatantLoadoutDefinition."
	)

	instance_id = p_instance_id
	definition = p_definition
	team_id = p_team_id
	loadout = p_loadout
	grid_position = p_grid_position

	_initialize_runtime_attributes()


func _initialize_runtime_attributes() -> void:
	strength = definition.base_strength
	agility = definition.base_agility
	spirit = definition.base_spirit

	max_health = definition.max_health
	current_health = max_health

	current_guard = 0

	armor = definition.base_armor

	max_stamina = definition.max_stamina
	current_stamina = max_stamina
	stamina_regeneration = definition.stamina_regeneration

	initiative = definition.base_initiative

	max_morale = definition.base_morale
	current_morale = max_morale

	_initialize_ability_locks()


func set_grid_position(new_position: Vector2i) -> void:
	if grid_position == new_position:
		return

	var previous_position := grid_position
	grid_position = new_position

	grid_position_changed.emit(
		previous_position,
		grid_position
	)


func can_spend_stamina(amount: int) -> bool:
	return amount >= 0 and current_stamina >= amount


func spend_stamina(amount: int) -> bool:
	if amount < 0:
		return false

	if current_stamina < amount:
		return false

	var previous_value := current_stamina
	current_stamina -= amount

	stamina_changed.emit(
		previous_value,
		current_stamina
	)

	return true


func restore_stamina(amount: int) -> int:
	if amount <= 0:
		return 0

	var previous_value := current_stamina

	current_stamina = mini(
		max_stamina,
		current_stamina + amount
	)

	var restored_amount := current_stamina - previous_value

	if restored_amount > 0:
		stamina_changed.emit(
			previous_value,
			current_stamina
		)

	return restored_amount


func restore_round_stamina() -> int:
	return restore_stamina(stamina_regeneration)

func grant_guard(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_guard

	current_guard = mini(
		max_health,
		current_guard + amount
	)

	var granted_amount := (
		current_guard - previous_value
	)

	if granted_amount > 0:
		guard_changed.emit(
			previous_value,
			current_guard
		)

	return granted_amount


func absorb_damage_with_guard(
	amount: int
) -> int:
	if amount <= 0 or current_guard <= 0:
		return 0

	var previous_value := current_guard

	var absorbed_amount := mini(
		amount,
		current_guard
	)

	current_guard -= absorbed_amount

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return absorbed_amount


func clear_guard() -> int:
	if current_guard <= 0:
		return 0

	var previous_value := current_guard
	current_guard = 0

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return previous_value

func apply_resolved_damage(
	amount: int,
	bypass_guard: bool = false
) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var remaining_damage := amount

	if not bypass_guard:
		remaining_damage -= (
			absorb_damage_with_guard(
				remaining_damage
			)
		)

	if remaining_damage <= 0:
		return 0

	var previous_value := current_health

	current_health = maxi(
		0,
		current_health - remaining_damage
	)

	var received_damage := (
		previous_value - current_health
	)

	if received_damage > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	if previous_value > 0 and current_health == 0:
		clear_guard()

		clear_statuses(
			&"owner_defeated"
		)

		died.emit()

	return received_damage


func heal(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_health

	current_health = mini(
		max_health,
		current_health + amount
	)

	var healed_amount := current_health - previous_value

	if healed_amount > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	return healed_amount


func set_morale(new_value: int) -> void:
	var clamped_value := clampi(
		new_value,
		0,
		max_morale
	)

	if current_morale == clamped_value:
		return

	var previous_value := current_morale
	current_morale = clamped_value

	morale_changed.emit(
		previous_value,
		current_morale
	)


func change_morale(amount: int) -> int:
	var previous_value := current_morale

	set_morale(current_morale + amount)

	return current_morale - previous_value


func get_abilities() -> Array[AbilityDefinition]:
	if loadout == null:
		return []

	return loadout.get_abilities()


func has_ability(
	ability_id: StringName
) -> bool:
	return (
		loadout != null
		and loadout.has_ability(
			ability_id
		)
	)


func get_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_ability(
		ability_id
	)


func get_default_ability() -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_default_ability()

func get_ability_lock_remaining_turns(
	ability_id: StringName
) -> int:
	if ability_id == &"":
		return 0

	if not _ability_lock_turns_by_id.has(
		ability_id
	):
		return 0

	return maxi(
		0,
		int(
			_ability_lock_turns_by_id[
				ability_id
			]
		)
	)


func get_ability_lock_kind(
	ability_id: StringName
) -> int:
	if (
		get_ability_lock_remaining_turns(
			ability_id
		) <= 0
	):
		return AbilityLockKind.NONE

	if _initially_locked_ability_ids.has(
		ability_id
	):
		return AbilityLockKind.INITIAL

	return AbilityLockKind.COOLDOWN


func is_ability_locked(
	ability_id: StringName
) -> bool:
	return (
		get_ability_lock_remaining_turns(
			ability_id
		) > 0
	)


func start_ability_cooldown(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	if ability.ability_id == &"":
		return false

	if not has_ability(
		ability.ability_id
	):
		return false

	var cooldown_turns := maxi(
		0,
		ability.cooldown_turns
	)

	if cooldown_turns <= 0:
		return false

	var previous_remaining_turns := (
		get_ability_lock_remaining_turns(
			ability.ability_id
		)
	)

	_ability_lock_turns_by_id[
		ability.ability_id
	] = cooldown_turns

	_initially_locked_ability_ids.erase(
		ability.ability_id
	)

	_cooldowns_started_this_turn[
		ability.ability_id
	] = true

	ability_lock_changed.emit(
		ability.ability_id,
		previous_remaining_turns,
		cooldown_turns
	)

	return true


func advance_ability_cooldowns_after_owner_turn() -> void:
	var ability_ids: Array = (
		_ability_lock_turns_by_id.keys()
	)

	for value in ability_ids:
		var ability_id: StringName = value

		if _cooldowns_started_this_turn.has(
			ability_id
		):
			continue

		var previous_remaining_turns := (
			get_ability_lock_remaining_turns(
				ability_id
			)
		)

		if previous_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

			continue

		var current_remaining_turns := maxi(
			0,
			previous_remaining_turns - 1
		)

		if current_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

		else:
			_ability_lock_turns_by_id[
				ability_id
			] = current_remaining_turns

		ability_lock_changed.emit(
			ability_id,
			previous_remaining_turns,
			current_remaining_turns
		)

	_cooldowns_started_this_turn.clear()


func _initialize_ability_locks() -> void:
	_ability_lock_turns_by_id.clear()
	_initially_locked_ability_ids.clear()
	_cooldowns_started_this_turn.clear()

	if loadout == null:
		return

	for ability in loadout.get_abilities():
		if ability == null:
			continue

		if ability.initial_lock_turns <= 0:
			continue

		_ability_lock_turns_by_id[
			ability.ability_id
		] = ability.initial_lock_turns

		_initially_locked_ability_ids[
			ability.ability_id
		] = true

func get_active_statuses() -> Array[BattleStatusInstance]:
	var result: Array[BattleStatusInstance] = []

	for value in _statuses_by_id.values():
		var status := (
			value as BattleStatusInstance
		)

		if status == null:
			continue

		result.append(
			status
		)

	return result


func get_status(
	status_id: StringName
) -> BattleStatusInstance:
	if status_id == &"":
		return null

	if not _statuses_by_id.has(
		status_id
	):
		return null

	return (
		_statuses_by_id[status_id]
		as BattleStatusInstance
	)


func has_status(
	status_id: StringName
) -> bool:
	return get_status(
		status_id
	) != null


func add_status(
	status_definition: BattleStatusDefinition,
	source_instance_id: StringName = &""
) -> BattleStatusInstance:
	if status_definition == null:
		return null

	if not status_definition.is_valid_definition():
		return null

	if (
		definition != null
		and definition.is_immune_to_status(
			status_definition
		)
	):
		return null

	var existing_status := get_status(
		status_definition.status_id
	)

	if existing_status != null:
		var previous_stack_count := (
			existing_status.stack_count
		)

		var previous_remaining_turns := (
			existing_status.remaining_turns
		)

		existing_status.reapply(
			source_instance_id
		)

		status_updated.emit(
			existing_status,
			previous_stack_count,
			previous_remaining_turns
		)

		return existing_status

	var new_status := BattleStatusInstance.new(
		status_definition,
		source_instance_id
	)

	_statuses_by_id[
		status_definition.status_id
	] = new_status

	status_added.emit(
		new_status
	)

	return new_status


func remove_status(
	status_id: StringName,
	reason: StringName = &"removed"
) -> bool:
	var status := get_status(
		status_id
	)

	if status == null:
		return false

	_statuses_by_id.erase(
		status_id
	)

	status_removed.emit(
		status,
		reason
	)

	return true


func clear_statuses(
	reason: StringName = &"cleared"
) -> void:
	var status_ids: Array = (
		_statuses_by_id.keys()
	)

	for value in status_ids:
		var status_id: StringName = value

		remove_status(
			status_id,
			reason
		)

func get_status_ids_matching_removal(
	effect: RemoveStatusEffect
) -> Array[StringName]:
	var result: Array[StringName] = []

	if effect == null:
		return result

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		if not effect.matches_status_definition(
			status.definition
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func remove_statuses_matching(
	effect: RemoveStatusEffect,
	reason: StringName = &"removed_by_effect"
) -> Array[BattleStatusInstance]:
	var removed_statuses: Array[BattleStatusInstance] = []

	var matching_status_ids := (
		get_status_ids_matching_removal(
			effect
		)
	)

	for status_id in matching_status_ids:
		var status := get_status(
			status_id
		)

		if status == null:
			continue

		if not remove_status(
			status_id,
			reason
		):
			continue

		removed_statuses.append(
			status
		)

	return removed_statuses
	
func advance_statuses_after_owner_turn() -> Array[StringName]:
	var expired_status_ids: Array[StringName] = []

	var statuses := get_active_statuses()

	for status in statuses:
		if status == null:
			continue

		var previous_stack_count := (
			status.stack_count
		)

		var previous_remaining_turns := (
			status.remaining_turns
		)

		status.advance_owner_turn()

		if status.is_expired:
			expired_status_ids.append(
				status.status_id
			)

			remove_status(
				status.status_id,
				&"expired"
			)

			continue

		status_updated.emit(
			status,
			previous_stack_count,
			previous_remaining_turns
		)

	return expired_status_ids

func must_skip_turn() -> bool:
	return not get_turn_skip_status_ids().is_empty()


func is_movement_restricted() -> bool:
	return not (
		get_movement_restriction_status_ids()
		.is_empty()
	)


func is_ability_restricted(
	ability_id: StringName
) -> bool:
	return not (
		get_ability_restriction_status_ids(
			ability_id
		).is_empty()
	)


func get_turn_skip_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction.skip_owner_turn
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_movement_restriction_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_movement()
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_ability_restriction_status_ids(
	ability_id: StringName
) -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_ability(
				ability_id
			)
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func _is_status_id_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)

func get_stat_base_value(
	stat: int
) -> int:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return armor

		BattleStatModifier.Stat.STRENGTH:
			return strength

		BattleStatModifier.Stat.AGILITY:
			return agility

		BattleStatModifier.Stat.SPIRIT:
			return spirit

	return 0


func get_stat_modifier_total(
	stat: int
) -> int:
	var total: int = 0

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		for modifier in (
			status.definition.stat_modifiers
		):
			if modifier == null:
				continue

			if modifier.stat != stat:
				continue

			total += modifier.get_total_amount(
				status.stack_count
			)

	return total


# Оставляем старое имя как совместимый переходный метод,
# чтобы уже существующий код не сломался.
func get_status_modifier_total(
	stat: int
) -> int:
	return get_stat_modifier_total(
		stat
	)


func get_effective_stat(
	stat: int
) -> int:
	return maxi(
		0,
		get_stat_base_value(stat)
		+ get_stat_modifier_total(stat)
	)


func get_effective_strength() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.STRENGTH
	)


func get_effective_agility() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.AGILITY
	)


func get_effective_spirit() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.SPIRIT
	)


func get_effective_armor() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.ARMOR
	)
```

---

## FILE: `core/battle/loadouts/combatant_loadout_definition.gd`
```gdscript
@tool
class_name CombatantLoadoutDefinition
extends Resource


@export_group("Identity")

@export
var loadout_id: StringName = &""

@export
var display_name: String = "Unnamed Loadout"


@export_group("Abilities")

@export
var default_ability_id: StringName = &""

@export
var abilities: Array[AbilityDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if loadout_id == &"":
		errors.append(
			"Loadout ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Loadout display name is empty."
		)

	if abilities.is_empty():
		errors.append(
			"Loadout must contain at least one ability."
		)

	var used_ability_ids: Dictionary = {}

	for ability_index in range(
		abilities.size()
	):
		var ability := abilities[ability_index]

		if ability == null:
			errors.append(
				"Ability at index %d is null."
				% ability_index
			)

			continue

		for ability_error in ability.get_validation_errors():
			errors.append(
				"Ability %d: %s"
				% [
					ability_index,
					ability_error,
				]
			)

		if ability.ability_id == &"":
			continue

		if used_ability_ids.has(
			ability.ability_id
		):
			errors.append(
				"Duplicate ability ID in loadout: %s."
				% ability.ability_id
			)
		else:
			used_ability_ids[
				ability.ability_id
			] = true

	if default_ability_id == &"":
		errors.append(
			"Default ability ID is empty."
		)

	elif not used_ability_ids.has(
		default_ability_id
	):
		errors.append(
			"Default ability '%s' is not included "
			% default_ability_id
			+"in the loadout."
		)

	return errors


func has_ability(
	ability_id: StringName
) -> bool:
	return get_ability(
		ability_id
	) != null


func get_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if ability_id == &"":
		return null

	for ability in abilities:
		if (
			ability != null
			and ability.ability_id == ability_id
		):
			return ability

	return null


func get_default_ability() -> AbilityDefinition:
	return get_ability(
		default_ability_id
	)


func get_abilities() -> Array[AbilityDefinition]:
	var result: Array[AbilityDefinition] = []

	for ability in abilities:
		if ability != null:
			result.append(
				ability
			)

	return result
```

---

## FILE: `core/battle/session/battle_session.gd`
```gdscript
class_name BattleSession
extends RefCounted


signal combatant_added(combatant: CombatantState)
signal combatant_removed(instance_id: StringName)
signal combatant_defeated(combatant: CombatantState)


var grid: BattleGrid
var side_rules: BattleSideRules
var surface_effect_controller: BattleSurfaceEffectController

var _combatants: Dictionary = {}
var _death_callbacks: Dictionary = {}


func _init(
	p_rows: int = 5,
	p_columns: int = 10,
	p_side_rules: BattleSideRules = null
) -> void:
	side_rules = (
		p_side_rules
		if p_side_rules != null
		else BattleSideRules.new()
	)

	var side_errors := (
		side_rules.get_validation_errors(
			p_columns
		)
	)

	assert(
		side_errors.is_empty(),
		"Invalid battle side rules: %s"
		% side_errors
	)

	surface_effect_controller = (
		BattleSurfaceEffectController.new()
	)

	grid = BattleGrid.new(
		p_rows,
		p_columns
	)


func add_combatant(
	instance_id: StringName,
	definition: CombatantDefinition,
	team_id: StringName,
	coordinate: Vector2i,
	loadout_override: CombatantLoadoutDefinition = null
) -> CombatantState:
	if instance_id == &"":
		return null

	if definition == null:
		return null

	var resolved_loadout := (
		loadout_override
		if loadout_override != null
		else definition.default_loadout
	)

	if resolved_loadout == null:
		return null

	if not resolved_loadout.is_valid_definition():
		return null

	if team_id == &"":
		return null

	if not is_coordinate_allowed_for_team(
		team_id,
		coordinate
	):
		return null

	if _combatants.has(instance_id):
		return null

	if not grid.try_place_occupant(
		instance_id,
		coordinate
	):
		return null

	var combatant := CombatantState.new(
		instance_id,
		definition,
		team_id,
		resolved_loadout,
		coordinate
	)

	_combatants[instance_id] = combatant

	var death_callback := Callable(
		self,
		"_on_combatant_died"
	).bind(combatant)

	_death_callbacks[instance_id] = death_callback

	combatant.died.connect(
		death_callback
	)

	combatant_added.emit(
		combatant
	)

	return combatant


func has_combatant(
	instance_id: StringName
) -> bool:
	return _combatants.has(instance_id)


func get_combatant(
	instance_id: StringName
) -> CombatantState:
	return (
		_combatants.get(instance_id)
		as CombatantState
	)


func get_all_combatants() -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for value in _combatants.values():
		var combatant := value as CombatantState

		if combatant != null:
			result.append(combatant)

	return result


func get_living_combatants() -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for combatant in get_all_combatants():
		if combatant.is_alive:
			result.append(combatant)

	return result


func get_team_combatants(
	team_id: StringName,
	living_only: bool = false
) -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	for combatant in get_all_combatants():
		if combatant.team_id != team_id:
			continue

		if living_only and not combatant.is_alive:
			continue

		result.append(combatant)

	return result


func is_team_supported(
	team_id: StringName
) -> bool:
	return (
		side_rules != null
		and side_rules.is_team_supported(
			team_id
		)
	)


func is_coordinate_allowed_for_team(
	team_id: StringName,
	coordinate: Vector2i
) -> bool:
	if side_rules == null or grid == null:
		return false

	return side_rules.is_coordinate_allowed(
		team_id,
		coordinate,
		grid.rows,
		grid.columns
	)


func get_team_forward_direction(
	team_id: StringName
) -> int:
	if side_rules == null:
		return 0

	return side_rules.get_forward_direction(
		team_id
	)

func remove_combatant(
	instance_id: StringName
) -> bool:
	var combatant := get_combatant(
		instance_id
	)

	if combatant == null:
		return false

	var death_callback: Callable = (
		_death_callbacks.get(
			instance_id,
			Callable()
		)
	)

	if (
		death_callback.is_valid()
		and combatant.is_connected(
			&"died",
			death_callback
		)
	):
		combatant.disconnect(
			&"died",
			death_callback
		)

	grid.remove_occupant(
		instance_id
	)

	_death_callbacks.erase(
		instance_id
	)

	_combatants.erase(
		instance_id
	)

	combatant_removed.emit(
		instance_id
	)

	return true


func clear() -> void:
	if surface_effect_controller != null:
		surface_effect_controller.clear(
			self
		)

	var combatant_ids := _combatants.keys()

	for value in combatant_ids:
		var instance_id: StringName = value

		remove_combatant(
			instance_id
		)

	grid.clear()


func _on_combatant_died(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	if not has_combatant(
		combatant.instance_id
	):
		return

	grid.remove_occupant(
		combatant.instance_id
	)

	combatant_defeated.emit(
		combatant
	)
```

---

## FILE: `core/battle/turns/battle_turn_controller.gd`
```gdscript
class_name BattleTurnController
extends RefCounted


signal battle_started
signal round_started(round_number: int)

signal turn_starting(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_started(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_skipped(
	combatant: CombatantState,
	round_number: int,
	turn_index: int,
	restriction_status_ids: Array[StringName]
)

signal turn_ending(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal turn_ended(
	combatant: CombatantState,
	round_number: int,
	turn_index: int
)

signal periodic_status_effects_resolved(
	combatant: CombatantState,
	timing: int,
	results: Array[BattleStatusPeriodicTriggerResult]
)

signal battle_finished(
	winning_team_id: StringName
)


var session: BattleSession
var reinforcement_controller: BattleReinforcementController

var periodic_status_processor: BattleStatusPeriodicProcessor

var round_number: int = 0
var active_combatant: CombatantState
var winning_team_id: StringName = &""


var is_running: bool:
	get:
		return _started and not _finished


var is_finished: bool:
	get:
		return _finished


var _turn_order: Array[CombatantState] = []
var _current_turn_index: int = -1

var _started: bool = false
var _finished: bool = false

var _is_processing_periodic_statuses: bool = false
var _is_processing_surface_effects: bool = false


func _init(
	p_periodic_status_processor: BattleStatusPeriodicProcessor = null
) -> void:
	periodic_status_processor = (
		p_periodic_status_processor
		if p_periodic_status_processor != null
		else BattleStatusPeriodicProcessor.new()
	)


func start(
	p_session: BattleSession,
	p_reinforcement_controller: BattleReinforcementController = null
) -> bool:
	if _started:
		return false

	if p_session == null:
		return false

	session = p_session
	reinforcement_controller = (
		p_reinforcement_controller
	)

	_started = true
	_finished = false

	round_number = 0
	winning_team_id = &""

	_connect_session_signals()

	battle_started.emit()

	return _start_round(1)


func end_current_turn() -> bool:
	if not is_running:
		return false

	if active_combatant == null:
		return false

	var ended_combatant := active_combatant
	var ended_index := _current_turn_index

	turn_ending.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	_process_periodic_status_effects(
		ended_combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_END
	)

	if ended_combatant.is_alive:
		ended_combatant.advance_statuses_after_owner_turn()

	_process_surface_effects(
		ended_combatant,
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_END
	)

	ended_combatant.advance_ability_cooldowns_after_owner_turn()

	turn_ended.emit(
		ended_combatant,
		round_number,
		ended_index
	)

	active_combatant = null

	if evaluate_battle_state():
		return true

	return _advance_to_next_turn()


func evaluate_battle_state() -> bool:
	if not _started:
		return false

	if _finished:
		return true

	var living_combatants := (
		session.get_living_combatants()
	)

	if living_combatants.is_empty():
		if (
			reinforcement_controller != null
			and reinforcement_controller
			.has_pending_reinforcements()
		):
			return false

		_finish_battle(&"")
		return true

	var living_team_ids: Dictionary = {}

	for combatant in living_combatants:
		living_team_ids[
			combatant.team_id
		] = true

	if living_team_ids.size() > 1:
		return false

	var possible_winner: StringName = (
		living_team_ids.keys()[0]
	)

	if (
		reinforcement_controller != null
		and reinforcement_controller
		.has_pending_opposition_to(
			possible_winner
		)
	):
		return false

	_finish_battle(
		possible_winner
	)

	return true


func is_combatant_active(
	combatant: CombatantState
) -> bool:
	return (
		is_running
		and combatant != null
		and combatant == active_combatant
	)


func get_turn_order() -> Array[CombatantState]:
	return _turn_order.duplicate()


func get_current_turn_index() -> int:
	return _current_turn_index


func _start_round(
	new_round_number: int
) -> bool:
	if not is_running:
		return false

	round_number = new_round_number
	active_combatant = null
	_current_turn_index = -1

	if (
		session != null
		and session.surface_effect_controller != null
	):
		session.surface_effect_controller.advance_to_round(
			session,
			round_number
		)

	if reinforcement_controller != null:
		reinforcement_controller.process_round(
			round_number
		)

	_rebuild_turn_order()

	if evaluate_battle_state():
		return true

	if _turn_order.is_empty():
		return false

	round_started.emit(
		round_number
	)

	_current_turn_index = 0

	_begin_turn(
		_turn_order[_current_turn_index]
	)

	return true


func _advance_to_next_turn() -> bool:
	var next_index := (
		_current_turn_index + 1
	)

	while next_index < _turn_order.size():
		var candidate := _turn_order[next_index]

		if (
			candidate != null
			and candidate.is_alive
		):
			_current_turn_index = next_index

			_begin_turn(
				candidate
			)

			return true

		next_index += 1

	return _start_next_round()


func _start_next_round() -> bool:
	return _start_round(
		round_number + 1
	)


func _begin_turn(
	combatant: CombatantState
) -> void:
	if (
		combatant == null
		or not combatant.is_alive
	):
		return

	active_combatant = combatant

	turn_starting.emit(
		combatant,
		round_number,
		_current_turn_index
	)

	_process_periodic_status_effects(
		combatant,
		BattleStatusPeriodicTrigger
		.Timing
		.OWNER_TURN_START
	)

	_process_surface_effects(
		combatant,
		BattleSurfaceEffectDefinition
			.TriggerTiming
			.OWNER_TURN_START
	)

	if not combatant.is_alive:
		active_combatant = null

		if evaluate_battle_state():
			return

		_advance_to_next_turn()
		return

	combatant.restore_round_stamina()

	var skip_status_ids := (
		combatant.get_turn_skip_status_ids()
	)

	if not skip_status_ids.is_empty():
		turn_skipped.emit(
			combatant,
			round_number,
			_current_turn_index,
			skip_status_ids
		)

		end_current_turn()
		return

	turn_started.emit(
		combatant,
		round_number,
		_current_turn_index
	)


func _process_periodic_status_effects(
	combatant: CombatantState,
	timing: int
) -> Array[BattleStatusPeriodicTriggerResult]:
	var results: Array[BattleStatusPeriodicTriggerResult] = []

	if periodic_status_processor == null:
		return results

	_is_processing_periodic_statuses = true

	results = (
		periodic_status_processor
		.process_owner_timing(
			session,
			combatant,
			timing
		)
	)

	_is_processing_periodic_statuses = false

	if not results.is_empty():
		periodic_status_effects_resolved.emit(
			combatant,
			timing,
			results
		)

	return results


func _process_surface_effects(
	combatant: CombatantState,
	timing: int
) -> Array[BattleSurfaceTriggerResult]:
	var results: Array[BattleSurfaceTriggerResult] = []

	if (
		session == null
		or session.surface_effect_controller == null
		or combatant == null
		or not combatant.is_alive
	):
		return results

	_is_processing_surface_effects = true

	results = (
		session
		.surface_effect_controller
		.trigger_for_combatant(
			session,
			combatant,
			timing
		)
	)

	_is_processing_surface_effects = false

	return results

func _rebuild_turn_order() -> void:
	_turn_order.clear()

	for combatant in (
		session.get_living_combatants()
	):
		if (
			combatant == null
			or combatant.definition == null
		):
			continue

		if not (
			combatant
			.definition
			.participates_in_turn_order
		):
			continue

		_turn_order.append(
			combatant
		)

	_turn_order.sort_custom(
		Callable(
			self,
			"_has_higher_turn_priority"
		)
	)


func _has_higher_turn_priority(
	first: CombatantState,
	second: CombatantState
) -> bool:
	if first.initiative != second.initiative:
		return first.initiative > second.initiative

	return (
		String(first.instance_id)
		< String(second.instance_id)
	)


func _connect_session_signals() -> void:
	var callback := Callable(
		self,
		"_on_combatant_defeated"
	)

	if not session.is_connected(
		&"combatant_defeated",
		callback
	):
		session.connect(
			&"combatant_defeated",
			callback
		)


func _on_combatant_defeated(
	_combatant: CombatantState
) -> void:
	if (
		_is_processing_periodic_statuses
		or _is_processing_surface_effects
	):
		return

	evaluate_battle_state()


func _finish_battle(
	p_winning_team_id: StringName
) -> void:
	if _finished:
		return

	_finished = true
	winning_team_id = p_winning_team_id
	active_combatant = null

	battle_finished.emit(
		winning_team_id
	)
```

---

## FILE: `presentation/battle/ai/basic_melee_ai_turn_outcome.gd`
```gdscript
class_name BasicMeleeAITurnOutcome
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""
var target_id: StringName = &""

var movement_outcome: BattleMovementOutcome

# Последний выполненный результат оставляем
# для совместимости с существующим кодом.
var action_outcome: BattleActionOutcome

var action_outcomes: Array[BattleActionOutcome] = []


func did_move() -> bool:
	return (
		movement_outcome != null
		and movement_outcome.did_move()
	)


func get_movement_step_count() -> int:
	if movement_outcome == null:
		return 0

	return movement_outcome.get_step_count()


func add_action_outcome(
	outcome: BattleActionOutcome
) -> void:
	if outcome == null:
		return

	action_outcomes.append(
		outcome
	)

	action_outcome = outcome


func did_attack() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			return true

	return false


func get_attack_count() -> int:
	var result: int = 0

	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_execute()
		):
			result += 1

	return result


func get_damage_dealt() -> int:
	var result: int = 0

	for outcome in action_outcomes:
		if outcome == null:
			continue

		result += outcome.get_total_applied_amount(
			&"damage"
		)

	return result


func did_target_die() -> bool:
	for outcome in action_outcomes:
		if (
			outcome != null
			and outcome.did_target_die()
		):
			return true

	return false
```

---

## FILE: `presentation/battle/ai/basic_melee_ai_turn_runner.gd`
```gdscript
class_name BasicMeleeAITurnRunner
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_PLAN: StringName = (
	&"invalid_plan"
)

const FAILURE_ACTION_LIMIT_REACHED: StringName = (
	&"action_limit_reached"
)


const MAX_ACTIONS_PER_TURN: int = 64


var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner


func _init(
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner
) -> void:
	assert(
		p_movement_runner != null,
		"BasicMeleeAITurnRunner requires "
		+"a movement runner."
	)

	assert(
		p_action_runner != null,
		"BasicMeleeAITurnRunner requires "
		+"an action runner."
	)

	movement_runner = p_movement_runner
	action_runner = p_action_runner


func execute(
	session: BattleSession,
	plan: BasicMeleeAITurnPlan,
	animate_movement: bool = true,
	animate_action: bool = true
) -> BasicMeleeAITurnOutcome:
	var outcome := BasicMeleeAITurnOutcome.new()

	if session == null or session.grid == null:
		outcome.failure_code = (
			FAILURE_INVALID_SESSION
		)

		return outcome

	if (
		plan == null
		or not plan.is_valid
		or plan.actor == null
		or plan.target == null
		or plan.ability == null
	):
		outcome.failure_code = (
			FAILURE_INVALID_PLAN
		)

		return outcome

	var grid := session.grid

	outcome.actor_id = (
		plan.actor.instance_id
	)

	outcome.target_id = (
		plan.target.instance_id
	)

	if plan.has_movement():
		outcome.movement_outcome = await (
			movement_runner.execute(
				grid,
				plan.actor,
				plan.movement_plan,
				animate_movement
			)
		)

		if not outcome.movement_outcome.is_successful:
			outcome.failure_code = (
				outcome.movement_outcome
				.failure_code
			)

			return outcome

	if not plan.actor.is_alive:
		outcome.is_successful = true
		return outcome

	if not plan.target.is_alive:
		outcome.is_successful = true
		return outcome

	var executed_action_count: int = 0

	while (
		plan.actor.is_alive
		and plan.target.is_alive
	):
		if (
			executed_action_count
			>= MAX_ACTIONS_PER_TURN
		):
			outcome.failure_code = (
				FAILURE_ACTION_LIMIT_REACHED
			)

			return outcome

		var command := BattleActionCommand.new(
			plan.actor,
			plan.ability,
			plan.target.grid_position
		)

		if not action_runner.can_execute(
			session,
			command
		):
			break

		var previous_actor_stamina := (
			plan.actor.current_stamina
		)

		var previous_target_health := (
			plan.target.current_health
		)

		var current_action_outcome := await (
			action_runner.execute_action(
				session,
				command,
				animate_action
			)
		)

		if not current_action_outcome.is_successful:
			outcome.failure_code = (
				current_action_outcome
				.failure_code
			)

			return outcome

		outcome.add_action_outcome(
			current_action_outcome
		)

		executed_action_count += 1

		var stamina_changed := (
			plan.actor.current_stamina
			!= previous_actor_stamina
		)

		var health_changed := (
			plan.target.current_health
			!= previous_target_health
		)

		if not stamina_changed and not health_changed:
			break

	outcome.is_successful = true
	return outcome
```

---

## FILE: `scenes/debug/controllers/battle_sandbox_interaction_controller.gd`
```gdscript
class_name BattleSandboxInteractionController
extends RefCounted


var player_team_id: StringName

var session: BattleSession
var grid: BattleGrid
var turn_controller: BattleTurnController

var ability_panel: BattleAbilityPanel
var combatant_hover_panel: BattleCombatantHoverPanel

var surface_hover_panel: BattleSurfaceHoverPanel

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService

var action_preview_service: BattleActionPreviewService
var action_preview_presenter: BattleActionPreviewPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var grid_overlay_presenter: BattleGridOverlayPresenter
var debug_log_presenter: BattleDebugLogPresenter

var stamina_cost_per_cell: int = 1
var animate_movement: bool = true
var animate_actions: bool = true

var _obstacle_counter: int = 0
var _interaction_in_progress: bool = false

var _selected_ability: AbilityDefinition

var _hovered_coordinate: Vector2i = (
	BattleGridView.INVALID_COORDINATE
)


func _init(
	p_player_team_id: StringName,
	p_session: BattleSession,
	p_turn_controller: BattleTurnController,
	p_ability_panel: BattleAbilityPanel,
	p_combatant_hover_panel: BattleCombatantHoverPanel,
	p_surface_hover_panel: BattleSurfaceHoverPanel,
	p_movement_service: BattleMovementService,
	p_targeting_service: BattleTargetingService,
	p_action_preview_service: BattleActionPreviewService,
	p_action_preview_presenter: BattleActionPreviewPresenter,
	p_movement_runner: BattleMovementRunner,
	p_action_runner: BattleActionRunner,
	p_grid_overlay_presenter: BattleGridOverlayPresenter,
	p_debug_log_presenter: BattleDebugLogPresenter,
	p_stamina_cost_per_cell: int = 1,
	p_animate_movement: bool = true,
	p_animate_actions: bool = true
) -> void:
	assert(
		p_player_team_id != &"",
		"Interaction controller requires a player team ID."
	)

	assert(
		p_session != null,
		"Interaction controller requires a battle session."
	)

	assert(
		p_turn_controller != null,
		"Interaction controller requires a turn controller."
	)

	assert(
		p_ability_panel != null,
		"Interaction controller requires an ability panel."
	)

	assert(
		p_combatant_hover_panel != null,
		"Interaction controller requires "
		+"a combatant hover panel."
	)

	assert(
		p_surface_hover_panel != null,
		"Interaction controller requires "
		+"a surface hover panel."
	)

	assert(
		p_movement_service != null,
		"Interaction controller requires a movement service."
	)

	assert(
		p_targeting_service != null,
		"Interaction controller requires a targeting service."
	)

	assert(
		p_action_preview_service != null,
		"Interaction controller requires "
		+"an action preview service."
	)

	assert(
		p_action_preview_presenter != null,
		"Interaction controller requires "
		+"an action preview presenter."
	)

	assert(
		p_movement_runner != null,
		"Interaction controller requires a movement runner."
	)

	assert(
		p_action_runner != null,
		"Interaction controller requires an action runner."
	)

	assert(
		p_grid_overlay_presenter != null,
		"Interaction controller requires an overlay presenter."
	)

	assert(
		p_debug_log_presenter != null,
		"Interaction controller requires a debug log presenter."
	)

	player_team_id = p_player_team_id

	session = p_session
	grid = session.grid
	turn_controller = p_turn_controller

	ability_panel = p_ability_panel
	combatant_hover_panel = (
		p_combatant_hover_panel
	)

	surface_hover_panel = (
		p_surface_hover_panel
	)

	movement_service = p_movement_service
	targeting_service = p_targeting_service
	action_preview_service = (
		p_action_preview_service
	)

	action_preview_presenter = (
		p_action_preview_presenter
	)

	movement_runner = p_movement_runner
	action_runner = p_action_runner

	grid_overlay_presenter = p_grid_overlay_presenter
	debug_log_presenter = p_debug_log_presenter

	stamina_cost_per_cell = maxi(
		1,
		p_stamina_cost_per_cell
	)

	animate_movement = p_animate_movement
	animate_actions = p_animate_actions


func begin_player_turn(
	combatant: CombatantState
) -> void:
	_interaction_in_progress = false

	_selected_ability = get_default_ability(
		combatant
	)

	ability_panel.bind_combatant(
		combatant,
		_selected_ability
	)

	ability_panel.set_interactable(
		true
	)

	refresh_grid_overlays()


func begin_enemy_turn() -> void:
	_interaction_in_progress = true
	_selected_ability = null
	action_preview_presenter.clear()

	ability_panel.clear_combatant()

	refresh_grid_overlays()

func begin_skipped_turn() -> void:
	_interaction_in_progress = true
	_selected_ability = null
	action_preview_presenter.clear()

	ability_panel.clear_combatant()
	grid_overlay_presenter.clear()

func finish_battle() -> void:
	_interaction_in_progress = false
	_selected_ability = null
	action_preview_presenter.clear()

	ability_panel.clear_combatant()
	combatant_hover_panel.clear_combatant()
	surface_hover_panel.clear_surfaces()
	grid_overlay_presenter.clear()


func set_interaction_in_progress(
	value: bool
) -> void:
	_interaction_in_progress = value

	if value:
		grid_overlay_presenter.clear()
		action_preview_presenter.clear()
	else:
		refresh_grid_overlays()


func is_interaction_in_progress() -> bool:
	return _interaction_in_progress


func get_selected_ability() -> AbilityDefinition:
	return _selected_ability


func get_selected_ability_for(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	if (
		combatant.team_id == player_team_id
		and _selected_ability != null
		and combatant.has_ability(
			_selected_ability.ability_id
		)
		and not combatant.is_ability_locked(
			_selected_ability.ability_id
		)
		and not combatant.is_ability_restricted(
			_selected_ability.ability_id
		)
	):
		return _selected_ability

	return get_default_ability(
		combatant
	)


func get_default_ability(
	combatant: CombatantState
) -> AbilityDefinition:
	if combatant == null:
		return null

	var default_ability := (
		combatant.get_default_ability()
	)

	if (
		default_ability != null
		and not combatant.is_ability_locked(
			default_ability.ability_id
		)
		and not combatant
		.is_ability_restricted(
			default_ability.ability_id
		)
	):
		return default_ability

	for ability in combatant.get_abilities():
		if ability == null:
			continue

		if combatant.is_ability_locked(
			ability.ability_id
		):
			continue

		if combatant.is_ability_restricted(
			ability.ability_id
		):
			continue

		return ability

	return null


func get_active_combatant() -> CombatantState:
	if turn_controller == null:
		return null

	if not turn_controller.is_running:
		return null

	return turn_controller.active_combatant


func is_player_turn() -> bool:
	var active_combatant := get_active_combatant()

	return (
		active_combatant != null
		and active_combatant.team_id
		== player_team_id
	)


func end_active_turn() -> void:
	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	turn_controller.end_current_turn()


func handle_unhandled_input(
	event: InputEvent
) -> bool:
	if _interaction_in_progress:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	if key_event.keycode == KEY_T:
		_apply_debug_status_to_hovered_combatant()
		return true

	if (
		key_event.keycode == KEY_SPACE
		and is_player_turn()
	):
		end_active_turn()
		return true

	return false


func handle_input(
	event: InputEvent
) -> bool:
	if not (event is InputEventKey):
		return false

	var key_event := event as InputEventKey

	if (
		not key_event.pressed
		or key_event.echo
	):
		return false

	var ability_index := _get_ability_hotkey_index(
		key_event
	)

	if ability_index < 0:
		return false

	if turn_controller == null:
		return false

	if not turn_controller.is_running:
		return false

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
		or _interaction_in_progress
	):
		return false

	return ability_panel.select_ability_by_index(
		ability_index,
		true
	)


func on_ability_selected(
	ability: AbilityDefinition
) -> void:
	if ability == null:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	var active := turn_controller.active_combatant

	if (
		active == null
		or active.team_id != player_team_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if _interaction_in_progress:
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if not active.has_ability(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	if active.is_ability_locked(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		debug_log_presenter.set_headline(
			_get_ability_lock_message(
				active,
				ability
			)
		)

		return

	if active.is_ability_restricted(
		ability.ability_id
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		debug_log_presenter.set_headline(
			"«%s» сейчас запрещена активным статусом."
			% ability.display_name
		)

		return

	if not active.can_spend_stamina(
		ability.stamina_cost
	):
		ability_panel.set_selected_ability(
			_selected_ability
		)

		return

	_selected_ability = ability

	ability_panel.set_selected_ability(
		_selected_ability
	)

	refresh_grid_overlays()

	debug_log_presenter.set_headline(
		"%s выбирает «%s». "
		% [
			active.definition.display_name,
			ability.display_name,
		]
		+"Стоимость: %d выносливости."
		% ability.stamina_cost
	)


func on_grid_cell_hovered(
	coordinate: Vector2i
) -> void:
	_hovered_coordinate = coordinate

	refresh_hover_panels()

	if not _interaction_in_progress:
		refresh_grid_overlays()


func on_grid_cell_clicked(
	coordinate: Vector2i,
	mouse_button: int
) -> void:
	if _interaction_in_progress:
		return

	if turn_controller == null:
		return

	if not turn_controller.is_running:
		return

	if not is_player_turn():
		return

	var active_combatant := get_active_combatant()

	if active_combatant == null:
		return

	match mouse_button:
		MOUSE_BUTTON_LEFT:
			var ability := get_selected_ability_for(
				active_combatant
			)

			var target := _get_combatant_at_coordinate(
				coordinate
			)

			if (
				ability != null
				and targeting_service.can_target(
					session,
					active_combatant,
					ability,
					coordinate
				)
			):
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

			elif target == null:
				_try_move_active_combatant(
					active_combatant,
					coordinate
				)

			elif target == active_combatant:
				debug_log_presenter.set_headline(
					"%s уже находится на клетке %s."
					% [
						active_combatant
						.definition.display_name,
						coordinate,
					]
				)

			elif (
				target.team_id
				== active_combatant.team_id
			):
				_try_swap_with_ally(
					active_combatant,
					target
				)

			else:
				_try_use_ability_at(
					active_combatant,
					coordinate
				)

		MOUSE_BUTTON_RIGHT:
			_toggle_obstacle(
				coordinate
			)


func refresh_grid_overlays() -> void:
	if grid_overlay_presenter == null:
		return

	if turn_controller == null:
		grid_overlay_presenter.clear()
		return

	if not turn_controller.is_running:
		grid_overlay_presenter.clear()
		return

	var active := turn_controller.active_combatant

	if active == null:
		grid_overlay_presenter.clear()
		return

	var target_candidates: Array[CombatantState] = []

	for combatant in session.get_living_combatants():
		if combatant.team_id == active.team_id:
			continue

		target_candidates.append(
			combatant
		)

	var selected_ability := get_selected_ability_for(
		active
	)

	grid_overlay_presenter.refresh(
		session,
		active,
		target_candidates,
		selected_ability,
		_hovered_coordinate,
		stamina_cost_per_cell
	)

	refresh_hover_panels()
	_refresh_action_preview()


func _refresh_action_preview() -> void:
	if action_preview_presenter == null:
		return

	action_preview_presenter.clear()

	if (
		_interaction_in_progress
		or not is_player_turn()
		or _hovered_coordinate
			== BattleGridView.INVALID_COORDINATE
	):
		return

	var actor := get_active_combatant()

	if actor == null:
		return

	var ability := get_selected_ability_for(
		actor
	)

	if ability == null:
		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		_hovered_coordinate
	)

	var preview_result := (
		action_preview_service.create_preview(
			session,
			command
		)
	)

	if not preview_result.is_valid:
		return

	action_preview_presenter.show_preview(
		preview_result
	)

func refresh_hover_panels() -> void:
	var hovered_combatant := (
		_get_combatant_at_coordinate(
			_hovered_coordinate
		)
	)

	var has_living_combatant := (
		hovered_combatant != null
		and hovered_combatant.is_alive
	)

	_refresh_combatant_hover_panel(
		hovered_combatant
	)

	_refresh_surface_hover_panel(
		has_living_combatant
	)


func _refresh_combatant_hover_panel(
	hovered_combatant: CombatantState
) -> void:
	if combatant_hover_panel == null:
		return

	if (
		hovered_combatant == null
		or not hovered_combatant.is_alive
	):
		combatant_hover_panel.clear_combatant()
		return

	combatant_hover_panel.bind_combatant(
		hovered_combatant,
		player_team_id
	)


func _refresh_surface_hover_panel(
	has_combatant_neighbor: bool
) -> void:
	if surface_hover_panel == null:
		return

	if (
		session == null
		or session.surface_effect_controller == null
		or _hovered_coordinate
			== BattleGridView.INVALID_COORDINATE
	):
		surface_hover_panel.clear_surfaces()
		return

	var surface_instances := (
		session
		.surface_effect_controller
		.get_effects_at(
			_hovered_coordinate
		)
	)

	if surface_instances.is_empty():
		surface_hover_panel.clear_surfaces()
		return

	surface_hover_panel.show_surfaces(
		_hovered_coordinate,
		surface_instances,
		has_combatant_neighbor
	)

func _apply_debug_status_to_hovered_combatant() -> void:
	var target := _get_combatant_at_coordinate(
		_hovered_coordinate
	)

	debug_log_presenter.apply_debug_status(
		target,
		get_active_combatant()
	)


func _get_combatant_at_coordinate(
	coordinate: Vector2i
) -> CombatantState:
	if grid == null or session == null:
		return null

	var cell := grid.get_cell(
		coordinate
	)

	if cell == null or not cell.is_occupied():
		return null

	return session.get_combatant(
		cell.occupant_id
	)


func _try_swap_with_ally(
	active: CombatantState,
	ally: CombatantState
) -> void:
	if active == null or ally == null:
		return

	if not turn_controller.is_combatant_active(
		active
	):
		return

	var failure_code := (
		movement_service.get_ally_swap_failure(
			session,
			active,
			ally,
			stamina_cost_per_cell
		)
	)

	if failure_code != &"":
		debug_log_presenter.set_headline(
			_get_ally_swap_failure_message(
				failure_code,
				active,
				ally
			)
		)

		refresh_grid_overlays()
		return

	var active_origin := active.grid_position
	var ally_origin := ally.grid_position

	_interaction_in_progress = true
	grid_overlay_presenter.clear()
	action_preview_presenter.clear()

	debug_log_presenter.set_headline(
		"%s меняется местами с %s..."
		% [
			active.definition.display_name,
			ally.definition.display_name,
		]
	)

	var movement_outcome := await (
		movement_runner.execute_ally_swap(
			active,
			ally,
			stamina_cost_per_cell,
			animate_movement
		)
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Обмен позициями не выполнен: %s."
			% movement_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.set_headline(
		"%s и %s меняются местами: %s ↔ %s. "
		% [
			active.definition.display_name,
			ally.definition.display_name,
			active_origin,
			ally_origin,
		]
		+"Потрачено выносливости: %d. "
		% movement_outcome
			.relocation_result
			.stamina_spent
		+"Осталось: %d/%d."
		% [
			active.current_stamina,
			active.max_stamina,
		]
	)

	_interaction_in_progress = false
	refresh_grid_overlays()


func _try_move_active_combatant(
	combatant: CombatantState,
	target_coordinate: Vector2i
) -> void:
	if combatant == null:
		return

	if not turn_controller.is_combatant_active(
		combatant
	):
		return

	var plan := movement_service.create_plan(
		grid,
		combatant,
		target_coordinate,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		debug_log_presenter.set_headline(
			_get_movement_failure_message(
				plan.failure_code,
				plan,
				combatant
			)
		)

		refresh_grid_overlays()
		return

	var previous_coordinate := combatant.grid_position

	_interaction_in_progress = true
	grid_overlay_presenter.clear()
	action_preview_presenter.clear()

	debug_log_presenter.set_headline(
		"%s движется к клетке %s..."
		% [
			combatant.definition.display_name,
			plan.target_coordinate,
		]
	)

	var movement_outcome := await movement_runner.execute(
		grid,
		combatant,
		plan,
		animate_movement
	)

	if not movement_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Не удалось выполнить перемещение: %s."
			% movement_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.set_headline(
		"%s идёт %s → %s. Шагов: %d. "
		% [
			combatant.definition.display_name,
			previous_coordinate,
			plan.target_coordinate,
			movement_outcome.get_step_count(),
		]
		+"Потрачено выносливости: %d. "
		% plan.stamina_cost
		+"Осталось: %d/%d."
		% [
			combatant.current_stamina,
			combatant.max_stamina,
		]
	)

	_interaction_in_progress = false
	refresh_grid_overlays()


func _try_use_ability_at(
	actor: CombatantState,
	aim_coordinate: Vector2i
) -> void:
	if actor == null:
		return

	if not turn_controller.is_combatant_active(
		actor
	):
		return

	var ability := get_selected_ability_for(
		actor
	)

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% actor.definition.display_name
		)

		return

	var command := BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)

	var failure_code := action_runner.get_validation_failure(
		session,
		command
	)

	if failure_code != &"":
		debug_log_presenter.set_headline(
			_get_action_failure_message(
				failure_code,
				actor,
				ability
			)
		)

		refresh_grid_overlays()
		return

	_interaction_in_progress = true
	grid_overlay_presenter.clear()
	action_preview_presenter.clear()

	debug_log_presenter.suspend_status_signal_logging()

	var action_outcome := await action_runner.execute_action(
		session,
		command,
		animate_actions
	)

	debug_log_presenter.resume_status_signal_logging()

	if not action_outcome.is_successful:
		_interaction_in_progress = false

		debug_log_presenter.set_headline(
			"Действие не выполнено: %s."
			% action_outcome.failure_code
		)

		refresh_grid_overlays()
		return

	debug_log_presenter.append_action_results(
		action_outcome.action_result
	)

	if (
		action_outcome
		.action_result
		.cooldown_started
	):
		_selected_ability = get_default_ability(
			actor
		)

		ability_panel.set_selected_ability(
			_selected_ability
		)

	if turn_controller.is_finished:
		_interaction_in_progress = false
		return

	var damage_dealt := (
		action_outcome.get_total_applied_amount(
			&"damage"
		)
	)

	var affected_count := (
		action_outcome.get_affected_target_count()
	)

	var defeated_count := (
		action_outcome
		.get_defeated_target_ids()
		.size()
	)

	debug_log_presenter.set_headline(
		"%s использует «%s» по клетке %s. "
		% [
			actor.definition.display_name,
			ability.display_name,
			aim_coordinate,
		]
		+"Задето целей: %d. "
		% affected_count
		+"Общий урон: %d. "
		% damage_dealt
		+"Погибло целей: %d. "
		% defeated_count
		+"Выносливость: %d/%d."
		% [
			actor.current_stamina,
			actor.max_stamina,
		]
	)

	_interaction_in_progress = false
	refresh_grid_overlays()


func _toggle_obstacle(
	coordinate: Vector2i
) -> void:
	var cell := grid.get_cell(
		coordinate
	)

	if cell == null:
		return

	if cell.is_occupied():
		debug_log_presenter.set_headline(
			"Нельзя поставить препятствие под бойца."
		)
		return

	if cell.has_obstacle():
		var obstacle_id := cell.obstacle_id

		grid.remove_obstacle(
			obstacle_id
		)

		debug_log_presenter.set_headline(
			"Препятствие удалено с клетки %s."
			% coordinate
		)

		refresh_grid_overlays()
		return

	_obstacle_counter += 1

	var new_obstacle_id := StringName(
		"debug_obstacle_%d"
		% _obstacle_counter
	)

	if not grid.try_place_obstacle(
		new_obstacle_id,
		coordinate
	):
		debug_log_presenter.set_headline(
			"Не удалось поставить препятствие."
		)
		return

	debug_log_presenter.set_headline(
		"Препятствие установлено на клетку %s."
		% coordinate
	)

	refresh_grid_overlays()


func _get_ability_hotkey_index(
	event: InputEventKey
) -> int:
	var keycodes: Array[int] = [
		event.keycode,
		event.physical_keycode,
	]

	for keycode in keycodes:
		match keycode:
			KEY_1:
				return 0

			KEY_2:
				return 1

			KEY_3:
				return 2

			KEY_4:
				return 3

			KEY_5:
				return 4

			KEY_6:
				return 5

			KEY_7:
				return 6

			KEY_8:
				return 7

			KEY_9:
				return 8

	return -1


func _get_action_failure_message(
	failure_code: StringName,
	actor: CombatantState,
	ability: AbilityDefinition
) -> String:
	match failure_code:
		BattleTargetingService.FAILURE_AIM_NOT_IN_PATTERN:
			return (
				"Выбранная клетка не входит в зону "
				+"досягаемости способности."
			)

		BattleTargetingService.FAILURE_AIM_OUTSIDE_GRID:
			return (
				"Выбранная клетка находится "
				+"за пределами поля."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_OCCUPIED:
			return (
				"Для этой способности нужно выбрать "
				+"занятую клетку."
			)

		BattleTargetingService.FAILURE_AIM_CELL_MUST_BE_EMPTY:
			return (
				"Для этой способности нужно выбрать "
				+"пустую клетку."
			)

		BattleTargetingService.FAILURE_INVALID_AIM_RELATION:
			return (
				"Эта способность не может быть "
				+"применена к выбранному бойцу."
			)

		BattleTargetingService.FAILURE_TARGET_PROTECTED_BY_BLOCKER:
			return (
				"Цель защищена боевым объектом, "
				+"стоящим перед ней."
			)

		BattleActionService.FAILURE_NOT_ENOUGH_STAMINA:
			var cost := (
				ability.stamina_cost
				if ability != null
				else 0
			)

			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					cost,
					actor.current_stamina,
				]
			)

		BattleActionService.FAILURE_ABILITY_ON_COOLDOWN:
			return _get_ability_lock_message(
				actor,
				ability
			)

		BattleActionService.FAILURE_ABILITY_RESTRICTED:
			return (
				"Боец не может использовать "
				+"эту способность из-за статуса."
			)

		BattleActionService.FAILURE_ABILITY_NOT_IN_LOADOUT:
			return (
				"Выбранная способность отсутствует "
				+"в loadout бойца."
			)

		BattleTargetingService.FAILURE_ACTOR_DEAD:
			return (
				"Погибший боец не может "
				+"использовать способности."
			)

		BattleSurfaceEffectController.FAILURE_SURFACE_CELL_HAS_OBSTACLE:
			return (
				"На клетке находится препятствие. "
				+"Поверхность здесь создать нельзя."
			)

		BattleSurfaceEffectController.FAILURE_INVALID_SURFACE_COORDINATE:
			return (
				"Поверхность нельзя создать "
				+"за пределами поля."
			)

		BattleSurfaceEffectController.FAILURE_INVALID_SURFACE_DEFINITION:
			return (
				"Способность содержит некорректную "
				+"поверхность."
			)

		BattleActionService.FAILURE_NO_AFFECTED_COORDINATES:
			return (
				"Способность не затрагивает "
				+"ни одной клетки поля."
			)

		_:
			return (
				"Действие невозможно: %s."
				% failure_code
			)


func _get_ability_lock_message(
	actor: CombatantState,
	ability: AbilityDefinition
) -> String:
	if actor == null or ability == null:
		return "Способность временно недоступна."

	var remaining_turns := (
		actor.get_ability_lock_remaining_turns(
			ability.ability_id
		)
	)

	var formatted_turns := (
		BattleAbilityPresentationBuilder
		.format_turn_count(
			remaining_turns
		)
	)

	if (
		actor.get_ability_lock_kind(
			ability.ability_id
		)
		== CombatantState
		.AbilityLockKind
		.INITIAL
	):
		return (
			"«%s» ещё закрыта стартовой задержкой. "
			% ability.display_name
			+"Осталось: %s."
			% formatted_turns
		)

	return (
		"«%s» восстанавливается. "
		% ability.display_name
		+"Осталось: %s."
		% formatted_turns
	)


func _get_ally_swap_failure_message(
	failure_code: StringName,
	active: CombatantState,
	ally: CombatantState
) -> String:
	match failure_code:
		BattleRelocationService.FAILURE_NOT_ADJACENT:
			return (
				"С %s можно поменяться местами "
				% ally.definition.display_name
				+"только с соседней клетки."
			)

		BattleRelocationService.FAILURE_TEAM_MISMATCH:
			return "Обычный обмен доступен только с союзником."

		BattleRelocationService.FAILURE_POSITION_LOCKED:
			return (
				"%s является неподвижным объектом."
				% ally.definition.display_name
			)

		BattleRelocationService.FAILURE_MOVEMENT_RESTRICTED:
			return (
				"Обмен невозможен: один из бойцов "
				+"не может двигаться."
			)

		BattleRelocationService.FAILURE_NOT_ENOUGH_STAMINA:
			return (
				"Недостаточно выносливости для обмена. "
				+"Нужно: %d, доступно: %d."
				% [
					stamina_cost_per_cell,
					active.current_stamina,
				]
			)

		BattleRelocationService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может менять позицию."

		_:
			return (
				"Обмен позициями невозможен: %s."
				% failure_code
			)

			
func _get_movement_failure_message(
	failure_code: StringName,
	plan: BattleMovementPlan,
	combatant: CombatantState
) -> String:
	match failure_code:
		BattleMovementService.FAILURE_TARGET_IS_START:
			return (
				"%s уже находится на выбранной клетке."
				% combatant.definition.display_name
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_TEAM_SIDE:
			return (
				"Обычным движением нельзя переходить "
				+"на сторону противника."
			)

		BattleMovementService.FAILURE_TARGET_BLOCKED:
			return (
				"Клетка %s занята или заблокирована."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NO_PATH:
			return (
				"До клетки %s невозможно построить маршрут."
				% plan.target_coordinate
			)

		BattleMovementService.FAILURE_NOT_ENOUGH_STAMINA:
			return (
				"Недостаточно выносливости. "
				+"Нужно: %d, доступно: %d."
				% [
					plan.stamina_cost,
					combatant.current_stamina,
				]
			)

		BattleMovementService.FAILURE_TARGET_OUTSIDE_GRID:
			return "Цель находится за пределами поля."

		BattleMovementService.FAILURE_MOVEMENT_RESTRICTED:
			return (
				"Боец не может двигаться "
				+"из-за активного статуса."
			)

		BattleMovementService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может двигаться."

		_:
			return (
				"Перемещение невозможно: %s."
				% failure_code
			)
```

---

## FILE: `scenes/debug/presentation/battle_debug_log_presenter.gd`
```gdscript
class_name BattleDebugLogPresenter
extends RefCounted


var status_label: Label
var session: BattleSession
var debug_status_definition: BattleStatusDefinition
var max_battle_log_lines: int = 6

var _status_headline: String = ""
var _battle_log_lines := PackedStringArray()
var _status_signal_logging_suspended: bool = false


func _init(
	p_status_label: Label,
	p_session: BattleSession,
	p_debug_status_definition: BattleStatusDefinition = null,
	p_max_battle_log_lines: int = 6
) -> void:
	assert(
		p_status_label != null,
		"BattleDebugLogPresenter requires a status label."
	)
	assert(
		p_session != null,
		"BattleDebugLogPresenter requires a battle session."
	)

	status_label = p_status_label
	session = p_session
	debug_status_definition = p_debug_status_definition
	max_battle_log_lines = maxi(
		1,
		p_max_battle_log_lines
	)


func connect_combatant(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	var added_callback := Callable(
		self,
		"_on_combatant_status_added"
	).bind(
		combatant
	)

	var updated_callback := Callable(
		self,
		"_on_combatant_status_updated"
	).bind(
		combatant
	)

	var removed_callback := Callable(
		self,
		"_on_combatant_status_removed"
	).bind(
		combatant
	)

	if not combatant.is_connected(
		&"status_added",
		added_callback
	):
		combatant.connect(
			&"status_added",
			added_callback
		)

	if not combatant.is_connected(
		&"status_updated",
		updated_callback
	):
		combatant.connect(
			&"status_updated",
			updated_callback
		)

	if not combatant.is_connected(
		&"status_removed",
		removed_callback
	):
		combatant.connect(
			&"status_removed",
			removed_callback
		)


func set_headline(
	message: String
) -> void:
	_status_headline = message
	_refresh_status_label()


func push_battle_log(
	message: String
) -> void:
	if message.strip_edges().is_empty():
		return

	_battle_log_lines.append(
		message
	)

	while (
		_battle_log_lines.size()
		> max_battle_log_lines
	):
		_battle_log_lines.remove_at(0)

	print(message)

	_refresh_status_label()

func suspend_status_signal_logging() -> void:
	_status_signal_logging_suspended = true


func resume_status_signal_logging() -> void:
	_status_signal_logging_suspended = false

func apply_debug_status(
	target: CombatantState,
	source: CombatantState = null
) -> bool:
	if debug_status_definition == null:
		set_headline(
			"Debug-статус не назначен в Inspector."
		)

		return false

	if not debug_status_definition.is_valid_definition():
		set_headline(
			"Назначен некорректный debug-статус."
		)

		return false

	if target == null:
		set_headline(
			"Наведи курсор на бойца и нажми T."
		)

		return false

	var source_instance_id: StringName = &""

	if source != null:
		source_instance_id = source.instance_id

	var applied_status := target.add_status(
		debug_status_definition,
		source_instance_id
	)

	if applied_status == null:
		set_headline(
			"Не удалось применить debug-статус."
		)

		return false

	set_headline(
		"%s: %s. Текущая броня: %d."
		% [
			target.definition.display_name,
			format_status_for_player(
				applied_status
			),
			target.get_effective_armor(),
		]
	)

	return true


func get_status_summary(
	combatant: CombatantState
) -> String:
	if combatant == null:
		return "нет"

	var statuses := combatant.get_active_statuses()

	if statuses.is_empty():
		return "нет"

	var parts := PackedStringArray()

	for status in statuses:
		if status == null:
			continue

		parts.append(
			format_status_for_player(
				status
			)
		)

	if parts.is_empty():
		return "нет"

	return "; ".join(parts)


func format_status_for_player(
	status: BattleStatusInstance
) -> String:
	if (
		status == null
		or status.definition == null
	):
		return "Неизвестный статус"

	var title := status.definition.display_name

	if status.stack_count > 1:
		title += " ×%d" % status.stack_count

	var effects := PackedStringArray()

	var armor_modifier := get_status_stat_modifier_amount(
		status,
		BattleStatModifier.Stat.ARMOR
	)

	if armor_modifier != 0:
		effects.append(
			"броня %s"
			% format_signed_integer(
				armor_modifier
			)
		)

	var has_turn_start_trigger := false
	var has_turn_end_trigger := false

	for trigger in (
		status.definition.periodic_triggers
	):
		if trigger == null:
			continue

		match trigger.timing:
			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
				has_turn_start_trigger = true

			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
				has_turn_end_trigger = true

	if has_turn_start_trigger:
		effects.append(
			"эффект в начале хода"
		)

	if has_turn_end_trigger:
		effects.append(
			"эффект в конце хода"
		)

	var action_restriction := (
		status.definition.action_restriction
	)

	if action_restriction != null:
		if action_restriction.skip_owner_turn:
			effects.append(
				"пропуск хода"
			)

		else:
			if action_restriction.block_movement:
				effects.append(
					"запрет движения"
				)

			if action_restriction.block_all_abilities:
				effects.append(
					"запрет способностей"
				)

			elif not (
				action_restriction
				.blocked_ability_ids
				.is_empty()
			):
				effects.append(
					"запрещено способностей: %d"
					% action_restriction
					.blocked_ability_ids
					.size()
				)

	if effects.is_empty():
		effects.append(
			"без активных модификаторов"
		)

	return (
		"%s — %s, осталось %s"
		% [
			title,
			", ".join(effects),
			format_turn_count(
				status.remaining_turns
			),
		]
	)


func append_action_results(
	action_result: BattleActionResult
) -> void:
	if action_result == null:
		return

	for effect_result in (
		action_result.effect_results
	):
		if effect_result == null:
			continue

		if not effect_result.is_successful:
			continue

		match effect_result.effect_kind:
			&"damage":
				_append_damage_result(
					effect_result
				)

			&"heal":
				_append_heal_result(
					effect_result
				)

			&"grant_guard":
				_append_guard_result(
					effect_result
				)

			&"apply_status":
				_append_status_result(
					effect_result
				)

			&"remove_status":
				_append_remove_status_result(
					effect_result
				)

			&"forced_movement":
				_append_forced_movement_result(
					effect_result
				)

			&"place_surface":
				_append_place_surface_result(
					effect_result
				)

func append_surface_trigger_result(
	trigger_result: BattleSurfaceTriggerResult
) -> void:
	if trigger_result == null:
		return

	var target := session.get_combatant(
		trigger_result.target_id
	)

	var target_name := String(
		trigger_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var surface_name := (
		trigger_result.surface_display_name
	)

	if surface_name.strip_edges().is_empty():
		surface_name = String(
			trigger_result.surface_effect_id
		)

	push_battle_log(
		"«%s» срабатывает на клетке %s для %s (%s)."
		% [
			surface_name,
			trigger_result.coordinate,
			target_name,
			format_surface_timing(
				trigger_result.timing
			),
		]
	)

	for effect_result in (
		trigger_result.effect_results
	):
		if effect_result == null:
			continue

		if not effect_result.is_successful:
			push_battle_log(
				"Эффект поверхности не выполнен: %s."
				% effect_result.failure_code
			)

			continue

		match effect_result.effect_kind:
			&"damage":
				_append_damage_result(
					effect_result
				)

			&"heal":
				_append_heal_result(
					effect_result
				)

			&"grant_guard":
				_append_guard_result(
					effect_result
				)

			&"apply_status":
				## Изменение уже отображается
				## через status-сигналы.
				pass

			&"remove_status":
				_append_remove_status_result(
					effect_result
				)

			&"forced_movement":
				_append_forced_movement_result(
					effect_result
				)

	if trigger_result.was_consumed:
		push_battle_log(
			"«%s» исчезает после срабатывания."
			% surface_name
		)

func append_periodic_trigger_results(
	combatant: CombatantState,
	timing: int,
	trigger_results: Array[
		BattleStatusPeriodicTriggerResult
	]
) -> void:
	if combatant == null:
		return

	for trigger_result in trigger_results:
		if trigger_result == null:
			continue

		var status_name := (
			trigger_result.status_display_name
		)

		if status_name.strip_edges().is_empty():
			status_name = String(
				trigger_result.status_id
			)

		push_battle_log(
			"«%s» срабатывает у %s %s."
			% [
				status_name,
				combatant.definition.display_name,
				format_periodic_timing(
					timing
				),
			]
		)

		for effect_result in (
			trigger_result.effect_results
		):
			if effect_result == null:
				continue

			if not effect_result.is_successful:
				push_battle_log(
					"Периодический эффект не выполнен: %s."
					% effect_result.failure_code
				)

				continue

			match effect_result.effect_kind:
				&"damage":
					_append_damage_result(
						effect_result
					)

				&"heal":
					_append_heal_result(
						effect_result
					)

				&"grant_guard":
					_append_guard_result(
						effect_result
					)

				# ApplyStatusEffect уже сообщает
				# об изменении через status-сигналы.
				&"apply_status":
					pass


func _append_place_surface_result(
	effect_result: BattleEffectResult
) -> void:
	var surface_name := (
		effect_result.surface_display_name
	)

	if surface_name.strip_edges().is_empty():
		surface_name = String(
			effect_result.surface_effect_id
		)

	var action_text := "размещена"

	if effect_result.surface_was_added:
		action_text = "создана"

	elif effect_result.surface_was_updated:
		action_text = "обновлена"

	var duration_text := "постоянная"

	if not effect_result.surface_is_permanent:
		duration_text = format_round_count(
			effect_result
				.current_surface_remaining_rounds
		)

	push_battle_log(
		"На клетке %s %s поверхность «%s». "
		% [
			effect_result.effect_coordinate,
			action_text,
			surface_name,
		]
		+"Длительность: %s."
		% duration_text
	)


func _append_damage_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var armor_text := (
		"%d"
		% effect_result.target_base_armor
	)

	if (
		effect_result
		.target_status_armor_modifier != 0
	):
		armor_text += (
			" %s от статусов = %d"
			% [
				format_signed_integer(
					effect_result
					.target_status_armor_modifier
				),
				effect_result
				.target_modified_armor,
			]
		)

	var critical_text: String

	if not effect_result.critical_was_enabled:
		critical_text = "крит — отключён"

	elif effect_result.critical_was_guaranteed:
		critical_text = (
			"КРИТ — гарантирован"
			+", множитель ×%s"
			% format_decimal(
				effect_result
					.critical_multiplier
			)
		)

	elif effect_result.was_critical:
		critical_text = (
			"КРИТ — ДА"
			+", шанс %d%%"
			% effect_result
				.critical_chance_percent
			+", бросок %d"
			% effect_result
				.critical_roll_percent
			+", множитель ×%s"
			% format_decimal(
				effect_result
					.critical_multiplier
			)
		)

	else:
		critical_text = (
			"крит — нет"
			+", шанс %d%%"
			% effect_result
				.critical_chance_percent
			+", бросок %d"
			% effect_result
				.critical_roll_percent
		)

	var guard_text: String

	if effect_result.guard_was_bypassed:
		guard_text = (
			"оборона проигнорирована "
			+"(было %d)"
			% effect_result.previous_guard
		)

	else:
		guard_text = (
			"оборона: %d → %d, поглощено %d"
			% [
				effect_result.previous_guard,
				effect_result.current_guard,
				effect_result
					.guard_absorbed_amount,
			]
		)

	var message := (
		"%s: сырой урон до крита — %d; "
		% [
			target_name,
			effect_result
				.raw_amount_before_critical,
		]
		+"%s; "
		% critical_text
		+"сырой урон после крита — %d; "
		% effect_result.raw_amount
		+"броня — %s; "
		% armor_text
		+"пробитие — %d; "
		% effect_result.armor_piercing
		+"итоговая броня — %d; "
		% effect_result.effective_armor
		+"урон после брони — %d; "
		% effect_result.resolved_amount
		+"%s; "
		% guard_text
		+"потеря HP — %d; "
		% effect_result.applied_amount
		+"overkill — %d."
		% effect_result.overkill_amount
	)

	if effect_result.target_died:
		message += " Цель погибает."

	push_battle_log(
		message
	)


func _append_heal_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s: расчётное лечение — %d; "
		% [
			target_name,
			effect_result.resolved_amount,
		]
		+"восстановлено HP — %d; "
		% effect_result.applied_amount
		+"overheal — %d. "
		% effect_result.overheal_amount
		+"Здоровье: %d → %d."
		% [
			effect_result.previous_value,
			effect_result.current_value,
		]
	)

	push_battle_log(
		message
	)


func _append_guard_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s получает оборону: +%d; "
		% [
			target_name,
			effect_result.applied_amount,
		]
		+"оборона %d → %d."
		% [
			effect_result.previous_guard,
			effect_result.current_guard,
		]
	)

	if effect_result.overguard_amount > 0:
		message += (
			" Сверх лимита потеряно: %d."
			% effect_result.overguard_amount
		)

	push_battle_log(
		message
	)

func _append_remove_status_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	if (
		effect_result
		.removed_status_display_names
		.is_empty()
	):
		push_battle_log(
			"%s: подходящих статусов для снятия нет."
			% target_name
		)

		return

	var status_parts := PackedStringArray()

	for status_name in (
		effect_result
		.removed_status_display_names
	):
		status_parts.append(
			"«%s»"
			% status_name
		)

	var message := (
		"%s: сняты статусы — %s."
		% [
			target_name,
			", ".join(
				status_parts
			),
		]
	)

	if (
		effect_result
			.previous_target_effective_armor
		!= effect_result
			.current_target_effective_armor
	):
		message += (
			" Броня: %d → %d."
			% [
				effect_result
					.previous_target_effective_armor,
				effect_result
					.current_target_effective_armor,
			]
		)

	push_battle_log(
		message
	)


func _append_forced_movement_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s принудительно перемещается "
		% target_name
		+"на %d/%d клеток: %s → %s."
		% [
			effect_result
				.applied_movement_distance,
			effect_result
				.requested_movement_distance,
			effect_result.movement_origin,
			effect_result.movement_destination,
		]
	)

	if effect_result.movement_was_blocked:
		message += (
			" Дальнейшее движение остановлено: %s."
			% format_forced_movement_block_reason(
				effect_result
				.movement_block_reason
			)
		)

	push_battle_log(
		message
	)


func _append_status_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var status_name := (
		effect_result.status_display_name
	)

	if status_name.strip_edges().is_empty():
		status_name = String(
			effect_result.status_id
		)

	if (
		effect_result
		.status_application_blocked_by_immunity
	):
		var immunity_reason := ""

		match effect_result.status_immunity_kind:
			&"status_id":
				immunity_reason = (
					"иммунитет к конкретному статусу"
				)

			&"tag":
				immunity_reason = (
					"иммунитет по тегу «%s»"
					% effect_result
						.status_immunity_value
				)

			_:
				immunity_reason = (
					"постоянный иммунитет"
				)

		push_battle_log(
			"%s: «%s» не наложено — ИММУНИТЕТ (%s)."
			% [
				target_name,
				status_name,
				immunity_reason,
			]
		)

		return

	if target != null:
		var status := target.get_status(
			effect_result.status_id
		)

		if (
			status != null
			and status.definition != null
		):
			status_name = (
				status.definition.display_name
			)

	var message: String

	if effect_result.status_was_added:
		message = (
			"%s получает «%s»."
			% [
				target_name,
				status_name,
			]
		)
	else:
		message = (
			"«%s» у %s обновляется."
			% [
				status_name,
				target_name,
			]
		)

	if (
		effect_result
		.previous_target_effective_armor
		!= effect_result
		.current_target_effective_armor
	):
		message += (
			" Броня: %d → %d."
			% [
				effect_result
				.previous_target_effective_armor,
				effect_result
				.current_target_effective_armor,
			]
		)

	if (
		effect_result
		.previous_status_stack_count
		!= effect_result
		.current_status_stack_count
		and effect_result
		.current_status_stack_count > 1
	):
		message += (
			" Стаки: %d → %d."
			% [
				effect_result
				.previous_status_stack_count,
				effect_result
				.current_status_stack_count,
			]
		)

	if effect_result.status_was_added:
		message += (
			" Длительность: %s."
			% format_turn_count(
				effect_result
				.current_status_remaining_turns
			)
		)

	elif (
		effect_result
		.previous_status_remaining_turns
		!= effect_result
		.current_status_remaining_turns
	):
		message += (
			" Длительность: %s → %s."
			% [
				format_turn_count(
					effect_result
					.previous_status_remaining_turns
				),
				format_turn_count(
					effect_result
					.current_status_remaining_turns
				),
			]
		)

	push_battle_log(
		message
	)


func get_status_stat_modifier_amount(
	status: BattleStatusInstance,
	stat: int
) -> int:
	if (
		status == null
		or status.definition == null
	):
		return 0

	var total: int = 0

	for modifier in status.definition.stat_modifiers:
		if modifier == null:
			continue

		if modifier.stat != stat:
			continue

		total += modifier.get_total_amount(
			status.stack_count
		)

	return total

func format_decimal(
	value: float
) -> String:
	return str(
		snappedf(
			value,
			0.01
		)
	)


func format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


func format_round_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d раундов" % value

	if last_digit == 1:
		return "%d раунд" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d раунда" % value

	return "%d раундов" % value
	
func format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value


func format_periodic_timing(
	timing: int
) -> String:
	match timing:
		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
			return "в начале хода"

		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
			return "в конце хода"

	return "в неизвестный момент"


func format_surface_timing(
	timing: int
) -> String:
	match timing:
		BattleSurfaceEffectDefinition.TriggerTiming.ON_ENTER:
			return "при входе"

		BattleSurfaceEffectDefinition.TriggerTiming.OWNER_TURN_START:
			return "в начале хода"

		BattleSurfaceEffectDefinition.TriggerTiming.OWNER_TURN_END:
			return "в конце хода"

	return "неизвестный момент"

func format_forced_movement_block_reason(
	reason: StringName
) -> String:
	match reason:
		BattleForcedMovementService.BLOCK_OUTSIDE_GRID:
			return "граница поля"

		BattleForcedMovementService.BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED:
			return "клетка занята или заблокирована"

		BattleForcedMovementService.BLOCK_SURFACE_EFFECT:
			return "сработал эффект клетки"

	return String(reason)


func _refresh_status_label() -> void:
	var text := _status_headline

	if not _battle_log_lines.is_empty():
		if not text.is_empty():
			text += "\n\n"

		text += "Журнал боя:\n• "
		text += "\n• ".join(
			_battle_log_lines
		)

	status_label.text = text


func _on_combatant_status_added(
	status: BattleStatusInstance,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var status_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		- status_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message := (
		"%s получает «%s»."
		% [
			combatant.definition.display_name,
			status.definition.display_name,
		]
	)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	message += (
		" Длительность: %s."
		% format_turn_count(
			status.remaining_turns
		)
	)

	push_battle_log(
		message
	)


func _on_combatant_status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var current_status_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_status_modifier: int = 0

	if (
		status != null
		and status.definition != null
	):
		for modifier in status.definition.stat_modifiers:
			if (
				modifier != null
				and modifier.stat
				== BattleStatModifier.Stat.ARMOR
			):
				previous_status_modifier += (
					modifier.get_total_amount(
						previous_stack_count
					)
				)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_modifier_total := (
		current_modifier_total
		- current_status_modifier
		+ previous_status_modifier
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ previous_modifier_total
	)

	var current_armor := combatant.get_effective_armor()

	var changes := PackedStringArray()

	if previous_stack_count != status.stack_count:
		changes.append(
			"стаки: %d → %d"
			% [
				previous_stack_count,
				status.stack_count,
			]
		)

	if previous_armor != current_armor:
		changes.append(
			"броня: %d → %d"
			% [
				previous_armor,
				current_armor,
			]
		)

	if previous_remaining_turns != status.remaining_turns:
		if status.remaining_turns > previous_remaining_turns:
			changes.append(
				"длительность обновлена: %s → %s"
				% [
					format_turn_count(
						previous_remaining_turns
					),
					format_turn_count(
						status.remaining_turns
					),
				]
			)
		else:
			changes.append(
				"осталось %s"
				% format_turn_count(
					status.remaining_turns
				)
			)

	if changes.is_empty():
		changes.append("обновлён")

	push_battle_log(
		"«%s» у %s: %s."
		% [
			status.definition.display_name,
			combatant.definition.display_name,
			", ".join(changes),
		]
	)


func _on_combatant_status_removed(
	status: BattleStatusInstance,
	reason: StringName,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var removed_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		+ removed_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message: String

	match reason:
		&"expired":
			message = (
				"«%s» у %s заканчивается."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		&"owner_defeated":
			message = (
				"«%s» снимается после гибели %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		_:
			message = (
				"«%s» снимается с %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	push_battle_log(
		message
	)
```

---


## ✅ STATS
- Total files in tree: 135
- Readable files: 131
- Included files written: 10
- Trimmed files: 0
- Total lines written: 5955
