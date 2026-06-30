class_name BattleActionService
extends RefCounted


const FAILURE_INVALID_GRID: StringName = &"invalid_grid"
const FAILURE_INVALID_COMMAND: StringName = &"invalid_command"
const FAILURE_INVALID_ACTOR: StringName = &"invalid_actor"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_INVALID_ABILITY: StringName = &"invalid_ability"
const FAILURE_INVALID_ABILITY_DEFINITION: StringName = (
	&"invalid_ability_definition"
)

const FAILURE_ACTOR_DEAD: StringName = &"actor_dead"
const FAILURE_TARGET_DEAD: StringName = &"target_dead"

const FAILURE_ACTOR_NOT_ON_GRID: StringName = (
	&"actor_not_on_grid"
)

const FAILURE_TARGET_NOT_ON_GRID: StringName = (
	&"target_not_on_grid"
)

const FAILURE_INVALID_TARGET_RELATION: StringName = (
	&"invalid_target_relation"
)

const FAILURE_TARGET_OUT_OF_RANGE: StringName = (
	&"target_out_of_range"
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


var effect_resolver := EffectResolver.new()


func execute(
	grid: BattleGrid,
	command: BattleActionCommand
) -> BattleActionResult:
	var result := _create_result(command)

	var failure_code := _get_validation_failure(
		grid,
		command
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var actor := command.actor
	var target := command.target
	var ability := command.ability

	if not actor.spend_stamina(ability.stamina_cost):
		result.failure_code = (
			FAILURE_STAMINA_SPEND_FAILED
		)

		return result

	result.stamina_spent = ability.stamina_cost

	for effect in ability.effects:
		if not target.is_alive:
			break

		var effect_result := effect_resolver.resolve(
			effect,
			actor,
			target
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
	grid: BattleGrid,
	command: BattleActionCommand
) -> bool:
	return _get_validation_failure(
		grid,
		command
	) == &""


func get_validation_failure(
	grid: BattleGrid,
	command: BattleActionCommand
) -> StringName:
	return _get_validation_failure(
		grid,
		command
	)


func _get_validation_failure(
	grid: BattleGrid,
	command: BattleActionCommand
) -> StringName:
	if grid == null:
		return FAILURE_INVALID_GRID

	if command == null:
		return FAILURE_INVALID_COMMAND

	var actor := command.actor
	var target := command.target
	var ability := command.ability

	if actor == null:
		return FAILURE_INVALID_ACTOR

	if target == null:
		return FAILURE_INVALID_TARGET

	if ability == null:
		return FAILURE_INVALID_ABILITY

	if not ability.is_valid_definition():
		return FAILURE_INVALID_ABILITY_DEFINITION

	if not actor.is_alive:
		return FAILURE_ACTOR_DEAD

	if not target.is_alive:
		return FAILURE_TARGET_DEAD

	if not _is_combatant_on_grid(
		grid,
		actor
	):
		return FAILURE_ACTOR_NOT_ON_GRID

	if not _is_combatant_on_grid(
		grid,
		target
	):
		return FAILURE_TARGET_NOT_ON_GRID

	if not _is_valid_target_relation(
		actor,
		target,
		ability.target_relation
	):
		return FAILURE_INVALID_TARGET_RELATION

	var distance := grid.get_manhattan_distance(
		actor.grid_position,
		target.grid_position
	)

	if (
		distance < ability.minimum_range
		or distance > ability.maximum_range
	):
		return FAILURE_TARGET_OUT_OF_RANGE

	if not actor.can_spend_stamina(
		ability.stamina_cost
	):
		return FAILURE_NOT_ENOUGH_STAMINA

	for effect in ability.effects:
		if not effect_resolver.can_resolve(effect):
			return FAILURE_UNSUPPORTED_EFFECT

	return &""


func _is_combatant_on_grid(
	grid: BattleGrid,
	combatant: CombatantState
) -> bool:
	if not grid.is_inside(combatant.grid_position):
		return false

	if not grid.has_occupant(combatant.instance_id):
		return false

	return (
		grid.get_occupant_position(
			combatant.instance_id
		)
		== combatant.grid_position
	)


func _is_valid_target_relation(
	actor: CombatantState,
	target: CombatantState,
	target_relation: AbilityDefinition.TargetRelation
) -> bool:
	match target_relation:
		AbilityDefinition.TargetRelation.ENEMY:
			return actor.team_id != target.team_id

		AbilityDefinition.TargetRelation.ALLY:
			return (
				actor != target
				and actor.team_id == target.team_id
			)

		AbilityDefinition.TargetRelation.SELF:
			return actor == target

		AbilityDefinition.TargetRelation.ANY:
			return true

		_:
			return false


func _create_result(
	command: BattleActionCommand
) -> BattleActionResult:
	var result := BattleActionResult.new()

	if command == null:
		return result

	if command.actor != null:
		result.actor_id = command.actor.instance_id

	if command.target != null:
		result.target_id = command.target.instance_id

	if command.ability != null:
		result.ability_id = command.ability.ability_id
		result.stamina_cost = command.ability.stamina_cost

	return result