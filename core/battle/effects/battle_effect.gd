@tool
class_name BattleEffect
extends Resource


enum Recipient {
	TARGET,
	SOURCE,
}


@export_group("Identity")

@export
var effect_id: StringName = &""


@export_group("Resolution")

## TARGET — эффект применяется к выбранной цели.
## SOURCE — эффект применяется к владельцу способности.
@export
var recipient: Recipient = Recipient.TARGET


func targets_source() -> bool:
	return recipient == Recipient.SOURCE


func is_valid_effect() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effect_id == &"":
		errors.append(
			"Effect ID is empty."
		)

	return errors