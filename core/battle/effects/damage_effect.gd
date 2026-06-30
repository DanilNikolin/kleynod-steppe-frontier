@tool
class_name DamageEffect
extends BattleEffect


@export_group("Damage")

@export_range(0, 9999, 1)
var base_damage: int = 1

@export_range(0.0, 20.0, 0.05)
var strength_scaling: float = 1.0

@export_range(0, 999, 1)
var armor_piercing: int = 0

@export_range(0, 999, 1)
var minimum_damage: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if base_damage < 0:
		errors.append("Base damage cannot be negative.")

	if strength_scaling < 0.0:
		errors.append("Strength scaling cannot be negative.")

	if armor_piercing < 0:
		errors.append("Armor piercing cannot be negative.")

	if minimum_damage < 0:
		errors.append("Minimum damage cannot be negative.")

	return errors