# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/actions/battle_action_service.gd', 'core/battle/movement/battle_movement_service.gd', 'core/battle/turns/battle_turn_controller.gd', 'presentation/battle/grid/battle_grid_overlay_presenter.gd', 'scenes/debug/controllers/battle_sandbox_interaction_controller.gd', 'scenes/debug/battle_grid_sandbox.gd', 'core/battle/ai/basic_melee_ai_controller.gd', 'presentation/battle/ai/basic_melee_ai_turn_runner.gd']`
- Allow addons: `False`
- Included files planned: `8`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_bandage.tres
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_rending_cut.tres
│   │       ├── debug_sabre_slash.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       └── debug_steppe_raider.tres
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
│   └── statuses
│       └── debug
│           ├── debug_bleeding.tres
│           ├── debug_cracked_defense.tres
│           └── debug_regeneration.tres
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
│       │   └── heal_effect.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
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
│   │   └── movement
│   │       ├── battle_movement_outcome.gd
│   │       └── battle_movement_runner.gd
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

## FILE: `core/battle/actions/battle_action_service.gd`
```gdscript
class_name BattleActionService
extends RefCounted


const FAILURE_INVALID_SESSION: StringName = (
	&"invalid_session"
)

const FAILURE_INVALID_COMMAND: StringName = (
	&"invalid_command"
)

const FAILURE_INVALID_ACTOR: StringName = (
	&"invalid_actor"
)

const FAILURE_INVALID_ABILITY: StringName = (
	&"invalid_ability"
)

const FAILURE_INVALID_ABILITY_DEFINITION: StringName = (
	&"invalid_ability_definition"
)

const FAILURE_ABILITY_NOT_IN_LOADOUT: StringName = (
	&"ability_not_in_loadout"
)

const FAILURE_NOT_ENOUGH_STAMINA: StringName = (
	&"not_enough_stamina"
)

const FAILURE_UNSUPPORTED_EFFECT: StringName = (
	&"unsupported_effect"
)

const FAILURE_STAMINA_SPEND_FAILED: StringName = (
	&"stamina_spend_failed"
)

const FAILURE_EFFECT_RESOLUTION_FAILED: StringName = (
	&"effect_resolution_failed"
)


var targeting_service: BattleTargetingService
var effect_resolver := EffectResolver.new()


func _init(
	p_targeting_service: BattleTargetingService
) -> void:
	assert(
		p_targeting_service != null,
		"BattleActionService requires "
		+"BattleTargetingService."
	)

	targeting_service = p_targeting_service


func execute(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleActionResult:
	var result := _create_result(
		command
	)

	var failure_code := (
		_get_validation_failure(
			session,
			command
		)
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var targeting_result := (
		targeting_service.create_result(
			session,
			command.actor,
			command.ability,
			command.aim_coordinate
		)
	)

	if not targeting_result.is_valid:
		result.failure_code = (
			targeting_result.failure_code
		)

		return result

	for coordinate in (
		targeting_result.affected_coordinates
	):
		result.affected_coordinates.append(
			coordinate
		)

	for target in (
		targeting_result.affected_combatants
	):
		result.affected_target_ids.append(
			target.instance_id
		)

	if not command.actor.spend_stamina(
		command.ability.stamina_cost
	):
		result.failure_code = (
			FAILURE_STAMINA_SPEND_FAILED
		)

		return result

	result.stamina_spent = (
		command.ability.stamina_cost
	)

	# Стоимость списана один раз.
	# Эффекты применяются ко всем найденным целям.
	for target in (
		targeting_result.affected_combatants
	):
		if target == null or not target.is_alive:
			continue

		for effect in command.ability.effects:
			if not target.is_alive:
				break

			var effect_result := (
				effect_resolver.resolve(
					effect,
					command.actor,
					target
				)
			)

			result.effect_results.append(
				effect_result
			)

			if not effect_result.is_successful:
				result.failure_code = (
					FAILURE_EFFECT_RESOLUTION_FAILED
				)

				return result

	result.is_successful = true
	return result


func can_execute(
	session: BattleSession,
	command: BattleActionCommand
) -> bool:
	return _get_validation_failure(
		session,
		command
	) == &""


func get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	return _get_validation_failure(
		session,
		command
	)


func get_targeting_result(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleTargetingResult:
	if command == null:
		return BattleTargetingResult.new()

	return targeting_service.create_result(
		session,
		command.actor,
		command.ability,
		command.aim_coordinate
	)


func _get_validation_failure(
	session: BattleSession,
	command: BattleActionCommand
) -> StringName:
	if session == null:
		return FAILURE_INVALID_SESSION

	if command == null:
		return FAILURE_INVALID_COMMAND

	var actor := command.actor
	var ability := command.ability

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if ability == null:
		return FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY_DEFINITION

	if not actor.has_ability(
		ability.ability_id
	):
		return FAILURE_ABILITY_NOT_IN_LOADOUT

	var targeting_failure := (
		targeting_service.get_validation_failure(
			session,
			actor,
			ability,
			command.aim_coordinate
		)
	)

	if targeting_failure != &"":
		return targeting_failure

	if not actor.can_spend_stamina(
		ability.stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	for effect in ability.effects:
		if not effect_resolver.can_resolve(
			effect
		):
			return FAILURE_UNSUPPORTED_EFFECT

	return &""


func _create_result(
	command: BattleActionCommand
) -> BattleActionResult:
	var result := BattleActionResult.new()

	if command == null:
		return result

	result.aim_coordinate = (
		command.aim_coordinate
	)

	if command.actor != null:
		result.actor_id = (
			command.actor.instance_id
		)

	if command.ability != null:
		result.ability_id = (
			command.ability.ability_id
		)

		result.stamina_cost = (
			command.ability.stamina_cost
		)

	return result
```

---

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
		+ "a movement service."
	)

	assert(
		p_action_service != null,
		"BasicMeleeAIController requires "
		+ "an action service."
	)

	assert(
		p_targeting_service != null,
		"BasicMeleeAIController requires "
		+ "a targeting service."
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

## FILE: `core/battle/movement/battle_movement_service.gd`
```gdscript
class_name BattleMovementService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMBATANT: StringName = &"invalid_combatant"
const FAILURE_DEAD_COMBATANT: StringName = &"dead_combatant"
const FAILURE_INVALID_COST: StringName = &"invalid_cost"
const FAILURE_INVALID_START: StringName = &"invalid_start"
const FAILURE_TARGET_OUTSIDE_GRID: StringName = &"target_outside_grid"
const FAILURE_TARGET_OUTSIDE_TEAM_SIDE: StringName = (
	&"target_outside_team_side"
)
const FAILURE_TARGET_IS_START: StringName = &"target_is_start"
const FAILURE_TARGET_BLOCKED: StringName = &"target_blocked"
const FAILURE_NO_PATH: StringName = &"no_path"
const FAILURE_NOT_ENOUGH_STAMINA: StringName = &"not_enough_stamina"


var side_rules: BattleSideRules


func _init(
	p_side_rules: BattleSideRules
) -> void:
	assert(
		p_side_rules != null,
		"BattleMovementService requires BattleSideRules."
	)

	side_rules = p_side_rules


func create_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	target_coordinate: Vector2i,
	stamina_cost_per_step: int = 1
) -> BattleMovementPlan:
	var plan := BattleMovementPlan.new()

	plan.target_coordinate = target_coordinate
	plan.stamina_cost_per_step = stamina_cost_per_step

	if grid == null:
		plan.failure_code = FAILURE_INVALID_GRID
		return plan

	if combatant == null:
		plan.failure_code = FAILURE_INVALID_COMBATANT
		return plan

	plan.combatant_id = combatant.instance_id
	plan.start_coordinate = combatant.grid_position

	if not combatant.is_alive:
		plan.failure_code = FAILURE_DEAD_COMBATANT
		return plan

	if stamina_cost_per_step <= 0:
		plan.failure_code = FAILURE_INVALID_COST
		return plan

	if not grid.is_inside(combatant.grid_position):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if not _is_coordinate_allowed(
		grid,
		combatant.team_id,
		combatant.grid_position
	):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if (
		not grid.has_occupant(combatant.instance_id)
		or grid.get_occupant_position(
			combatant.instance_id
		) != combatant.grid_position
	):
		plan.failure_code = FAILURE_INVALID_START
		return plan

	if not grid.is_inside(target_coordinate):
		plan.failure_code = FAILURE_TARGET_OUTSIDE_GRID
		return plan

	if target_coordinate == combatant.grid_position:
		plan.failure_code = FAILURE_TARGET_IS_START
		return plan

	if not _is_coordinate_allowed(
		grid,
		combatant.team_id,
		target_coordinate
	):
		plan.failure_code = (
			FAILURE_TARGET_OUTSIDE_TEAM_SIDE
		)

		return plan

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		plan.failure_code = FAILURE_TARGET_BLOCKED
		return plan

	plan.path = find_shortest_path(
		grid,
		combatant.grid_position,
		target_coordinate,
		combatant.team_id
	)

	if plan.path.is_empty():
		plan.failure_code = FAILURE_NO_PATH
		return plan

	plan.stamina_cost = (
		plan.path.size()
		* stamina_cost_per_step
	)

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		plan.failure_code = FAILURE_NOT_ENOUGH_STAMINA
		return plan

	plan.is_valid = true
	return plan


func commit_plan(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> bool:
	if grid == null or combatant == null or plan == null:
		return false

	if not plan.is_valid:
		return false

	if combatant.instance_id != plan.combatant_id:
		return false

	if combatant.grid_position != plan.start_coordinate:
		return false

	if not combatant.can_spend_stamina(
		plan.stamina_cost
	):
		return false

	if not _is_path_currently_valid(
		grid,
		combatant.team_id,
		plan.start_coordinate,
		plan.path
	):
		return false

	if not combatant.spend_stamina(
		plan.stamina_cost
	):
		return false

	for step_coordinate in plan.path:
		var moved := grid.try_move_occupant(
			combatant.instance_id,
			step_coordinate
		)

		if not moved:
			_rollback_failed_movement(
				grid,
				combatant,
				plan
			)

			return false

		combatant.set_grid_position(
			step_coordinate
		)

	return true


func find_shortest_path(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	target_coordinate: Vector2i,
	team_id: StringName
) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []

	if grid == null:
		return empty_path

	if not side_rules.is_team_supported(
		team_id
	):
		return empty_path

	if (
		not grid.is_inside(start_coordinate)
		or not grid.is_inside(target_coordinate)
	):
		return empty_path

	if (
		not _is_coordinate_allowed(
			grid,
			team_id,
			start_coordinate
		)
		or not _is_coordinate_allowed(
			grid,
			team_id,
			target_coordinate
		)
	):
		return empty_path

	if start_coordinate == target_coordinate:
		return empty_path

	var target_cell := grid.get_cell(target_coordinate)

	if target_cell == null or not target_cell.is_walkable():
		return empty_path

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var came_from: Dictionary = {
		start_coordinate: start_coordinate,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		if current_coordinate == target_coordinate:
			break

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if not _is_coordinate_allowed(
				grid,
				team_id,
				neighbor_coordinate
			):
				continue

			if came_from.has(neighbor_coordinate):
				continue

			came_from[neighbor_coordinate] = (
				current_coordinate
			)

			frontier.append(
				neighbor_coordinate
			)

	if not came_from.has(target_coordinate):
		return empty_path

	var reversed_path: Array[Vector2i] = []
	var cursor := target_coordinate

	while cursor != start_coordinate:
		reversed_path.append(cursor)

		var previous_coordinate: Vector2i = (
			came_from[cursor]
		)

		cursor = previous_coordinate

	reversed_path.reverse()

	return reversed_path


func get_reachable_coordinates(
	grid: BattleGrid,
	start_coordinate: Vector2i,
	maximum_steps: int,
	team_id: StringName
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	if grid == null:
		return result

	if maximum_steps <= 0:
		return result

	if not side_rules.is_team_supported(
		team_id
	):
		return result

	if not grid.is_inside(start_coordinate):
		return result

	if not _is_coordinate_allowed(
		grid,
		team_id,
		start_coordinate
	):
		return result

	var frontier: Array[Vector2i] = [
		start_coordinate
	]

	var frontier_index: int = 0

	var distances: Dictionary = {
		start_coordinate: 0,
	}

	while frontier_index < frontier.size():
		var current_coordinate: Vector2i = (
			frontier[frontier_index]
		)

		frontier_index += 1

		var current_distance: int = (
			distances[current_coordinate]
		)

		if current_distance >= maximum_steps:
			continue

		var neighbors := grid.get_orthogonal_neighbors(
			current_coordinate,
			true
		)

		for neighbor_coordinate in neighbors:
			if not _is_coordinate_allowed(
				grid,
				team_id,
				neighbor_coordinate
			):
				continue

			if distances.has(neighbor_coordinate):
				continue

			var neighbor_distance := (
				current_distance + 1
			)

			distances[neighbor_coordinate] = (
				neighbor_distance
			)

			frontier.append(
				neighbor_coordinate
			)

			result.append(
				neighbor_coordinate
			)

	return result


func _is_path_currently_valid(
	grid: BattleGrid,
	team_id: StringName,
	start_coordinate: Vector2i,
	path: Array[Vector2i]
) -> bool:
	if path.is_empty():
		return false

	if not _is_coordinate_allowed(
		grid,
		team_id,
		start_coordinate
	):
		return false

	var previous_coordinate := start_coordinate

	for step_coordinate in path:
		if not grid.are_orthogonally_adjacent(
			previous_coordinate,
			step_coordinate
		):
			return false

		if not _is_coordinate_allowed(
			grid,
			team_id,
			step_coordinate
		):
			return false

		var step_cell := grid.get_cell(
			step_coordinate
		)

		if step_cell == null or not step_cell.is_walkable():
			return false

		previous_coordinate = step_coordinate

	return true


func _is_coordinate_allowed(
	grid: BattleGrid,
	team_id: StringName,
	coordinate: Vector2i
) -> bool:
	if grid == null or side_rules == null:
		return false

	return side_rules.is_coordinate_allowed(
		team_id,
		coordinate,
		grid.rows,
		grid.columns
	)


func _rollback_failed_movement(
	grid: BattleGrid,
	combatant: CombatantState,
	plan: BattleMovementPlan
) -> void:
	var current_coordinate := (
		grid.get_occupant_position(
			combatant.instance_id
		)
	)

	if current_coordinate != BattleGrid.INVALID_COORDINATE:
		grid.try_move_occupant(
			combatant.instance_id,
			plan.start_coordinate
		)

	combatant.set_grid_position(
		plan.start_coordinate
	)

	combatant.restore_stamina(
		plan.stamina_cost
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

	if not combatant.is_alive:
		active_combatant = null

		if evaluate_battle_state():
			return

		_advance_to_next_turn()
		return

	combatant.restore_round_stamina()

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


func _rebuild_turn_order() -> void:
	_turn_order = (
		session.get_living_combatants()
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
	if _is_processing_periodic_statuses:
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

## FILE: `presentation/battle/grid/battle_grid_overlay_presenter.gd`
```gdscript
class_name BattleGridOverlayPresenter
extends RefCounted


const REACHABLE_OVERLAY_COLOR := Color(
	0.20,
	0.72,
	0.88,
	0.28
)

const PATH_OVERLAY_COLOR := Color(
	1.0,
	0.82,
	0.24,
	0.52
)

const OBSTACLE_OVERLAY_COLOR := Color(
	0.82,
	0.26,
	0.18,
	0.62
)

const ENEMY_OVERLAY_COLOR := Color(
	0.82,
	0.18,
	0.14,
	0.30
)

const ATTACKABLE_OVERLAY_COLOR := Color(
	1.0,
	0.46,
	0.12,
	0.70
)


var grid_view: BattleGridView

var movement_service: BattleMovementService
var action_service: BattleActionService
var targeting_service: BattleTargetingService

var show_targeting_debug: bool = true


func _init(
	p_grid_view: BattleGridView,
	p_movement_service: BattleMovementService,
	p_action_service: BattleActionService,
	p_targeting_service: BattleTargetingService,
	p_show_targeting_debug: bool = true
) -> void:
	assert(
		p_grid_view != null,
		"BattleGridOverlayPresenter requires a grid view."
	)

	assert(
		p_movement_service != null,
		"BattleGridOverlayPresenter requires "
		+"a movement service."
	)

	assert(
		p_action_service != null,
		"BattleGridOverlayPresenter requires "
		+"an action service."
	)

	assert(
		p_targeting_service != null,
		"BattleGridOverlayPresenter requires "
		+"a targeting service."
	)

	grid_view = p_grid_view
	movement_service = p_movement_service
	action_service = p_action_service
	targeting_service = p_targeting_service

	show_targeting_debug = (
		p_show_targeting_debug
	)


func refresh(
	session: BattleSession,
	selected_combatant: CombatantState,
	target_candidates: Array[CombatantState],
	selected_ability: AbilityDefinition,
	hovered_coordinate: Vector2i,
	stamina_cost_per_cell: int
) -> void:
	clear()

	if session == null or session.grid == null:
		return

	var grid := session.grid

	if selected_combatant == null:
		return

	if not selected_combatant.is_alive:
		return

	_draw_reachable_coordinates(
		grid,
		selected_combatant,
		stamina_cost_per_cell
	)

	_draw_obstacles(grid)

	_draw_target_candidates(
		session,
		selected_combatant,
		target_candidates,
		selected_ability
	)

	if show_targeting_debug:
		_draw_targeting_debug(
			session,
			selected_combatant,
			selected_ability,
			hovered_coordinate
		)

	_draw_hovered_path(
		grid,
		selected_combatant,
		target_candidates,
		hovered_coordinate,
		stamina_cost_per_cell
	)

	if grid.is_inside(
		selected_combatant.grid_position
	):
		grid_view.set_selected_cell(
			selected_combatant.grid_position
		)


func clear() -> void:
	grid_view.clear_cell_overlays()
	grid_view.clear_selected_cell()
	grid_view.clear_targeting_debug_markers()


func _draw_targeting_debug(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	hovered_coordinate: Vector2i
) -> void:
	if (
		session == null
		or actor == null
		or ability == null
		or ability.targeting == null
	):
		grid_view.clear_targeting_debug_markers()
		return

	var aim_coordinates := (
		targeting_service.get_aim_coordinates(
			session,
			actor,
			ability
		)
	)

	var impact_coordinates: Array[Vector2i] = []

	if (
		hovered_coordinate
		!= BattleGridView.INVALID_COORDINATE
		and aim_coordinates.has(
			hovered_coordinate
		)
	):
		impact_coordinates = (
			targeting_service
			.get_impact_coordinates(
				session,
				actor,
				ability,
				hovered_coordinate
			)
		)

	grid_view.set_targeting_debug_markers(
		aim_coordinates,
		impact_coordinates
	)


func _draw_reachable_coordinates(
	grid: BattleGrid,
	combatant: CombatantState,
	stamina_cost_per_cell: int
) -> void:
	if stamina_cost_per_cell <= 0:
		return

	var maximum_steps := floori(
		float(combatant.current_stamina)
		/ float(stamina_cost_per_cell)
	)

	var reachable_coordinates := (
				movement_service.get_reachable_coordinates(
			grid,
			combatant.grid_position,
			maximum_steps,
			combatant.team_id
		)
	)

	for coordinate in reachable_coordinates:
		grid_view.set_cell_overlay(
			coordinate,
			REACHABLE_OVERLAY_COLOR
		)


func _draw_obstacles(
	grid: BattleGrid
) -> void:
	for coordinate in grid.get_all_coordinates():
		var cell := grid.get_cell(coordinate)

		if cell == null or not cell.has_obstacle():
			continue

		grid_view.set_cell_overlay(
			coordinate,
			OBSTACLE_OVERLAY_COLOR
		)


func _draw_target_candidates(
	session: BattleSession,
	actor: CombatantState,
	target_candidates: Array[CombatantState],
	ability: AbilityDefinition
) -> void:
	if session == null or session.grid == null:
		return

	var grid := session.grid

	for target in target_candidates:
		if target == null or not target.is_alive:
			continue

		if not grid.is_inside(
			target.grid_position
		):
			continue

		var overlay_color := (
			ENEMY_OVERLAY_COLOR
		)

		if ability != null:
			var command := BattleActionCommand.new(
				actor,
				ability,
				target.grid_position
			)

			if action_service.can_execute(
				session,
				command
			):
				overlay_color = (
					ATTACKABLE_OVERLAY_COLOR
				)

		grid_view.set_cell_overlay(
			target.grid_position,
			overlay_color
		)


func _draw_hovered_path(
	grid: BattleGrid,
	combatant: CombatantState,
	target_candidates: Array[CombatantState],
	hovered_coordinate: Vector2i,
	stamina_cost_per_cell: int
) -> void:
	if (
		hovered_coordinate
		== BattleGridView.INVALID_COORDINATE
	):
		return

	if _is_living_target_coordinate(
		target_candidates,
		hovered_coordinate
	):
		return

	var hover_plan := movement_service.create_plan(
		grid,
		combatant,
		hovered_coordinate,
		stamina_cost_per_cell
	)

	if not hover_plan.is_valid:
		return

	for path_coordinate in hover_plan.path:
		grid_view.set_cell_overlay(
			path_coordinate,
			PATH_OVERLAY_COLOR
		)


func _is_living_target_coordinate(
	target_candidates: Array[CombatantState],
	coordinate: Vector2i
) -> bool:
	for target in target_candidates:
		if (
			target != null
			and target.is_alive
			and target.grid_position == coordinate
		):
			return true

	return false
```

---

## FILE: `scenes/debug/battle_grid_sandbox.gd`
```gdscript
extends Node2D


const PLAYER_TEAM_ID: StringName = &"team_player"
const ENEMY_TEAM_ID: StringName = &"team_enemy"

const MAX_BATTLE_LOG_LINES: int = 6


@export_group("Combatants")

@export
var combatant_view_scene: PackedScene

@export
var encounter_definition: BattleEncounterDefinition


@export_group("Presentation")

@export
var animate_movement: bool = true

@export
var animate_actions: bool = true

@export
var show_targeting_debug: bool = true

@export_range(0.0, 2.0, 0.05)
var ai_think_delay: float = 0.35


@export_group("Movement")

@export_range(1, 10, 1)
var stamina_cost_per_cell: int = 1


@export_group("Status Debug")

@export
var debug_status_definition: BattleStatusDefinition


@onready
var grid_view: BattleGridView = $BattleGridView

@onready
var combatant_layer: Node2D = (
	$BattleGridView/CombatantLayer
)

@onready
var status_label: Label = (
	$CanvasLayer/InterfaceMargin/PanelContainer /
	ContentMargin / VBoxContainer /
	CollapsibleContent / StatusLabel
)

@onready
var ability_panel: BattleAbilityPanel = (
	$CanvasLayer/AbilityPanel
)

@onready
var combatant_hover_panel: BattleCombatantHoverPanel = (
	$CanvasLayer/CombatantHoverPanel
)


var session: BattleSession
var grid: BattleGrid

var combatant_presenter: BattleCombatantPresenter
var grid_overlay_presenter: BattleGridOverlayPresenter

var movement_runner: BattleMovementRunner
var action_runner: BattleActionRunner

var turn_controller: BattleTurnController
var reinforcement_controller: BattleReinforcementController

var ai_controller: BasicMeleeAIController
var ai_turn_runner: BasicMeleeAITurnRunner

var debug_log_presenter: BattleDebugLogPresenter
var interaction_controller: BattleSandboxInteractionController

var session_factory := BattleSessionFactory.new()

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService
var action_service: BattleActionService


func _ready() -> void:
	_validate_dependencies()
	_create_battle_state()
	_create_action_services()
	_create_debug_log_presenter()
	_create_combatant_presenter()
	_create_movement_runner()
	_create_action_runner()
	_create_grid_overlay_presenter()
	_create_ai_system()
	_create_reinforcement_system()
	_create_turn_controller()
	_create_interaction_controller()
	_connect_grid_signals()
	_connect_ability_panel()
	_connect_turn_signals()
	_start_battle()


func _input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_input(
		event
	):
		get_viewport().set_input_as_handled()


func _unhandled_input(
	event: InputEvent
) -> void:
	if interaction_controller == null:
		return

	if interaction_controller.handle_unhandled_input(
		event
	):
		get_viewport().set_input_as_handled()


func _validate_dependencies() -> void:
	assert(
		combatant_view_scene != null,
		"Combatant view scene is not assigned."
	)

	assert(
		encounter_definition != null,
		"Encounter definition is not assigned."
	)

	var encounter_errors := (
		encounter_definition.get_validation_errors()
	)

	assert(
		encounter_errors.is_empty(),
		"Invalid encounter definition: %s"
		% encounter_errors
	)


func _create_battle_state() -> void:
	session = session_factory.create_from_encounter(
		encounter_definition
	)

	assert(
		session != null,
		"Failed to create battle session "
		+"from encounter definition."
	)

	grid = session.grid

	movement_service = BattleMovementService.new(
		session.side_rules
	)

	grid_view.rows = grid.rows
	grid_view.columns = grid.columns
	grid_view.divider_column = (
		session.side_rules.divider_column
	)


func _create_action_services() -> void:
	targeting_service = BattleTargetingService.new()

	action_service = BattleActionService.new(
		targeting_service
	)


func _create_debug_log_presenter() -> void:
	debug_log_presenter = BattleDebugLogPresenter.new(
		status_label,
		session,
		debug_status_definition,
		MAX_BATTLE_LOG_LINES
	)


func _create_combatant_presenter() -> void:
	combatant_presenter = BattleCombatantPresenter.new(
		grid_view,
		combatant_layer,
		combatant_view_scene
	)

	for combatant in session.get_all_combatants():
		var created_view := (
			combatant_presenter.add_combatant(
				combatant,
				false
			)
		)

		assert(
			created_view != null,
			"Failed to create view for combatant '%s'."
			% combatant.instance_id
		)

		debug_log_presenter.connect_combatant(
			combatant
		)


func _create_movement_runner() -> void:
	movement_runner = BattleMovementRunner.new(
		movement_service,
		combatant_presenter
	)


func _create_action_runner() -> void:
	action_runner = BattleActionRunner.new(
		action_service,
		combatant_presenter
	)


func _create_grid_overlay_presenter() -> void:
	grid_overlay_presenter = (
		BattleGridOverlayPresenter.new(
			grid_view,
			movement_service,
			action_service,
			targeting_service,
			show_targeting_debug
		)
	)


func _create_ai_system() -> void:
	ai_controller = BasicMeleeAIController.new(
		movement_service,
		action_service,
		targeting_service
	)

	ai_turn_runner = BasicMeleeAITurnRunner.new(
		movement_runner,
		action_runner
	)


func _create_reinforcement_system() -> void:
	reinforcement_controller = (
		BattleReinforcementController.new(
			session,
			encounter_definition.reinforcement_waves
		)
	)

	reinforcement_controller.combatant_spawned.connect(
		_on_reinforcement_combatant_spawned
	)

	reinforcement_controller.wave_completed.connect(
		_on_reinforcement_wave_completed
	)

	reinforcement_controller.wave_deferred.connect(
		_on_reinforcement_wave_deferred
	)


func _create_turn_controller() -> void:
	turn_controller = BattleTurnController.new()


func _create_interaction_controller() -> void:
	interaction_controller = (
		BattleSandboxInteractionController.new(
			PLAYER_TEAM_ID,
			session,
			turn_controller,
			ability_panel,
			combatant_hover_panel,
			movement_service,
			targeting_service,
			movement_runner,
			action_runner,
			grid_overlay_presenter,
			debug_log_presenter,
			stamina_cost_per_cell,
			animate_movement,
			animate_actions
		)
	)


func _connect_grid_signals() -> void:
	grid_view.cell_clicked.connect(
		interaction_controller.on_grid_cell_clicked
	)

	grid_view.cell_hovered.connect(
		interaction_controller.on_grid_cell_hovered
	)


func _connect_ability_panel() -> void:
	assert(
		ability_panel != null,
		"Battle ability panel is required."
	)

	ability_panel.ability_selected.connect(
		interaction_controller.on_ability_selected
	)


func _connect_turn_signals() -> void:
	turn_controller.turn_started.connect(
		_on_turn_started
	)

	turn_controller.periodic_status_effects_resolved.connect(
		_on_periodic_status_effects_resolved
	)

	turn_controller.battle_finished.connect(
		_on_battle_finished
	)


func _start_battle() -> void:
	var started := turn_controller.start(
		session,
		reinforcement_controller
	)

	assert(
		started,
		"Failed to start battle turn controller."
	)


func _on_reinforcement_combatant_spawned(
	combatant: CombatantState,
	wave_id: StringName,
	scheduled_round: int,
	actual_round: int,
	coordinate: Vector2i
) -> void:
	var created_view := (
		combatant_presenter.add_combatant(
			combatant,
			false
		)
	)

	assert(
		created_view != null,
		"Failed to create reinforcement view "
		+"for combatant '%s'."
		% combatant.instance_id
	)

	debug_log_presenter.connect_combatant(
		combatant
	)

	print(
		"Reinforcement '%s' from wave '%s' "
		% [
			combatant.instance_id,
			wave_id,
		]
		+"spawned at %s. Scheduled round: %d, "
		% [
			coordinate,
			scheduled_round,
		]
		+"actual round: %d."
		% actual_round
	)


func _on_reinforcement_wave_completed(
	wave_id: StringName,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' completed "
		% wave_id
		+"on round %d."
		% actual_round
	)


func _on_reinforcement_wave_deferred(
	wave_id: StringName,
	pending_combatant_count: int,
	actual_round: int
) -> void:
	print(
		"Reinforcement wave '%s' deferred "
		% wave_id
		+"on round %d. Pending combatants: %d."
		% [
			actual_round,
			pending_combatant_count,
		]
	)


func _on_periodic_status_effects_resolved(
	combatant: CombatantState,
	timing: int,
	trigger_results: Array[
		BattleStatusPeriodicTriggerResult
	]
) -> void:
	debug_log_presenter.append_periodic_trigger_results(
		combatant,
		timing,
		trigger_results
	)

	var removed_view_ids: Dictionary = {}

	for trigger_result in trigger_results:
		if trigger_result == null:
			continue

		for target_id in (
			trigger_result
			.get_defeated_target_ids()
		):
			if removed_view_ids.has(
				target_id
			):
				continue

			removed_view_ids[
				target_id
			] = true

			if combatant_presenter.has_view(
				target_id
			):
				combatant_presenter.remove_view(
					target_id
				)

	if interaction_controller != null:
		interaction_controller.refresh_grid_overlays()
		
func _on_turn_started(
	combatant: CombatantState,
	current_round: int,
	_turn_index: int
) -> void:
	_set_active_combatant_selection(
		combatant
	)

	if combatant.team_id == PLAYER_TEAM_ID:
		interaction_controller.begin_player_turn(
			combatant
		)

		var selected_ability := (
			interaction_controller.get_selected_ability()
		)

		var ability_name := (
			selected_ability.display_name
			if selected_ability != null
			else "не выбрана"
		)

		debug_log_presenter.set_headline(
			"Раунд %d. Твой ход: %s. "
			% [
				current_round,
				combatant.definition.display_name,
			]
			+"Выносливость: %d/%d. "
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
			+"Статусы: %s. "
			% debug_log_presenter.get_status_summary(
				combatant
			)
			+"Выбрано: %s. "
			% ability_name
			+"1–9 — способность, Space — завершить ход."
		)

		return

	interaction_controller.begin_enemy_turn()

	debug_log_presenter.set_headline(
		"Раунд %d. Ход врага: %s. "
		% [
			current_round,
			combatant.definition.display_name,
		]
		+"Статусы: %s."
		% debug_log_presenter.get_status_summary(
			combatant
		)
	)

	call_deferred(
		"_run_ai_turn",
		combatant
	)


func _on_battle_finished(
	winning_team_id: StringName
) -> void:
	_set_active_combatant_selection(
		null
	)

	interaction_controller.finish_battle()

	if winning_team_id == PLAYER_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Победа!"
		)

	elif winning_team_id == ENEMY_TEAM_ID:
		debug_log_presenter.set_headline(
			"Бой завершён. Поражение."
		)

	else:
		debug_log_presenter.set_headline(
			"Бой завершён без победителя."
		)


func _set_active_combatant_selection(
	active: CombatantState
) -> void:
	for combatant in session.get_all_combatants():
		var view := combatant_presenter.get_view(
			combatant.instance_id
		)

		if view == null:
			continue

		view.set_selected_state(
			combatant == active
		)


func _run_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	if ai_think_delay > 0.0:
		await get_tree().create_timer(
			ai_think_delay
		).timeout

	if not _is_combatant_still_active(
		combatant
	):
		return

	var ability := combatant.get_default_ability()

	if ability == null:
		debug_log_presenter.set_headline(
			"%s не имеет доступных способностей."
			% combatant.definition.display_name
		)

		_finish_ai_turn(
			combatant
		)
		return

	var plan := ai_controller.create_turn_plan(
		grid,
		session,
		combatant,
		ability,
		stamina_cost_per_cell
	)

	if not plan.is_valid:
		debug_log_presenter.set_headline(
			"%s завершает ход: %s."
			% [
				combatant.definition.display_name,
				plan.failure_code,
			]
		)

		_finish_ai_turn(
			combatant
		)
		return

	grid_overlay_presenter.clear()

	var outcome := await ai_turn_runner.execute(
		session,
		plan,
		animate_movement,
		animate_actions
	)

	if turn_controller.is_finished:
		interaction_controller.set_interaction_in_progress(
			false
		)
		return

	if not outcome.is_successful:
		debug_log_presenter.set_headline(
			"Ход ИИ выполнен не полностью: %s."
			% outcome.failure_code
		)

	elif outcome.did_attack():
		debug_log_presenter.set_headline(
			"%s использует «%s» против %s. "
			% [
				combatant.definition.display_name,
				ability.display_name,
				plan.target.definition.display_name,
			]
			+"Ударов: %d. Общий урон: %d. "
			% [
				outcome.get_attack_count(),
				outcome.get_damage_dealt(),
			]
			+"Здоровье цели: %d/%d. "
			% [
				plan.target.current_health,
				plan.target.max_health,
			]
			+"Выносливость врага: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	elif outcome.did_move():
		debug_log_presenter.set_headline(
			"%s приближается к %s. "
			% [
				combatant.definition.display_name,
				plan.target.definition.display_name,
			]
			+"Пройдено клеток: %d. "
			% outcome.get_movement_step_count()
			+"Осталось выносливости: %d/%d."
			% [
				combatant.current_stamina,
				combatant.max_stamina,
			]
		)

	else:
		debug_log_presenter.set_headline(
			"%s не может действовать."
			% combatant.definition.display_name
		)

	interaction_controller.refresh_grid_overlays()

	_finish_ai_turn(
		combatant
	)


func _is_combatant_still_active(
	combatant: CombatantState
) -> bool:
	return (
		turn_controller != null
		and turn_controller.is_running
		and turn_controller.is_combatant_active(
			combatant
		)
	)


func _finish_ai_turn(
	combatant: CombatantState
) -> void:
	if not _is_combatant_still_active(
		combatant
	):
		return

	turn_controller.end_current_turn()
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

var movement_service: BattleMovementService
var targeting_service: BattleTargetingService

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
	p_movement_service: BattleMovementService,
	p_targeting_service: BattleTargetingService,
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
		p_movement_service != null,
		"Interaction controller requires a movement service."
	)

	assert(
		p_targeting_service != null,
		"Interaction controller requires a targeting service."
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

	movement_service = p_movement_service
	targeting_service = p_targeting_service

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

	ability_panel.clear_combatant()

	refresh_grid_overlays()


func finish_battle() -> void:
	_interaction_in_progress = false
	_selected_ability = null

	ability_panel.clear_combatant()
	combatant_hover_panel.clear_combatant()
	grid_overlay_presenter.clear()


func set_interaction_in_progress(
	value: bool
) -> void:
	_interaction_in_progress = value

	if value:
		grid_overlay_presenter.clear()
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

	return combatant.get_default_ability()


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

	_refresh_hover_panel()

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
				debug_log_presenter.set_headline(
					"Клетка %s занята союзником %s."
					% [
						coordinate,
						target.definition.display_name,
					]
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

	_refresh_hover_panel()


func _refresh_hover_panel() -> void:
	if combatant_hover_panel == null:
		return

	var hovered_combatant := (
		_get_combatant_at_coordinate(
			_hovered_coordinate
		)
	)

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

		_:
			return (
				"Действие невозможно: %s."
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

		BattleMovementService.FAILURE_DEAD_COMBATANT:
			return "Погибший боец не может двигаться."

		_:
			return (
				"Перемещение невозможно: %s."
				% failure_code
			)
```

---


## ✅ STATS
- Total files in tree: 87
- Readable files: 83
- Included files written: 8
- Trimmed files: 0
- Total lines written: 4151
