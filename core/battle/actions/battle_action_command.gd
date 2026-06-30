class_name BattleActionCommand
extends RefCounted


var actor: CombatantState
var ability: AbilityDefinition

var aim_coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)


func _init(
	p_actor: CombatantState = null,
	p_ability: AbilityDefinition = null,
	p_aim_coordinate: Vector2i = (
		BattleGrid.INVALID_COORDINATE
	)
) -> void:
	actor = p_actor
	ability = p_ability
	aim_coordinate = p_aim_coordinate