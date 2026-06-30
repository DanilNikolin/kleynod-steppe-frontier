class_name BasicMeleeAITurnPlan
extends RefCounted


var is_valid: bool = false
var failure_code: StringName = &""

var actor: CombatantState
var target: CombatantState
var ability: AbilityDefinition

var movement_plan: BattleMovementPlan
var expects_attack_after_movement: bool = false


func has_movement() -> bool:
	return (
		movement_plan != null
		and movement_plan.is_valid
		and movement_plan.has_path()
	)