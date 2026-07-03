class_name BattleRelocationResult
extends RefCounted


const KIND_SWAP: StringName = &"swap"
const KIND_TELEPORT: StringName = &"teleport"


var is_successful: bool = false
var failure_code: StringName = &""

var relocation_kind: StringName = &""

var primary_combatant_id: StringName = &""
var secondary_combatant_id: StringName = &""

var primary_origin: Vector2i = BattleGrid.INVALID_COORDINATE
var primary_destination: Vector2i = BattleGrid.INVALID_COORDINATE

var secondary_origin: Vector2i = BattleGrid.INVALID_COORDINATE
var secondary_destination: Vector2i = BattleGrid.INVALID_COORDINATE

var stamina_cost: int = 0
var stamina_spent: int = 0

var primary_surface_results: Array[BattleSurfaceTriggerResult] = []
var secondary_surface_results: Array[BattleSurfaceTriggerResult] = []


func is_swap() -> bool:
	return relocation_kind == KIND_SWAP


func is_teleport() -> bool:
	return relocation_kind == KIND_TELEPORT


func get_all_surface_results() -> Array[BattleSurfaceTriggerResult]:
	var result: Array[BattleSurfaceTriggerResult] = []

	for trigger_result in primary_surface_results:
		if trigger_result != null:
			result.append(trigger_result)

	for trigger_result in secondary_surface_results:
		if trigger_result != null:
			result.append(trigger_result)

	return result