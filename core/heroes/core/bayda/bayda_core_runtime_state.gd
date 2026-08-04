class_name BaydaCoreRuntimeState
extends HeroCoreRuntimeState


var base_max_stamina: int = 1

var unbroken_available: bool = true
var is_fractured: bool = false

## Неоплаченная часть периодического урона.
## Следующее восстановление Stamina сначала
## погашает этот долг.
var exhaustion_debt: int = 0

## Постоянное до конца текущего боя уменьшение
## Max Stamina от «Стиснуть зубы».
var grit_teeth_max_stamina_penalty: int = 0

## Нижняя граница после всех штрафов.
var minimum_effective_max_stamina: int = 1

var _incoming_action_depth: int = 0
var _survived_current_action: bool = false


func initialize(
	p_definition,
	p_owner
) -> void:
	super.initialize(
		p_definition,
		p_owner
	)

	var combatant := _get_owner()

	if combatant == null:
		return

	base_max_stamina = maxi(
		1,
		combatant.max_stamina
	)

	_sync_max_stamina_to_health()


func begin_incoming_action_resolution() -> void:
	_incoming_action_depth += 1

	if _incoming_action_depth == 1:
		_survived_current_action = false


func end_incoming_action_resolution() -> void:
	_incoming_action_depth = maxi(
		0,
		_incoming_action_depth - 1
	)

	if _incoming_action_depth == 0:
		_survived_current_action = false


func modify_health_damage(
	amount: int,
	damage_kind: StringName
) -> int:
	var combatant := _get_owner()
	var bayda_definition = definition

	if (
		combatant == null
		or bayda_definition == null
		or amount <= 0
		or not combatant.is_alive
	):
		return maxi(
			0,
			amount
		)

	## Пока Байда выше 1 HP, периодический урон
	## работает как обычный урон по здоровью.
	if damage_kind == BattleDamageKind.PERIODIC:
		if combatant.current_health > 1:
			return amount

		## На 1 HP периодический урон больше
		## не затрагивает здоровье.
		var drained_stamina := (
			combatant.drain_stamina(
				amount
			)
		)

		var unpaid_amount := maxi(
			0,
			amount - drained_stamina
		)

		if unpaid_amount > 0:
			exhaustion_debt += unpaid_amount

		state_changed.emit()

		return 0

	if damage_kind != BattleDamageKind.DIRECT:
		return amount

	var is_lethal := (
		amount >= combatant.current_health
	)

	if not is_lethal:
		return amount

	## После срабатывания Несломленности все остальные
	## попадания того же действия оставляют Байду на 1 HP.
	if (
		_incoming_action_depth > 0
		and _survived_current_action
	):
		return maxi(
			0,
			combatant.current_health - 1
		)

	if not unbroken_available:
		return amount

	if is_fractured:
		return amount

	if not combatant.can_spend_stamina(
		bayda_definition.unbroken_stamina_cost
	):
		return amount

	if not combatant.spend_stamina(
		bayda_definition.unbroken_stamina_cost
	):
		return amount

	unbroken_available = false
	is_fractured = true

	if _incoming_action_depth > 0:
		_survived_current_action = true

	state_changed.emit()

	return maxi(
		0,
		combatant.current_health - 1
	)


func modify_stamina_restoration(
	amount: int,
	_reason: StringName
) -> int:
	if amount <= 0:
		return 0

	if exhaustion_debt <= 0:
		return amount

	var paid_debt := mini(
		amount,
		exhaustion_debt
	)

	exhaustion_debt -= paid_debt

	if paid_debt > 0:
		state_changed.emit()

	return maxi(
		0,
		amount - paid_debt
	)


func get_stamina_restoration_debt() -> int:
	return maxi(
		0,
		exhaustion_debt
	)


func on_health_changed(
	previous_health: int,
	current_health: int,
	reason: StringName
) -> void:
	var combatant := _get_owner()
	var bayda_definition = definition

	if (
		combatant == null
		or bayda_definition == null
		or current_health <= 0
	):
		return

	var previous_tier: int = (
		bayda_definition.get_health_tier(
			previous_health
		)
	)

	var current_tier: int = (
		bayda_definition.get_health_tier(
			current_health
		)
	)

	## Max Stamina зависит от фактического HP
	## независимо от причины его изменения.
	var max_stamina_changed := (
		_sync_max_stamina_to_health()
	)

	var restored_stamina: int = 0

	## Пороговая награда выдаётся только за урон,
	## который Байде навязал противник или окружение.
	##
	## Добровольная цена здоровья расширяет
	## Max Stamina, но не создаёт дополнительное топливо.
	if (
		reason == &"damage"
		and current_health < previous_health
		and current_tier > previous_tier
	):
		var crossed_threshold_count := (
			current_tier - previous_tier
		)

		restored_stamina = (
			combatant.restore_stamina(
				crossed_threshold_count
					* bayda_definition
						.stamina_per_crossed_threshold,
				&"health_threshold"
			)
		)

	if (
		max_stamina_changed
		or restored_stamina > 0
	):
		state_changed.emit()


func can_resolve_effect(
	effect
) -> bool:
	return effect is BaydaGritTeethEffect


func get_effect_validation_failure(
	effect
) -> StringName:
	var failure_code: StringName = (
		super.get_effect_validation_failure(
			effect
		)
	)

	if failure_code != &"":
		return failure_code

	var combatant := _get_owner()

	if (
		combatant == null
		or not combatant.is_alive
	):
		return FAILURE_INVALID_CORE_OWNER

	return &""


func resolve_effect(
	effect,
	source_id: StringName,
	target_id: StringName
) -> BattleEffectResult:
	var result := super.resolve_effect(
		effect,
		source_id,
		target_id
	)

	if result.failure_code != &"":
		return result

	var grit_effect: BaydaGritTeethEffect = (
		effect as BaydaGritTeethEffect
	)

	if grit_effect == null:
		result.failure_code = (
			FAILURE_UNSUPPORTED_CORE_EFFECT
		)

		return result

	var combatant := _get_owner()

	if combatant == null:
		result.failure_code = (
			FAILURE_INVALID_CORE_OWNER
		)

		return result

	result.core_effect_kind = (
		BaydaGritTeethEffect
			.CORE_EFFECT_KIND
	)

	result.raw_amount = (
		grit_effect.stamina_restoration
	)

	result.resolved_amount = (
		grit_effect.stamina_restoration
	)

	result.previous_max_stamina = (
		combatant.max_stamina
	)

	result.previous_stamina = (
		combatant.current_stamina
	)

	result.previous_value = (
		combatant.current_stamina
	)

	result.previous_stamina_restoration_debt = (
		get_stamina_restoration_debt()
	)

	result.previous_unbroken_available = (
		unbroken_available
	)

	result.previous_fractured = (
		is_fractured
	)

	## Сначала возвращаем защитный механизм.
	unbroken_available = true
	is_fractured = false

	## Затем навсегда ухудшаем потолок
	## текущего боя.
	grit_teeth_max_stamina_penalty += (
		grit_effect
			.max_stamina_reduction
	)

	minimum_effective_max_stamina = maxi(
		minimum_effective_max_stamina,
		grit_effect.minimum_max_stamina
	)

	_sync_max_stamina_to_health()

	## И только после нового потолка
	## восстанавливаем Current Stamina.
	result.applied_amount = (
		combatant.restore_stamina(
			grit_effect.stamina_restoration,
			&"bayda_grit_teeth"
		)
	)

	result.current_max_stamina = (
		combatant.max_stamina
	)

	result.current_stamina = (
		combatant.current_stamina
	)

	result.current_value = (
		combatant.current_stamina
	)

	result.current_stamina_restoration_debt = (
		get_stamina_restoration_debt()
	)

	result.stamina_restoration_debt_paid_amount = maxi(
		0,
		result.previous_stamina_restoration_debt
			- result
				.current_stamina_restoration_debt
	)

	result.max_stamina_penalty_applied_amount = (
		grit_effect
			.max_stamina_reduction
	)

	result.current_unbroken_available = (
		unbroken_available
	)

	result.current_fractured = (
		is_fractured
	)

	result.unbroken_was_restored = (
		not result.previous_unbroken_available
		and result.current_unbroken_available
	)

	result.fracture_was_removed = (
		result.previous_fractured
		and not result.current_fractured
	)

	result.is_successful = true

	state_changed.emit()

	return result

func get_debug_summary() -> String:
	var combatant := _get_owner()
	var bayda_definition = definition

	if (
		combatant == null
		or bayda_definition == null
	):
		return "Core Байды не инициализирован."

	var unbroken_text := (
		"готова"
		if unbroken_available
		else "потрачена"
	)

	var fracture_text := (
		"есть"
		if is_fractured
		else "нет"
	)

	return (
		"Несломленность: %s | "
		% unbroken_text
		+"Надлом: %s | "
		% fracture_text
		+"Долг истощения: %d | "
		% exhaustion_debt
		+"HP-порог: %d | "
		% bayda_definition.get_health_tier(
			combatant.current_health
		)
		+"Базовая Max Stamina: %d | "
		% base_max_stamina
		+"Штраф «Стиснуть зубы»: %d"
		% grit_teeth_max_stamina_penalty
	)


func create_runtime_copy(
	p_new_owner
) -> HeroCoreRuntimeState:
	var result := BaydaCoreRuntimeState.new()

	result.definition = definition
	result.owner = p_new_owner

	result.base_max_stamina = base_max_stamina

	result.unbroken_available = (
		unbroken_available
	)

	result.is_fractured = (
		is_fractured
	)

	result.exhaustion_debt = (
		exhaustion_debt
	)

	result.grit_teeth_max_stamina_penalty = (
		grit_teeth_max_stamina_penalty
	)

	result.minimum_effective_max_stamina = (
		minimum_effective_max_stamina
	)

	result._incoming_action_depth = (
		_incoming_action_depth
	)

	result._survived_current_action = (
		_survived_current_action
	)

	return result


func _sync_max_stamina_to_health() -> bool:
	var combatant := _get_owner()
	var bayda_definition = definition

	if (
		combatant == null
		or bayda_definition == null
	):
		return false

	var stamina_bonus: int = (
		bayda_definition
			.get_max_stamina_bonus_for_health(
				combatant.current_health
			)
	)

	var resolved_max_stamina: int = (
		base_max_stamina
		+ stamina_bonus
		- grit_teeth_max_stamina_penalty
	)

	resolved_max_stamina = maxi(
		minimum_effective_max_stamina,
		resolved_max_stamina
	)

	return combatant.set_max_stamina(
		resolved_max_stamina,
		true
	)


func _get_owner() -> CombatantState:
	return owner as CombatantState