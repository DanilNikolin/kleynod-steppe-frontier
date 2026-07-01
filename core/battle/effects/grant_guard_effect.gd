@tool
class_name GrantGuardEffect
extends BattleEffect


@export_group("Guard")

@export_range(1, 9999, 1)
var guard_amount: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if guard_amount <= 0:
		errors.append(
			"Guard amount must be greater than zero."
		)

	return errors