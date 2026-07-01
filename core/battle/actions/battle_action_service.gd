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

	if actor.is_ability_restricted(
		ability.ability_id
	):
		return FAILURE_ABILITY_RESTRICTED

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
