@tool
class_name BattleStatusDefinition
extends Resource


enum ReapplyRule {
	REFRESH_DURATION,
	ADD_STACK_AND_REFRESH,
	KEEP_EXISTING,
}


@export_group("Identity")

@export
var status_id: StringName = &""

@export
var display_name: String = "Unnamed Status"

@export_multiline
var description: String = ""


@export_group("Lifetime")

## Количество завершённых ходов носителя,
## после которых статус исчезнет.
@export_range(1, 999, 1)
var duration_turns: int = 1

@export_range(1, 99, 1)
var max_stacks: int = 1

@export
var reapply_rule: ReapplyRule = (
	ReapplyRule.REFRESH_DURATION
)


@export_group("Stat Modifiers")

@export
var stat_modifiers: Array[BattleStatModifier] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if status_id == &"":
		errors.append(
			"Status ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Status display name is empty."
		)

	if duration_turns <= 0:
		errors.append(
			"Status duration must be greater than zero."
		)

	if max_stacks <= 0:
		errors.append(
			"Maximum status stacks must be greater than zero."
		)

	for modifier_index in range(
		stat_modifiers.size()
	):
		var modifier := stat_modifiers[
			modifier_index
		]

		if modifier == null:
			errors.append(
				"Stat modifier at index %d is null."
				% modifier_index
			)

			continue

		for modifier_error in (
			modifier.get_validation_errors()
		):
			errors.append(
				"Stat modifier %d: %s"
				% [
					modifier_index,
					modifier_error,
				]
			)

	return errors