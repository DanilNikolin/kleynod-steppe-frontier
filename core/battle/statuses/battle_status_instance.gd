class_name BattleStatusInstance
extends RefCounted


var definition: BattleStatusDefinition

var source_instance_id: StringName = &""

var stack_count: int = 1
var remaining_turns: int = 0


var status_id: StringName:
	get:
		if definition == null:
			return &""

		return definition.status_id


var is_expired: bool:
	get:
		return remaining_turns <= 0


func _init(
	p_definition: BattleStatusDefinition,
	p_source_instance_id: StringName = &""
) -> void:
	assert(
		p_definition != null,
		"BattleStatusInstance requires a definition."
	)

	assert(
		p_definition.is_valid_definition(),
		"BattleStatusInstance requires "
		+"a valid status definition."
	)

	definition = p_definition
	source_instance_id = p_source_instance_id

	stack_count = 1
	remaining_turns = definition.duration_turns


func reapply(
	p_source_instance_id: StringName = &""
) -> void:
	if definition == null:
		return

	if p_source_instance_id != &"":
		source_instance_id = (
			p_source_instance_id
		)

	match definition.reapply_rule:
		BattleStatusDefinition.ReapplyRule.REFRESH_DURATION:
			remaining_turns = (
				definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH:
			stack_count = mini(
				definition.max_stacks,
				stack_count + 1
			)

			remaining_turns = (
				definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.KEEP_EXISTING:
			pass


func advance_owner_turn() -> void:
	if remaining_turns <= 0:
		return

	remaining_turns -= 1