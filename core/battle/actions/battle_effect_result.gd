class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0
var applied_amount: int = 0

var overkill_amount: int:
	get:
		if effect_kind != &"damage":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)

var overheal_amount: int:
	get:
		if effect_kind != &"heal":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)

var target_base_armor: int = 0
var target_status_armor_modifier: int = 0
var target_modified_armor: int = 0

var armor_piercing: int = 0
var effective_armor: int = 0

var status_id: StringName = &""

var status_was_added: bool = false

var previous_status_stack_count: int = 0
var current_status_stack_count: int = 0

var previous_status_remaining_turns: int = 0
var current_status_remaining_turns: int = 0

var previous_target_effective_armor: int = 0
var current_target_effective_armor: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false

var movement_origin: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_destination: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_direction: Vector2i = Vector2i.ZERO

var movement_path: Array[Vector2i] = []

var requested_movement_distance: int = 0
var applied_movement_distance: int = 0

var movement_was_blocked: bool = false
var movement_block_reason: StringName = &""