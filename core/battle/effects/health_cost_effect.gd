@tool
class_name HealthCostEffect
extends BattleEffect


@export_group("Health Cost")

@export_range(1, 9999, 1)
var health_cost: int = 1

## После оплаты у бойца должно остаться
## не меньше этого количества Health.
@export_range(1, 9999, 1)
var minimum_remaining_health: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if health_cost <= 0:
		errors.append(
			"Health cost must be greater than zero."
		)

	if minimum_remaining_health <= 0:
		errors.append(
			"Minimum remaining health must be greater than zero."
		)

	if recipient != BattleEffect.Recipient.SOURCE:
		errors.append(
			"Health cost effect must target its source."
		)

	return errors