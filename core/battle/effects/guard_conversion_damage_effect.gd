@tool
class_name GuardConversionDamageEffect
extends DamageEffect


@export_group("Guard Conversion")

## Максимальное количество Guard, которое
## можно потратить при этом ударе.
@export_range(1, 9999, 1)
var max_guard_spend: int = 1

## Сколько дополнительного сырого урона
## даёт каждая реально потраченная единица Guard.
@export_range(1, 9999, 1)
var bonus_damage_per_guard: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if max_guard_spend <= 0:
		errors.append(
			"Maximum Guard spend must be greater than zero."
		)

	if bonus_damage_per_guard <= 0:
		errors.append(
			"Bonus damage per Guard must be greater than zero."
		)

	return errors