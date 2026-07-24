@tool
class_name DamageEffect
extends BattleEffect
enum CritMode {
	DISABLED,
	STANDARD,
	GUARANTEED,
}


@export_group("Damage")

@export_range(0, 9999, 1)
var base_damage: int = 1

## Устаревшее поле для совместимости со старым debug-контентом.
## Новые способности масштабируются только через
## Skill Growth Table.
@export_range(0.0, 20.0, 0.05)
var strength_scaling: float = 0.0

@export_range(0, 999, 1)
var armor_piercing: int = 0

@export_range(0, 999, 1)
var minimum_damage: int = 1

@export_group("Critical Hit")

## Может ли этот конкретный эффект наносить критический урон.
@export
var crit_mode: CritMode = CritMode.STANDARD

## Дополнительный шанс крита конкретного эффекта.
## При стандартном крите входит в общий лимит 35%.
@export_range(-100, 100, 1)
var crit_chance_bonus_percent: int = 0

## Множитель сырого урона при критическом попадании.
@export_range(1.0, 10.0, 0.05)
var critical_multiplier: float = 1.5

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

	if critical_multiplier < 1.0:
		errors.append(
			"Critical multiplier cannot be lower than 1.0."
		)

	return errors