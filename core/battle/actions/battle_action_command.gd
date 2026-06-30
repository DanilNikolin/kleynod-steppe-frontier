class_name BattleActionCommand
extends RefCounted


var actor: CombatantState
var target: CombatantState
var ability: AbilityDefinition


func _init(
	p_actor: CombatantState = null,
	p_target: CombatantState = null,
	p_ability: AbilityDefinition = null
) -> void:
	actor = p_actor
	target = p_target
	ability = p_ability