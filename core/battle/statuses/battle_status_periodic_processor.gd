class_name BattleStatusPeriodicProcessor
extends RefCounted


const FAILURE_INVALID_TRIGGER: StringName = (
	&"invalid_periodic_trigger"
)

const FAILURE_NO_EFFECTS_RESOLVED: StringName = (
	&"no_periodic_effects_resolved"
)


var effect_resolver: EffectResolver


func _init(
	p_effect_resolver: EffectResolver = null
) -> void:
	effect_resolver = (
		p_effect_resolver
		if p_effect_resolver != null
		else EffectResolver.new()
	)


func process_owner_timing(
	session: BattleSession,
	owner: CombatantState,
	timing: int
) -> Array[BattleStatusPeriodicTriggerResult]:
	var results: Array[BattleStatusPeriodicTriggerResult] = []

	if session == null:
		return results

	if owner == null or not owner.is_alive:
		return results

	var statuses := owner.get_active_statuses()

	statuses.sort_custom(
		Callable(
			self,
			"_is_status_before"
		)
	)

	for status in statuses:
		if not owner.is_alive:
			break

		if (
			status == null
			or status.definition == null
		):
			continue

		if (
			owner.get_status(
				status.status_id
			) != status
		):
			continue

		for trigger in (
			status.definition
			.periodic_triggers
		):
			if not owner.is_alive:
				break

			if (
				owner.get_status(
					status.status_id
				) != status
			):
				break

			if (
				trigger == null
				or trigger.timing != timing
			):
				continue

			results.append(
				_process_trigger(
					session,
					owner,
					status,
					trigger
				)
			)

	return results


func _process_trigger(
	session: BattleSession,
	owner: CombatantState,
	status: BattleStatusInstance,
	trigger: BattleStatusPeriodicTrigger
) -> BattleStatusPeriodicTriggerResult:
	var result := (
		BattleStatusPeriodicTriggerResult
		.new()
	)

	result.timing = trigger.timing
	result.owner_id = owner.instance_id
	result.status_id = status.status_id

	if status.definition != null:
		result.status_display_name = (
			status.definition.display_name
		)

	if not trigger.is_valid_definition():
		result.failure_code = (
			FAILURE_INVALID_TRIGGER
		)

		return result

	var source := _resolve_source(
		session,
		owner,
		status
	)

	var all_effects_succeeded := true

	for effect in trigger.effects:
		if not owner.is_alive:
			break

		var effect_result := (
			effect_resolver.resolve(
				effect,
				source,
				owner
			)
		)

		result.effect_results.append(
			effect_result
		)

		if (
			effect_result == null
			or not effect_result.is_successful
		):
			all_effects_succeeded = false

	if result.effect_results.is_empty():
		result.failure_code = (
			FAILURE_NO_EFFECTS_RESOLVED
		)

		return result

	result.is_successful = (
		all_effects_succeeded
	)

	return result


func _resolve_source(
	session: BattleSession,
	owner: CombatantState,
	status: BattleStatusInstance
) -> CombatantState:
	if status.source_instance_id != &"":
		var stored_source := (
			session.get_combatant(
				status.source_instance_id
			)
		)

		if stored_source != null:
			return stored_source

	return owner


func _is_status_before(
	left: BattleStatusInstance,
	right: BattleStatusInstance
) -> bool:
	if left == null:
		return false

	if right == null:
		return true

	return (
		String(left.status_id)
		< String(right.status_id)
	)