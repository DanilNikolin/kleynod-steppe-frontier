@tool
class_name RemoveStatusEffect
extends BattleEffect


enum FilterMode {
	SPECIFIC_STATUSES,
	STATUS_TAG,
	ALL_HARMFUL,
	ALL_BENEFICIAL,
}


@export_group("Status Removal")

@export
var filter_mode: FilterMode = (
	FilterMode.SPECIFIC_STATUSES
)

## В этом режиме снимаются все перечисленные статусы,
## которые сейчас присутствуют на цели.
@export
var specific_statuses: Array[BattleStatusDefinition] = []

## В этом режиме снимаются все статусы,
## содержащие указанный тег.
@export
var status_tag: StringName = &""


func matches_status_definition(
	status_definition: BattleStatusDefinition
) -> bool:
	if status_definition == null:
		return false

	match filter_mode:
		FilterMode.SPECIFIC_STATUSES:
			for specific_status in specific_statuses:
				if specific_status == null:
					continue

				if (
					specific_status.status_id
					== status_definition.status_id
				):
					return true

			return false

		FilterMode.STATUS_TAG:
			return status_definition.has_tag(
				status_tag
			)

		FilterMode.ALL_HARMFUL:
			return (
				status_definition.polarity
				== BattleStatusDefinition
					.Polarity.HARMFUL
			)

		FilterMode.ALL_BENEFICIAL:
			return (
				status_definition.polarity
				== BattleStatusDefinition
					.Polarity.BENEFICIAL
			)

	return false


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	match filter_mode:
		FilterMode.SPECIFIC_STATUSES:
			if specific_statuses.is_empty():
				errors.append(
					"Specific status removal requires "
					+"at least one status definition."
				)

			var used_status_ids: Dictionary = {}

			for status_index in range(
				specific_statuses.size()
			):
				var status_definition := (
					specific_statuses[
						status_index
					]
				)

				if status_definition == null:
					errors.append(
						"Specific status at index %d is null."
						% status_index
					)

					continue

				if not status_definition.is_valid_definition():
					errors.append(
						"Specific status at index %d "
						% status_index
						+"is invalid."
					)

					continue

				if used_status_ids.has(
					status_definition.status_id
				):
					errors.append(
						"Specific status '%s' is duplicated."
						% status_definition.status_id
					)

					continue

				used_status_ids[
					status_definition.status_id
				] = true

		FilterMode.STATUS_TAG:
			if status_tag == &"":
				errors.append(
					"Status tag removal requires "
					+"a non-empty tag."
				)

		FilterMode.ALL_HARMFUL:
			pass

		FilterMode.ALL_BENEFICIAL:
			pass

	return errors