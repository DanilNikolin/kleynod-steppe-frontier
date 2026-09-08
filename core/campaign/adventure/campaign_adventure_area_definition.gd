@tool
class_name CampaignAdventureAreaDefinition
extends Resource


@export_group("Identity")

@export
var area_id: StringName = &""

@export
var display_name: String = "Unnamed Adventure Area"

@export_multiline
var description: String = ""


@export_group("Sites")

@export
var sites: Array[CampaignAdventureSiteDefinition] = []


func get_site(
	site_id: StringName
) -> CampaignAdventureSiteDefinition:
	if site_id == &"":
		return null

	for site in sites:
		if (
			site != null
			and site.site_id == site_id
		):
			return site

	return null


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if area_id == &"":
		errors.append(
			"Adventure area ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Adventure area display name is empty."
		)

	if sites.is_empty():
		errors.append(
			"Adventure area requires at least one site."
		)

	var used_site_ids: Dictionary = {}

	for site_index in range(
		sites.size()
	):
		var site := sites[
			site_index
		]

		if site == null:
			errors.append(
				"Adventure site at index %d is null."
				% site_index
			)

			continue

		for site_error in (
			site.get_validation_errors()
		):
			errors.append(
				"Adventure site %d: %s"
				% [
					site_index,
					site_error,
				]
			)

		if site.site_id == &"":
			continue

		if used_site_ids.has(
			site.site_id
		):
			errors.append(
				"Duplicate adventure site ID: %s."
				% site.site_id
			)

			continue

		used_site_ids[
			site.site_id
		] = true

	for site in sites:
		if site == null:
			continue

		for connected_site_id in (
			site.connected_site_ids
		):
			if get_site(
				connected_site_id
			) == null:
				errors.append(
					"Adventure site '%s' connects "
					% site.site_id
					+"to unknown site '%s'."
					% connected_site_id
				)

	return errors