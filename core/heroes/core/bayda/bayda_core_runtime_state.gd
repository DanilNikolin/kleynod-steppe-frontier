class_name BaydaCoreRuntimeState
extends HeroCoreRuntimeState


var base_max_stamina: int = 1

var unbroken_available: bool = true
var is_fractured: bool = false

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

	## Периодический урон пока проходит обычным путём.
	## В следующем срезе на 1 HP он будет высушивать
	## Stamina и создавать долг истощения.
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


func on_health_changed(
	previous_health: int,
	current_health: int,
	_reason: StringName
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

	var max_stamina_changed := (
		_sync_max_stamina_to_health()
	)

	var restored_stamina: int = 0

	if (
		current_health < previous_health
		and current_tier > previous_tier
	):
		var crossed_threshold_count := (
			current_tier - previous_tier
		)

		restored_stamina = (
			combatant.restore_stamina(
				crossed_threshold_count
				* bayda_definition
					.stamina_per_crossed_threshold
			)
		)

	if (
		max_stamina_changed
		or restored_stamina > 0
	):
		state_changed.emit()


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
		+"HP-порог: %d | "
		% bayda_definition.get_health_tier(
			combatant.current_health
		)
		+"Базовая Max Stamina: %d"
		% base_max_stamina
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

	return combatant.set_max_stamina(
		base_max_stamina + stamina_bonus,
		true
	)


func _get_owner() -> CombatantState:
	return owner as CombatantState