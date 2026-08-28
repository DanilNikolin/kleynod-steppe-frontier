@tool
class_name CampaignWorldNodeDefinition
extends Resource


enum NodeType {
	HOME_SETTLEMENT,
	VILLAGE,
	CITY,
	ADVENTURE,
}


@export_group("Identity")

@export
var node_id: StringName = &""

@export
var display_name: String = "Unnamed World Node"

@export_multiline
var description: String = ""


@export_group("World")

@export
var node_type: NodeType = NodeType.ADVENTURE

## Позиция именно на глобальной карте.
## Используется в том числе для автоматического
## расчёта времени путешествия.
@export
var map_position: Vector2 = Vector2.ZERO


@export_group("Adventure")

## Необязательная ссылка на существующую
## CampaignLocationDefinition через stable ID.
##
## Для обычного села/города/дома поле пустое.
## Adventure-нода может иметь battle location,
## но сама World Node от боя не зависит.
@export
var campaign_location_id: StringName = &""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if node_id == &"":
		errors.append(
			"World node ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"World node display name is empty."
		)

	if (
		node_type != NodeType.ADVENTURE
		and campaign_location_id != &""
	):
		errors.append(
			"Only an adventure world node may reference "
			+"a campaign location."
		)

	return errors