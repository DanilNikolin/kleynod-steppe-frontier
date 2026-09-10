class_name HeroCoreRuntimeState
extends RefCounted


signal state_changed


const FAILURE_INVALID_CORE_EFFECT: StringName = (
	&"invalid_core_effect"
)

const FAILURE_UNSUPPORTED_CORE_EFFECT: StringName = (
	&"unsupported_core_effect"
)

const FAILURE_INVALID_CORE_OWNER: StringName = (
	&"invalid_core_owner"
)


var definition
var owner


func initialize(
	p_definition,
	p_owner
) -> void:
	definition = p_definition
	owner = p_owner


func begin_incoming_action_resolution() -> void:
	pass


func end_incoming_action_resolution() -> void:
	pass


func modify_health_damage(
	amount: int,
	_damage_kind: StringName
) -> int:
	return maxi(
		0,
		amount
	)


## Позволяет Core изменить любое восстановление Stamina.
## Например, сначала погасить долг истощения.
func modify_stamina_restoration(
	amount: int,
	_reason: StringName
) -> int:
	return maxi(
		0,
		amount
	)


## Общий диагностический интерфейс.
## У большинства героев всегда возвращает 0.
func get_stamina_restoration_debt() -> int:
	return 0


func on_health_changed(
	_previous_health: int,
	_current_health: int,
	_reason: StringName
) -> void:
	pass


## Поддерживает ли конкретный Hero Core этот эффект.
func can_resolve_effect(
	_effect
) -> bool:
	return false


func get_effect_validation_failure(
	effect
) -> StringName:
	if effect == null:
		return FAILURE_INVALID_CORE_EFFECT

	if owner == null:
		return FAILURE_INVALID_CORE_OWNER

	if not can_resolve_effect(
		effect
	):
		return FAILURE_UNSUPPORTED_CORE_EFFECT

	return &""


## Базовый метод создаёт стандартный результат.
## Конкретный Hero Core заполняет его и меняет состояние.
func resolve_effect(
	effect,
	source_id: StringName,
	target_id: StringName
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_kind = &"hero_core"
	result.source_id = source_id
	result.target_id = target_id

	if effect != null:
		result.effect_id = effect.effect_id

	result.failure_code = (
		get_effect_validation_failure(
			effect
		)
	)

	return result


## Короткая строка над фигуркой.
## Пустой текст означает, что постоянный
## боевой индикатор Core не нужен.
func get_battle_indicator_text() -> String:
	return ""


## Цвет короткого индикатора.
func get_battle_indicator_color() -> Color:
	return Color.WHITE


## Подробное состояние Core для hover-панели.
func get_hover_details_text() -> String:
	return get_debug_summary()
	
func get_debug_summary() -> String:
	if definition == null:
		return "Hero Core отсутствует."

	return (
		"%s."
		% definition.display_name
	)


func create_runtime_copy(
	p_new_owner
) -> HeroCoreRuntimeState:
	var result := HeroCoreRuntimeState.new()

	result.definition = definition
	result.owner = p_new_owner

	return result