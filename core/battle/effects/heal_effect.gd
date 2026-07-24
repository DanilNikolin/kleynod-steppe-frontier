@tool
class_name HealEffect
extends BattleEffect


@export_group("Healing")

@export_range(0, 9999, 1)
var base_healing: int = 1

## Устаревшее поле для совместимости со старым debug-контентом.
## Новые способности масштабируются только через
## Skill Growth Table.
@export_range(0.0, 20.0, 0.05)
var spirit_scaling: float = 0.0


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if base_healing < 0:
		errors.append(
			"Base healing cannot be negative."
		)

	if spirit_scaling < 0.0:
		errors.append(
			"Spirit scaling cannot be negative."
		)

	return errors