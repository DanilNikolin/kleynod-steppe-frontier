@tool
class_name CampaignWorldRouteDefinition
extends Resource


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

	return errors