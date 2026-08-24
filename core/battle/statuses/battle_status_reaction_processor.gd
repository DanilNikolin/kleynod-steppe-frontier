class_name BattleStatusReactionProcessor
extends RefCounted


const FAILURE_INVALID_REACTION: StringName = (
	&"invalid_reaction"
)

const FAILURE_REACTION_EFFECT_FAILED: StringName = (
	&"reaction_effect_failed"
)

const DAMAGE_FLAG_HEALTH: int = 1
const DAMAGE_FLAG_GUARD: int = 2

var effect_resolver: EffectResolver


func _init(
	p_effect_resolver: EffectResolver = null
) -> void:
	effect_resolver = (
		p_effect_resolver
		if p_effect_resolver != null
		else EffectResolver.new()
	)


func process_after_enemy_action(
	session: BattleSession,
	triggering_actor: CombatantState,
	action_result: BattleActionResult,
	candidate_reactors: Array[CombatantState],
	standard_critical_mode: int = (
		EffectResolver
			.StandardCriticalMode
			.RANDOM
	)
) -> Array[BattleActionReactionResult]:
	var results: Array[BattleActionReactionResult] = []

	if (
		session == null
		or triggering_actor == null
		or action_result == null
	):
		return results

	for reactor in candidate_reactors:
		if (
			reactor == null
			or not reactor.is_alive
			or reactor == triggering_actor
			or reactor.team_id
				== triggering_actor.team_id
		):
			continue

		var statuses := reactor.get_active_statuses()

		for status in statuses:
			if (
				status == null
				or status.definition == null
			):
				continue

			for reaction in (
				status.definition.reactions
			):
				if reaction == null:
					continue

				if (
					reaction.trigger_timing
					!= BattleStatusReactionDefinition
						.TriggerTiming
						.AFTER_ENEMY_ACTION
				):
					continue

				if not reaction.matches_reactor_health(
					reactor.current_health
				):
					continue

				if not _matches_damage_requirement(
					action_result,
					reactor,
					reaction.damage_requirement
				):
					continue

				var reaction_result := (
					_resolve_reaction(
						session,
						reactor,
						triggering_actor,
						status,
						reaction,
						standard_critical_mode
					)
				)

				results.append(
					reaction_result
				)

				if (
					not reaction_result.is_successful
				):
					continue

				if (
					reaction.consume_status_on_trigger
				):
					reaction_result.status_consumed = (
						reactor.remove_status(
							status.status_id,
							&"reaction_consumed"
						)
					)

					break

	return results


func _matches_damage_requirement(
	action_result: BattleActionResult,
	reactor: CombatantState,
	requirement: int
) -> bool:
	if requirement == (
		BattleStatusReactionDefinition
			.DamageRequirement
			.NONE
	):
		return true

	var damage_flags := 0

	for effect_result in (
		action_result.effect_results
	):
		damage_flags |= (
			_get_damage_flags_from_effect_tree(
				effect_result,
				reactor
			)
		)

	var health_was_damaged := (
		damage_flags
		& DAMAGE_FLAG_HEALTH
	) != 0

	var guard_was_damaged := (
		damage_flags
		& DAMAGE_FLAG_GUARD
	) != 0

	match requirement:
		BattleStatusReactionDefinition.DamageRequirement.HEALTH_OR_GUARD:
			return (
				health_was_damaged
				or guard_was_damaged
			)

		BattleStatusReactionDefinition.DamageRequirement.HEALTH_ONLY:
			return health_was_damaged

		BattleStatusReactionDefinition.DamageRequirement.GUARD_ONLY:
			return guard_was_damaged

	return false

func _get_damage_flags_from_effect_tree(
	effect_result: BattleEffectResult,
	reactor: CombatantState
) -> int:
	if (
		effect_result == null
		or reactor == null
	):
		return 0

	var damage_flags := 0

	if (
		effect_result.is_successful
		and effect_result.effect_kind == &"damage"
		and effect_result.target_id
			== reactor.instance_id
	):
		var survival_damage_was_prevented := (
			reactor.is_alive
			and effect_result.overkill_amount > 0
			and not effect_result
				.damage_was_redirected_from_health
		)

		if (
			effect_result.applied_amount > 0
			or survival_damage_was_prevented
		):
			damage_flags |= (
				DAMAGE_FLAG_HEALTH
			)

		if (
			effect_result.guard_absorbed_amount
			> 0
		):
			damage_flags |= (
				DAMAGE_FLAG_GUARD
			)

	for trigger_result in (
		effect_result.surface_trigger_results
	):
		if trigger_result == null:
			continue

		for nested_effect_result in (
			trigger_result.effect_results
		):
			damage_flags |= (
				_get_damage_flags_from_effect_tree(
					nested_effect_result,
					reactor
				)
			)

	return damage_flags
	
func _resolve_reaction(
	session: BattleSession,
	reactor: CombatantState,
	triggering_actor: CombatantState,
	status: BattleStatusInstance,
	reaction: BattleStatusReactionDefinition,
	standard_critical_mode: int
) -> BattleActionReactionResult:
	var result := BattleActionReactionResult.new()

	result.reactor_id = reactor.instance_id
	result.triggering_actor_id = (
		triggering_actor.instance_id
	)

	result.status_id = status.status_id

	if status.definition != null:
		result.status_display_name = (
			status.definition.display_name
		)

	if (
		reaction == null
		or reaction.effects.is_empty()
	):
		result.failure_code = (
			FAILURE_INVALID_REACTION
		)

		return result

	## Реакция сама считается отдельным action-scope.
	## Это важно для Core вроде Несломленности,
	## если позже появятся multi-hit реакции.
	triggering_actor.begin_incoming_action_resolution()

	for effect in reaction.effects:
		if effect == null:
			triggering_actor.end_incoming_action_resolution()

			result.failure_code = (
				FAILURE_INVALID_REACTION
			)

			return result

		if (
			effect_resolver
			.requires_combatant_target(
				effect
			)
			and not triggering_actor.is_alive
		):
			triggering_actor.end_incoming_action_resolution()

			result.failure_code = (
				FAILURE_REACTION_EFFECT_FAILED
			)

			return result

		var effect_coordinate := (
			reactor.grid_position
			if effect.targets_source()
			else triggering_actor.grid_position
		)

		var effect_result := (
			effect_resolver.resolve(
				effect,
				reactor,
				triggering_actor,
				session,
				false,
				true,
				effect_coordinate,
				standard_critical_mode
			)
		)

		result.effect_results.append(
			effect_result
		)

		if not effect_result.is_successful:
			triggering_actor.end_incoming_action_resolution()

			result.failure_code = (
				FAILURE_REACTION_EFFECT_FAILED
			)

			return result

	triggering_actor.end_incoming_action_resolution()

	result.is_successful = true

	return result