@tool
class_name BattleEffect
extends Resource


enum Recipient {
	TARGET,
	SOURCE,
}


enum SourceRepeatMode {
	ONCE_PER_ACTION,
	PER_AFFECTED_TARGET,
}

@export_group("Identity")

@export
var effect_id: StringName = &""


@export_group("Resolution")

## TARGET — эффект применяется к выбранной цели.
## SOURCE — эффект применяется к владельцу способности.
@export
var recipient: Recipient = Recipient.TARGET

## Для SOURCE-эффектов определяет,
## сколько раз эффект выполняется.
##
## ONCE_PER_ACTION — один раз за всё действие.
## PER_AFFECTED_TARGET — один раз за каждого
## реально затронутого бойца.
@export
var source_repeat_mode: SourceRepeatMode = (
	SourceRepeatMode.ONCE_PER_ACTION
)

func targets_source() -> bool:
	return recipient == Recipient.SOURCE

func repeats_for_affected_targets() -> bool:
	return (
		targets_source()
		and source_repeat_mode
			== SourceRepeatMode.PER_AFFECTED_TARGET
	)
	

func is_valid_effect() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if effect_id == &"":
		errors.append(
			"Effect ID is empty."
		)

	return errors