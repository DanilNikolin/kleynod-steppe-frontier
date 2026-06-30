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

@export_range(0, 999, 1)
var stamina_regeneration: int = 4

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
		errors.append("Maximum stamina must be greater than zero.")

	if stamina_regeneration < 0:
		errors.append("Stamina regeneration cannot be negative.")

	if visual_scene == null:
		errors.append("Visual scene is not assigned.")

	return errors