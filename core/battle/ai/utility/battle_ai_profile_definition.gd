@tool
class_name BattleAIProfileDefinition
extends Resource


const MIN_WEIGHT: float = 0.0
const MAX_WEIGHT: float = 3.0


@export_group("Identity")

@export
var profile_id: StringName = &""

@export
var display_name: String = "Neutral AI"


@export_group("Behavior Weights")

## Насколько сильно AI ценит прямой урон
## и добивание противника.
@export_range(0.0, 3.0, 0.05)
var aggression: float = 1.0

## Насколько сильно AI ценит дебаффы,
## снятие Armor, Stamina pressure и другие
## способы ослабить противника.
@export_range(0.0, 3.0, 0.05)
var control: float = 1.0

## Насколько сильно AI ценит лечение,
## Guard, полезные статусы и поддержку союзников.
@export_range(0.0, 3.0, 0.05)
var support: float = 1.0

## Насколько сильно AI боится добровольного риска:
## собственной потери HP, harmful status,
## опасных поверхностей и т.п.
@export_range(0.0, 3.0, 0.05)
var caution: float = 1.0

## Насколько сильно AI ценит сохранение Stamina
## и избегает дорогих cooldown/resource решений.
@export_range(0.0, 3.0, 0.05)
var economy: float = 1.0

## Насколько сильно AI ценит обычную
## тактическую позицию на поле.
@export_range(0.0, 3.0, 0.05)
var positioning: float = 1.0


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if profile_id == &"":
		errors.append(
			"AI profile ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"AI profile display name is empty."
		)

	var weights := [
		["Aggression", aggression],
		["Control", control],
		["Support", support],
		["Caution", caution],
		["Economy", economy],
		["Positioning", positioning],
	]

	for entry in weights:
		var label: String = entry[0]
		var value: float = float(entry[1])

		if (
			value < MIN_WEIGHT
			or value > MAX_WEIGHT
		):
			errors.append(
				"%s weight must be between %.1f and %.1f."
				% [
					label,
					MIN_WEIGHT,
					MAX_WEIGHT,
				]
			)

	return errors