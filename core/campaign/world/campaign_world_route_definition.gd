@tool
class_name CampaignWorldRouteDefinition
extends Resource


enum TravelMode {
	LAND,
	RIVER,
}


@export_group("Identity")

@export
var route_id: StringName = &""


@export_group("Connection")

## Маршрут пока двусторонний.
## Специальные односторонние переходы, если когда-нибудь
## понадобятся, не закладываем раньше времени.
@export
var node_a_id: StringName = &""

@export
var node_b_id: StringName = &""


@export_group("Mode")

@export
var travel_mode: TravelMode = TravelMode.LAND


@export_group("Travel")

## Модификатор автоматически рассчитанного времени.
## 1.0 — обычный путь.
## 0.8 — хорошая дорога.
## 1.3 — тяжёлая местность.
@export
var travel_multiplier: float = 1.0

## -1 означает автоматический расчёт от расстояния.
## Положительное значение полностью заменяет
## автоматический расчёт для особого маршрута.
@export
var travel_days_override: int = -1


@export_group("Events")

## Необязательный профиль случайных событий.
##
## null = на этом route случайные travel events
## вообще не генерируются.
@export
var travel_event_profile: CampaignTravelEventProfileDefinition


@export_group("Access")

## Если задано, маршрут существует в authored world,
## но становится доступен только пока данный
## HOME settlement effect активен.
@export
var required_home_settlement_effect_id: StringName = &""

## Человекочитаемое объяснение для UI.
@export_multiline
var access_requirement_text: String = ""


func get_travel_mode_display_name() -> String:
	match travel_mode:
		TravelMode.RIVER:
			return "Речной путь"

		_:
			return "Сухопутный путь"


func connects(
	first_node_id: StringName,
	second_node_id: StringName
) -> bool:
	return (
		(
			node_a_id == first_node_id
			and node_b_id == second_node_id
		)
		or (
			node_a_id == second_node_id
			and node_b_id == first_node_id
		)
	)


func get_other_node_id(
	node_id: StringName
) -> StringName:
	if node_id == node_a_id:
		return node_b_id

	if node_id == node_b_id:
		return node_a_id

	return &""


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if route_id == &"":
		errors.append(
			"World route ID is empty."
		)

	if node_a_id == &"":
		errors.append(
			"World route node A ID is empty."
		)

	if node_b_id == &"":
		errors.append(
			"World route node B ID is empty."
		)

	if (
		node_a_id != &""
		and node_a_id == node_b_id
	):
		errors.append(
			"World route cannot connect a node to itself."
		)

	if travel_multiplier <= 0.0:
		errors.append(
			"World route travel multiplier must be positive."
		)

	if (
		travel_days_override != -1
		and travel_days_override <= 0
	):
		errors.append(
			"World route travel override must be -1 "
			+"or a positive number of days."
		)

	if travel_event_profile != null:
		for profile_error in (
			travel_event_profile
				.get_validation_errors()
		):
			errors.append(
				"Travel event profile: %s"
				% profile_error
			)

	return errors