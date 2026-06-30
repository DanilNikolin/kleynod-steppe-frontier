@tool
class_name AbilityTargetingDefinition
extends Resource


enum AimRequirement {
	ANY_CELL,
	OCCUPIED_CELL,
	EMPTY_CELL,
}


enum RelationMask {
	SELF = 1,
	ALLY = 2,
	ENEMY = 4,
}


const ALL_RELATIONS: int = (
	RelationMask.SELF
	| RelationMask.ALLY
	| RelationMask.ENEMY
)


@export_group("Aim")

@export
var aim_requirement: AimRequirement = (
	AimRequirement.OCCUPIED_CELL
)

@export_flags("Self", "Allies", "Enemies")
var aim_relation_mask: int = RelationMask.ENEMY

## Координаты относительно атакующего,
## когда атакующий смотрит вправо.
## Для правой команды X автоматически зеркалится.
@export
var aim_offsets: Array[Vector2i] = [
	Vector2i(1, 0),
]


@export_group("Impact")

@export_flags("Self", "Allies", "Enemies")
var affected_relation_mask: int = RelationMask.ENEMY

## Координаты относительно выбранной клетки.
## Vector2i.ZERO означает саму выбранную клетку.
@export
var impact_offsets: Array[Vector2i] = [
	Vector2i.ZERO,
]


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if aim_offsets.is_empty():
		errors.append(
			"Targeting must contain at least one aim offset."
		)

	if impact_offsets.is_empty():
		errors.append(
			"Targeting must contain at least one impact offset."
		)

	if (
		aim_relation_mask < 0
		or (
			aim_relation_mask
			& ALL_RELATIONS
		) != aim_relation_mask
	):
		errors.append(
			"Aim relation mask contains unsupported flags."
		)

	if (
		affected_relation_mask < 0
		or (
			affected_relation_mask
			& ALL_RELATIONS
		) != affected_relation_mask
	):
		errors.append(
			"Affected relation mask contains unsupported flags."
		)

	if (
		aim_requirement
		!= AimRequirement.EMPTY_CELL
		and aim_relation_mask == 0
	):
		errors.append(
			"Occupied aim cells require at least one "
			+"allowed relation."
		)

	_append_duplicate_offset_errors(
		aim_offsets,
		"Aim",
		errors
	)

	_append_duplicate_offset_errors(
		impact_offsets,
		"Impact",
		errors
	)

	return errors


func is_single_enemy_targeting() -> bool:
	return (
		aim_requirement
		== AimRequirement.OCCUPIED_CELL
		and aim_relation_mask
		== RelationMask.ENEMY
		and affected_relation_mask
		== RelationMask.ENEMY
		and impact_offsets.size() == 1
		and impact_offsets[0] == Vector2i.ZERO
	)


func _append_duplicate_offset_errors(
	offsets: Array[Vector2i],
	label: String,
	errors: PackedStringArray
) -> void:
	var used_offsets: Dictionary = {}

	for offset in offsets:
		if used_offsets.has(offset):
			errors.append(
				"%s offsets contain duplicate coordinate: %s."
				% [
					label,
					offset,
				]
			)

			continue

		used_offsets[offset] = true