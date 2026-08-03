class_name HeroCoreRuntimeState
extends RefCounted


signal state_changed


var definition
var owner


func initialize(
	p_definition,
	p_owner
) -> void:
	definition = p_definition
	owner = p_owner


func begin_incoming_action_resolution() -> void:
	pass


func end_incoming_action_resolution() -> void:
	pass


func modify_health_damage(
	amount: int,
	_damage_kind: StringName
) -> int:
	return maxi(
		0,
		amount
	)


func on_health_changed(
	_previous_health: int,
	_current_health: int,
	_reason: StringName
) -> void:
	pass


func get_debug_summary() -> String:
	if definition == null:
		return "Hero Core отсутствует."

	return (
		"%s."
		% definition.display_name
	)


func create_runtime_copy(
	p_new_owner
) -> HeroCoreRuntimeState:
	var result := HeroCoreRuntimeState.new()

	result.definition = definition
	result.owner = p_new_owner

	return result