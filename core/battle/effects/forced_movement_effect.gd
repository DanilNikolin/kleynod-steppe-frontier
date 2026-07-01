@tool
class_name ForcedMovementEffect
extends BattleEffect


enum DirectionMode {
	PUSH_AWAY,
	PULL_TOWARD,
}


@export_group("Forced Movement")

@export
var direction_mode: DirectionMode = (
	DirectionMode.PUSH_AWAY
)

@export_range(1, 99, 1)
var distance: int = 1


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if distance <= 0:
		errors.append(
			"Forced movement distance must be positive."
		)

	return errors