@tool
class_name BattleSurfaceEffectDefinition
extends Resource


enum TriggerTiming {
	ON_ENTER = 1,
	OWNER_TURN_START = 2,
	OWNER_TURN_END = 4,
}


enum TargetRelation {
	ALL,
	SOURCE_TEAM,
	OPPOSING_TEAM,
}


@export_group("Identity")

@export
var surface_effect_id: StringName = &""

@export
var display_name: String = ""

@export_multiline
var description: String = ""


@export_group("Triggering")

@export_flags(
	"On Enter",
	"Owner Turn Start",
	"Owner Turn End"
)
var trigger_mask: int = (
	TriggerTiming.ON_ENTER
)

## ALL работает и для нейтральных поверхностей.
## Остальные режимы требуют source_team_id
## у runtime-экземпляра поверхности.
@export
var target_relation: TargetRelation = (
	TargetRelation.ALL
)

@export
var effects: Array[BattleEffect] = []

## Применяется ко всем DamageEffect внутри поверхности.
@export
var bypass_guard: bool = false

## Запрещает дальнейшее перемещение после срабатывания.
## Подходит для капканов и вязкой земли.
@export
var stops_movement: bool = false

## Поверхность исчезает после успешного срабатывания.
@export
var consume_after_trigger: bool = false


@export_group("Duration")

## 0 — постоянная поверхность.
## Положительное значение — число полных раундов активности.
@export_range(0, 999, 1)
var duration_rounds: int = 0


@export_group("Debug Presentation")

@export
var presentation_color: Color = Color(
	0.9,
	0.2,
	0.08,
	0.42
)


func has_trigger(
	timing: int
) -> bool:
	return (
		(trigger_mask & timing) != 0
	)


func can_affect_team(
	source_team_id: StringName,
	target_team_id: StringName
) -> bool:
	match target_relation:
		TargetRelation.ALL:
			return true

		TargetRelation.SOURCE_TEAM:
			return (
				source_team_id != &""
				and source_team_id
					== target_team_id
			)

		TargetRelation.OPPOSING_TEAM:
			return (
				source_team_id != &""
				and source_team_id
					!= target_team_id
			)

	return false


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if surface_effect_id == &"":
		errors.append(
			"Surface effect ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Surface effect display name is empty."
		)

	if trigger_mask == 0:
		errors.append(
			"Surface effect has no trigger timings."
		)

	if duration_rounds < 0:
		errors.append(
			"Surface effect duration cannot be negative."
		)

	if effects.is_empty():
		errors.append(
			"Surface effect has no battle effects."
		)

	for effect_index in range(
		effects.size()
	):
		var effect := effects[
			effect_index
		]

		if effect == null:
			errors.append(
				"Battle effect at index %d is null."
				% effect_index
			)

			continue

		if not effect.is_valid_effect():
			errors.append(
				"Battle effect at index %d is invalid."
				% effect_index
			)

	return errors