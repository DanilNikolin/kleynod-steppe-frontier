class_name CampaignTravelEventRollService
extends RefCounted


func roll_event(
	profile: CampaignTravelEventProfileDefinition,
	occurrence_roll: float,
	selection_roll: float
) -> CampaignTravelEventDefinition:
	if (
		profile == null
		or not profile.is_valid_definition()
	):
		return null

	if not _is_unit_roll(
		occurrence_roll
	):
		return null

	if not _is_unit_roll(
		selection_roll
	):
		return null

	# Первый уровень:
	# происходит ли вообще событие.
	if occurrence_roll >= profile.event_chance:
		return null

	var total_weight := (
		profile.get_total_weight()
	)

	if total_weight <= 0:
		return null

	# selection_roll всегда [0, 1),
	# поэтому target_weight всегда
	# находится в [0, total_weight - 1].
	var target_weight := int(
		floor(
			selection_roll
			* float(total_weight)
		)
	)

	var accumulated_weight := 0

	for entry in profile.entries:
		if (
			entry == null
			or entry.event == null
			or entry.weight <= 0
		):
			continue

		accumulated_weight += entry.weight

		if target_weight < accumulated_weight:
			return entry.event

	return null


func roll_event_progress(
	event: CampaignTravelEventDefinition,
	progress_roll: float
) -> float:
	if (
		event == null
		or not event.is_valid_definition()
	):
		return -1.0

	if (
		progress_roll < 0.0
		or progress_roll > 1.0
	):
		return -1.0

	return lerpf(
		event.min_route_progress,
		event.max_route_progress,
		progress_roll
	)


func _is_unit_roll(
	value: float
) -> bool:
	return (
		value >= 0.0
		and value < 1.0
	)