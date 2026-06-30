@tool
class_name BattleStatModifier
extends Resource


enum Stat {
	ARMOR,
	STRENGTH,
	AGILITY,
	SPIRIT,
	INITIATIVE,
}


@export_group("Stat")

@export
var stat: Stat = Stat.ARMOR

## Изменение характеристики за каждый стак статуса.
## Например, -2 брони при одном стаке.
@export_range(-999, 999, 1)
var amount_per_stack: int = 0


func get_total_amount(
	stack_count: int
) -> int:
	return (
		amount_per_stack
		* maxi(0, stack_count)
	)


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if amount_per_stack == 0:
		errors.append(
			"Stat modifier amount cannot be zero."
		)

	return errors