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

const FAILURE_ABILITY_ON_COOLDOWN: StringName = (
	&"ability_on_cooldown"
)

const FAILURE_ABILITY_RESTRICTED: StringName = (
	&"ability_restricted"
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

const FAILURE_NO_AFFECTED_COORDINATES: StringName = (
	&"no_affected_coordinates"
)

const FAILURE_INVALID_RELOCATION_ABILITY: StringName = (
	&"invalid_relocation_ability"
)

const FAILURE_INVALID_RELOCATION_TARGET: StringName = (
	&"invalid_relocation_target"
)

var targeting_service: BattleTargetingService
var effect_resolver := EffectResolver.new()
var reaction_processor: BattleStatusReactionProcessor

var relocation_service := BattleRelocationService.new()

func _init(
	p_targeting_service: BattleTargetingService
) -> void:
	assert(
		p_targeting_service != null,
		"BattleActionService requires "
		+"BattleTargetingService."
	)

	targeting_service = p_targeting_service
	reaction_processor = (
		BattleStatusReactionProcessor.new(
			effect_resolver
		)
	)


func execute(
	session: BattleSession,
	command: BattleActionCommand,
	standard_critical_mode: int = (
		EffectResolver
			.StandardCriticalMode
			.RANDOM
	)
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

	if _has_combatant_targeted_effect(
		command.ability
	):
		for target in (
			targeting_result.affected_combatants
		):
			result.affected_target_ids.append(
				target.instance_id
			)

	elif _has_teleport_effect(
		command.ability
	):
		result.affected_target_ids.append(
			command.actor.instance_id
		)

	if (
		_has_source_recipient_effect(
			command.ability
		)
		and not result.affected_target_ids.has(
			command.actor.instance_id
		)
	):
		result.affected_target_ids.append(
			command.actor.instance_id
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

	var action_scope_targets := (
		_begin_target_action_scopes(
			targeting_result
		)
	)

	var targets_by_coordinate := (
		_get_targets_by_coordinate(
			targeting_result
		)
	)

	var resolved_source_effect_ids: Dictionary = {}

	# Эффекты разрешаются отдельно для каждой
	# impact-клетки и строго в заданном порядке.
	for coordinate in (
		targeting_result.affected_coordinates
	):
		var target := (
			targets_by_coordinate.get(
				coordinate
			) as CombatantState
		)

		for effect in command.ability.effects:
			if effect == null:
				continue

			## SOURCE-эффект разрешается ровно один раз
			## за действие, даже если способность
			## затрагивает несколько impact-клеток.
			if effect.targets_source():
				if resolved_source_effect_ids.has(
					effect.effect_id
				):
					continue

				resolved_source_effect_ids[
					effect.effect_id
				] = true
			if (
				effect_resolver
				.requires_combatant_target(
					effect
				)
			):
				if (
					target == null
					or not target.is_alive
				):
					continue

			var effect_result := (
				effect_resolver.resolve(
					effect,
					command.actor,
					target,
					session,
					false,
					true,
					coordinate,
					standard_critical_mode
				)
			)

			result.effect_results.append(
				effect_result
			)

			if not effect_result.is_successful:
				result.failure_code = (
					FAILURE_EFFECT_RESOLUTION_FAILED
				)

				_end_target_action_scopes(
					action_scope_targets
				)

				return result

	_end_target_action_scopes(
		action_scope_targets
	)
	result.is_successful = true

	result.cooldown_started = (
		command.actor.start_ability_cooldown(
			command.ability
		)
	)

	if result.cooldown_started:
		result.cooldown_turns = (
			command.ability.cooldown_turns
		)

	var resolved_reactions := (
		reaction_processor
		.process_after_enemy_action(
			session,
			command.actor,
			result,
			action_scope_targets,
			standard_critical_mode
		)
	)

	for reaction_result in (
		resolved_reactions
	):
		result.reaction_results.append(
			reaction_result
		)

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
	
	if actor.is_ability_locked(
		ability.ability_id
	):
		return FAILURE_ABILITY_ON_COOLDOWN

	if actor.is_ability_restricted(
		ability.ability_id
	):
		return FAILURE_ABILITY_RESTRICTED

	var targeting_result := (
		targeting_service.create_result(
			session,
			actor,
			ability,
			command.aim_coordinate
		)
	)

	if not targeting_result.is_valid:
		return targeting_result.failure_code

	for effect in ability.effects:
		if not effect_resolver.can_resolve(
			effect
		):
			return FAILURE_UNSUPPORTED_EFFECT

	var effect_runtime_failure := (
		_get_effect_runtime_validation_failure(
			actor,
			ability,
			targeting_result
		)
	)

	if effect_runtime_failure != &"":
		return effect_runtime_failure

	var surface_placement_failure := (
		_get_surface_placement_validation_failure(
			session,
			ability,
			targeting_result
		)
	)

	if surface_placement_failure != &"":
		return surface_placement_failure

	var relocation_failure := (
		_get_relocation_validation_failure(
			session,
			actor,
			ability,
			targeting_result
		)
	)

	if relocation_failure != &"":
		return relocation_failure

	if not actor.can_spend_stamina(
		ability.stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	return &""

func _get_effect_runtime_validation_failure(
	actor: CombatantState,
	ability: AbilityDefinition,
	targeting_result: BattleTargetingResult
) -> StringName:
	if (
		actor == null
		or ability == null
		or targeting_result == null
	):
		return FAILURE_INVALID_COMMAND

	for effect in ability.effects:
		if effect == null:
			continue

		if effect.targets_source():
			var source_failure := (
				effect_resolver
					.get_runtime_validation_failure(
						effect,
						actor,
						null
					)
			)

			if source_failure != &"":
				return source_failure

			continue

		if not effect_resolver.requires_combatant_target(
			effect
		):
			continue

		for target in (
			targeting_result.affected_combatants
		):
			if (
				target == null
				or not target.is_alive
			):
				continue

			var target_failure := (
				effect_resolver
					.get_runtime_validation_failure(
						effect,
						actor,
						target
					)
			)

			if target_failure != &"":
				return target_failure

	return &""

func _get_relocation_validation_failure(
	session: BattleSession,
	actor: CombatantState,
	ability: AbilityDefinition,
	targeting_result: BattleTargetingResult
) -> StringName:
	var relocation_effect: BattleEffect
	var relocation_effect_count := 0

	for effect in ability.effects:
		if (
			effect is SwapPositionsEffect
			or effect is TeleportEffect
		):
			relocation_effect = effect
			relocation_effect_count += 1

	if relocation_effect_count == 0:
		return &""

	## Relocation v1 намеренно не смешивается
	## с уроном, статусами и другими эффектами.
	if (
		relocation_effect_count != 1
		or ability.effects.size() != 1
	):
		return FAILURE_INVALID_RELOCATION_ABILITY

	if (
		targeting_result
		.affected_coordinates
		.size() != 1
	):
		return FAILURE_NO_AFFECTED_COORDINATES

	if relocation_effect is SwapPositionsEffect:
		if (
			targeting_result
			.affected_combatants
			.size() != 1
		):
			return FAILURE_INVALID_RELOCATION_TARGET

		var target := (
			targeting_result
			.affected_combatants[0]
		)

		return relocation_service.get_swap_failure(
			session,
			actor,
			target,
			true,
			false,
			0
		)

	if relocation_effect is TeleportEffect:
		return relocation_service.get_teleport_failure(
			session,
			actor,
			targeting_result.affected_coordinates[0],
			0
		)

	return FAILURE_INVALID_RELOCATION_ABILITY


func _has_teleport_effect(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	for effect in ability.effects:
		if effect is TeleportEffect:
			return true

	return false

func _get_surface_placement_validation_failure(
	session: BattleSession,
	ability: AbilityDefinition,
	targeting_result: BattleTargetingResult
) -> StringName:
	var has_surface_effect := false

	for effect in ability.effects:
		if effect is PlaceSurfaceEffect:
			has_surface_effect = true
			break

	if not has_surface_effect:
		return &""

	if targeting_result.affected_coordinates.is_empty():
		return FAILURE_NO_AFFECTED_COORDINATES

	if session.surface_effect_controller == null:
		return (
			BattleSurfaceEffectController
				.FAILURE_INVALID_SESSION
		)

	for effect in ability.effects:
		if not effect is PlaceSurfaceEffect:
			continue

		var place_effect := (
			effect as PlaceSurfaceEffect
		)

		for coordinate in (
			targeting_result.affected_coordinates
		):
			var placement_failure := (
				session
				.surface_effect_controller
				.get_placement_failure(
					session,
					coordinate,
					place_effect.surface_definition
				)
			)

			if placement_failure != &"":
				return placement_failure

	return &""


func _has_source_recipient_effect(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	for effect in ability.effects:
		if (
			effect != null
			and effect.targets_source()
		):
			return true

	return false
	
func _has_combatant_targeted_effect(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	for effect in ability.effects:
		if effect_resolver.requires_combatant_target(
			effect
		):
			return true

	return false


func _begin_target_action_scopes(
	targeting_result: BattleTargetingResult
) -> Array[CombatantState]:
	var result: Array[CombatantState] = []

	if targeting_result == null:
		return result

	var used_target_ids: Dictionary = {}

	for target in (
		targeting_result.affected_combatants
	):
		if (
			target == null
			or not target.is_alive
			or used_target_ids.has(
				target.instance_id
			)
		):
			continue

		used_target_ids[
			target.instance_id
		] = true

		target.begin_incoming_action_resolution()

		result.append(
			target
		)

	return result


func _end_target_action_scopes(
	targets: Array[CombatantState]
) -> void:
	for target in targets:
		if target == null:
			continue

		target.end_incoming_action_resolution()
		
func _get_targets_by_coordinate(
	targeting_result: BattleTargetingResult
) -> Dictionary:
	var result: Dictionary = {}

	for target in (
		targeting_result.affected_combatants
	):
		if target == null:
			continue

		result[target.grid_position] = target

	return result
	

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
