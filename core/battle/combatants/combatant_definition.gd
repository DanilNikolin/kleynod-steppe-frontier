@tool
class_name CombatantDefinition
extends Resource


@export_group("Identity")

@export
var definition_id: StringName = &""

@export
var display_name: String = "Unnamed Combatant"

@export_multiline
var description: String = ""


@export_group("Battle")

@export
var default_loadout: CombatantLoadoutDefinition

@export_group("AI")

## Необязательный профиль поведения.
## Null означает полностью нейтральные веса 1.0.
@export
var ai_profile: BattleAIProfileDefinition

@export_group("Battlefield Role")

## Участвует ли объект в обычной очереди ходов.
## Стены и другие пассивные боевые объекты могут иметь HP,
## занимать клетку и быть целью, но не получать собственный ход.
@export
var participates_in_turn_order: bool = true

## Защищает ли объект союзные цели, находящиеся за ним
## в том же горизонтальном ряду.
@export
var blocks_hostile_targeting_behind: bool = false

@export_group("Status Immunities")

## Полный иммунитет к конкретным status_id.
@export
var status_immunity_ids: Array[StringName] = []

## Иммунитет ко всем статусам, содержащим указанный тег.
@export
var status_immunity_tags: Array[StringName] = []

@export_group("Primary Attributes")

@export_range(0, 999, 1)
var base_strength: int = 1

@export_range(0, 999, 1)
var base_agility: int = 1

@export_range(0, 999, 1)
var base_spirit: int = 1


@export_group("Secondary Attributes")

@export_range(1, 9999, 1)
var max_health: int = 10

@export_range(0, 999, 1)
var base_armor: int = 0

@export_range(1, 999, 1)
var max_stamina: int = 10

## Стартовая выносливость бойца.
##
## Значение -1 сохраняет старое поведение:
## боец начинает бой с полной Max Stamina.
##
## Это нужно для обратной совместимости со старыми
## CombatantDefinition, где поле ещё не задано.
@export_range(-1, 999, 1)
var start_stamina: int = -1

@export_range(0, 999, 1)
var stamina_regeneration: int = 4

@export_range(0, 999, 1)
var start_guard: int = 0

@export_range(-100, 100, 1)
var base_crit_chance_bonus_percent: int = 0

@export_range(-100, 999, 1)
var base_crit_damage_bonus_percent: int = 0

@export_range(0, 99, 1)
var health_regeneration_every_two_turns: int = 0

@export_range(0, 99, 1)
var guard_regeneration_every_two_turns: int = 0

@export_range(0, 999, 1)
var base_initiative: int = 0

@export_range(0, 99, 1)
var base_morale: int = 2


@export_group("Presentation")

@export
var visual_scene: PackedScene

@export
var visual_tint: Color = Color.WHITE

@export
var portrait: Texture2D


func has_status_id_immunity(
	status_id: StringName
) -> bool:
	return (
		status_id != &""
		and status_immunity_ids.has(
			status_id
		)
	)


func get_matching_status_immunity_tag(
	status_definition: BattleStatusDefinition
) -> StringName:
	if status_definition == null:
		return &""

	for tag in status_definition.tags:
		if (
			tag != &""
			and status_immunity_tags.has(
				tag
			)
		):
			return tag

	return &""


func is_immune_to_status(
	status_definition: BattleStatusDefinition
) -> bool:
	if status_definition == null:
		return false

	if has_status_id_immunity(
		status_definition.status_id
	):
		return true

	return (
		get_matching_status_immunity_tag(
			status_definition
		) != &""
	)

func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if definition_id == &"":
		errors.append("Definition ID is empty.")

	if display_name.strip_edges().is_empty():
		errors.append("Display name is empty.")

	if max_health <= 0:
		errors.append("Maximum health must be greater than zero.")

	if max_stamina <= 0:
		errors.append(
			"Maximum stamina must be greater than zero."
		)

	if start_stamina < -1:
		errors.append(
			"Start stamina cannot be lower than -1."
		)

	if (
		start_stamina >= 0
		and start_stamina > max_stamina
	):
		errors.append(
			"Start stamina cannot be greater "
			+"than maximum stamina."
		)

	if stamina_regeneration < 0:
		errors.append(
			"Stamina regeneration cannot be negative."
		)

	if start_guard < 0:
		errors.append(
			"Start guard cannot be negative."
		)

	if base_crit_damage_bonus_percent < -100:
		errors.append(
			"Base crit damage bonus percent cannot be lower than -100."
		)

	if health_regeneration_every_two_turns < 0:
		errors.append(
			"Health regeneration every two turns cannot be negative."
		)

	if guard_regeneration_every_two_turns < 0:
		errors.append(
			"Guard regeneration every two turns cannot be negative."
		)

	var used_immunity_ids: Dictionary = {}

	for immunity_index in range(
		status_immunity_ids.size()
	):
		var immunity_id := (
			status_immunity_ids[
				immunity_index
			]
		)

		if immunity_id == &"":
			errors.append(
				"Status immunity ID at index %d is empty."
				% immunity_index
			)

			continue

		if used_immunity_ids.has(
			immunity_id
		):
			errors.append(
				"Status immunity ID '%s' is duplicated."
				% immunity_id
			)

			continue

		used_immunity_ids[
			immunity_id
		] = true

	var used_immunity_tags: Dictionary = {}

	for immunity_index in range(
		status_immunity_tags.size()
	):
		var immunity_tag := (
			status_immunity_tags[
				immunity_index
			]
		)

		if immunity_tag == &"":
			errors.append(
				"Status immunity tag at index %d is empty."
				% immunity_index
			)

			continue

		if used_immunity_tags.has(
			immunity_tag
		):
			errors.append(
				"Status immunity tag '%s' is duplicated."
				% immunity_tag
			)

			continue

		used_immunity_tags[
			immunity_tag
		] = true
		
	if default_loadout == null:
		errors.append(
			"Default combatant loadout is not assigned."
		)

	elif not default_loadout.is_valid_definition():
		errors.append(
			"Default combatant loadout is invalid."
		)

	if ai_profile != null:
		for profile_error in (
			ai_profile.get_validation_errors()
		):
			errors.append(
				"AI profile: %s"
				% profile_error
			)

	if visual_scene == null:
		errors.append("Visual scene is not assigned.")

	return errors