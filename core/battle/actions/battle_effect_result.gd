class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

## Сырой урон до критического множителя.
var raw_amount_before_critical: int = 0

## Был ли крит вообще разрешён для данного разрешения эффекта.
## Периодический урон устанавливает false.
var critical_was_enabled: bool = false

## Был ли крит гарантирован настройками DamageEffect.
var critical_was_guaranteed: bool = false

## Итоговый шанс крита от 0 до 100.
var critical_chance_percent: int = 0

## Выпавшее число от 1 до 100.
## Для гарантированного крита остаётся 0, потому что бросок не нужен.
var critical_roll_percent: int = 0

var critical_multiplier: float = 1.0
var was_critical: bool = false

## Для урона это значение уже включает критический множитель.
var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0

## Для damage это количество урона,
## реально применённого к Health.
var applied_amount: int = 0

## Часть урона, перенаправленная Core
## из Health в другую боевую экономику.
var redirected_damage_amount: int = 0

var damage_was_redirected_from_health: bool = false

var previous_stamina: int = 0
var current_stamina: int = 0
var stamina_drained_amount: int = 0

var previous_stamina_restoration_debt: int = 0
var current_stamina_restoration_debt: int = 0

var stamina_restoration_debt_added_amount: int = 0
var stamina_restoration_debt_paid_amount: int = 0

var overkill_amount: int:
	get:
		if effect_kind != &"damage":
			return 0

		return maxi(
			0,
			resolved_amount
			- guard_absorbed_amount
			- applied_amount
			- redirected_damage_amount
		)

var overheal_amount: int:
	get:
		if effect_kind != &"heal":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)
var overguard_amount: int:
	get:
		if effect_kind != &"grant_guard":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)

var target_base_armor: int = 0
var target_status_armor_modifier: int = 0
var target_modified_armor: int = 0

var armor_piercing: int = 0
var effective_armor: int = 0

var previous_guard: int = 0
var current_guard: int = 0
var guard_absorbed_amount: int = 0
var guard_was_bypassed: bool = false

var status_id: StringName = &""
var status_display_name: String = ""
var status_polarity: int = -1

## Статус не был наложен из-за постоянного иммунитета цели.
## Сам эффект считается успешно обработанным.
var status_application_blocked_by_immunity: bool = false

## status_id или tag.
var status_immunity_kind: StringName = &""

## Конкретный status_id либо совпавший тег.
var status_immunity_value: StringName = &""

## Статусы, реально снятые RemoveStatusEffect.
var removed_status_ids: Array[StringName] = []

var removed_status_display_names: PackedStringArray = []
var removed_status_polarities: PackedInt32Array = []

var status_was_added: bool = false

var previous_status_stack_count: int = 0
var current_status_stack_count: int = 0

var previous_status_remaining_turns: int = 0
var current_status_remaining_turns: int = 0

var previous_target_effective_armor: int = 0
var current_target_effective_armor: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false

var effect_coordinate: Vector2i = BattleGrid.INVALID_COORDINATE

var surface_effect_id: StringName = &""
var surface_display_name: String = ""

var surface_was_added: bool = false
var surface_was_updated: bool = false

var surface_is_permanent: bool = false

var previous_surface_remaining_rounds: int = 0
var current_surface_remaining_rounds: int = 0

var movement_origin: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_destination: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_direction: Vector2i = Vector2i.ZERO

var movement_path: Array[Vector2i] = []

var requested_movement_distance: int = 0
var applied_movement_distance: int = 0

var movement_was_blocked: bool = false
var movement_block_reason: StringName = &""

## Дополнительные данные для мгновенного перемещения.
var relocation_kind: StringName = &""

## Второй участник обмена позициями.
var secondary_target_id: StringName = &""

var secondary_movement_origin: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var secondary_movement_destination: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

## Участники relocation, погибшие от поверхностей
## после появления на новых клетках.
var relocation_defeated_ids: Array[StringName] = []

## Surface triggers, которые произошли внутри эффекта.
## Например, ForcedMovementEffect толкнул цель в огонь,
## и поверхность сработала при входе.
var surface_trigger_results: Array[BattleSurfaceTriggerResult] = []