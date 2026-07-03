class_name BattleActionSimulationRequest
extends RefCounted


var actor_id: StringName = &""

## Обычное свободное перемещение.
var movement_plan: BattleMovementPlan

## Обычный союзный swap через movement interaction.
var ally_swap_target_id: StringName = &""
var ally_swap_stamina_cost: int = 0

## Необязательная способность после перемещения.
var ability: AbilityDefinition

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

## Utility AI не бросает случайный крит.
## GUARANTEED-крит при этом продолжает работать.
var standard_critical_mode: int = (
	EffectResolver
		.StandardCriticalMode
		.NEVER
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