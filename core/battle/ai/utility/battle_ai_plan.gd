class_name BattleAIPlan
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor_id: StringName = &""

var origin_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

## Обычное свободное перемещение.
var movement_plan: BattleMovementPlan

## Обычный swap через movement interaction,
## а не SwapPositionsEffect способности.
var ally_swap_target_id: StringName = &""

var ally_swap_target_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var ally_swap_stamina_cost: int = 0

## Способность является необязательной частью plan.
var ability: AbilityDefinition

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var available_stamina_before: int = 0
var movement_stamina_cost: int = 0
var action_stamina_cost: int = 0
var total_stamina_cost: int = 0
var remaining_stamina: int = 0

var score_breakdown := (
	BattleAIScoreBreakdown.new()
)


func has_movement() -> bool:
	return (
		movement_plan != null
		and movement_plan.is_valid
		and movement_plan.has_path()
	)


func has_ally_swap() -> bool:
	return ally_swap_target_id != &""


func has_action() -> bool:
	return (
		ability != null
		and aim_coordinate
			!= BattleGrid.INVALID_COORDINATE
	)


func is_wait() -> bool:
	return (
		not has_movement()
		and not has_ally_swap()
		and not has_action()
	)


func get_destination_coordinate() -> Vector2i:
	if has_movement():
		return movement_plan.target_coordinate

	if has_ally_swap():
		return ally_swap_target_coordinate

	return origin_coordinate


func get_score() -> float:
	return score_breakdown.get_total_score()


func create_action_command(
	actor: CombatantState
) -> BattleActionCommand:
	if (
		not has_action()
		or actor == null
		or actor.instance_id != actor_id
	):
		return null

	return BattleActionCommand.new(
		actor,
		ability,
		aim_coordinate
	)


func get_stable_sort_key() -> String:
	var kind_rank := _get_kind_rank()

	var ability_id := ""

	if ability != null:
		ability_id = String(
			ability.ability_id
		)

	var destination := (
		get_destination_coordinate()
	)

	return (
		"%02d|%s|%d:%d|%d:%d|%s"
		% [
			kind_rank,
			ability_id,
			destination.y,
			destination.x,
			aim_coordinate.y,
			aim_coordinate.x,
			String(
				ally_swap_target_id
			),
		]
	)


func _get_kind_rank() -> int:
	if has_movement() and has_action():
		return 4

	if has_ally_swap() and has_action():
		return 5

	if has_action():
		return 1

	if has_movement():
		return 2

	if has_ally_swap():
		return 3

	return 0