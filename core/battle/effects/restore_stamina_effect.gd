@tool
class_name RestoreStaminaEffect
extends BattleEffect


@export_group("Stamina Restoration")

@export_range(1, 9999, 1)
var stamina_amount: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if stamina_amount <= 0:
		errors.append(
			"Stamina amount must be greater than zero."
		)

	return errors