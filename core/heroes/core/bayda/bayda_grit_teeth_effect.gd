@tool
class_name BaydaGritTeethEffect
extends HeroCoreEffect


const CORE_EFFECT_KIND: StringName = (
	&"bayda_grit_teeth"
)


@export_group("Stamina Restoration")

@export_range(0, 999, 1)
var stamina_restoration: int = 4


@export_group("Maximum Stamina Sacrifice")

@export_range(0, 999, 1)
var max_stamina_reduction: int = 1

@export_range(1, 999, 1)
var minimum_max_stamina: int = 4


func _init() -> void:
	recipient = Recipient.SOURCE


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if not targets_source():
		errors.append(
			"Grit Teeth effect must target the source."
		)

	if stamina_restoration < 0:
		errors.append(
			"Stamina restoration cannot be negative."
		)

	if max_stamina_reduction < 0:
		errors.append(
			"Max Stamina reduction cannot be negative."
		)

	if minimum_max_stamina <= 0:
		errors.append(
			"Minimum Max Stamina must be positive."
		)

	return errors


func get_presentation_text() -> String:
	return (
		"• Восстанавливает Несломленность"
		+"\n• Снимает Надлом"
		+"\n• Максимальная выносливость: -%d "
		% max_stamina_reduction
		+"до конца боя"
		+"\n  Минимум: %d"
		% minimum_max_stamina
		+"\n• Выносливость: +%d"
		% stamina_restoration
		+"\n  Сначала погашает долг истощения"
	)