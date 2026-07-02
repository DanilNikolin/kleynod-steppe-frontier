class_name EffectResolver
extends RefCounted


const FAILURE_INVALID_EFFECT: StringName = &"invalid_effect"
const FAILURE_INVALID_SOURCE: StringName = &"invalid_source"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_UNSUPPORTED_EFFECT: StringName = &"unsupported_effect"

const FAILURE_INVALID_STATUS_DEFINITION: StringName = (
	&"invalid_status_definition"
)

const FAILURE_STATUS_APPLICATION_FAILED: StringName = (
	&"status_application_failed"
)


var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)

var random_number_generator: RandomNumberGenerator


func _init(
	p_random_number_generator: RandomNumberGenerator = null
) -> void:
	if p_random_number_generator != null:
		random_number_generator = (
			p_random_number_generator
		)

		return

	random_number_generator = (
		RandomNumberGenerator.new()
	)

	random_number_generator.randomize()

func can_resolve(
	effect: BattleEffect
) -> bool:
	return (
		effect is DamageEffect
		or effect is HealEffect
		or effect is GrantGuardEffect
		or effect is ApplyStatusEffect
		or effect is ForcedMovementEffect
	)


func resolve(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession = null,
	bypass_guard: bool = false,
	allow_critical: bool = true
) -> BattleEffectResult:
	if effect == null:
		return _create_failure_result(
			FAILURE_INVALID_EFFECT,
			effect,
			source,
			target
		)

	if source == null:
		return _create_failure_result(
			FAILURE_INVALID_SOURCE,
			effect,
			source,
			target
		)

	if target == null:
		return _create_failure_result(
			FAILURE_INVALID_TARGET,
			effect,
			source,
			target
		)

	if effect is DamageEffect:
		return _resolve_damage(
			effect as DamageEffect,
			source,
			target,
			bypass_guard,
			allow_critical
		)

	if effect is HealEffect:
		return _resolve_heal(
			effect as HealEffect,
			source,
			target
		)

	if effect is GrantGuardEffect:
		return _resolve_grant_guard(
			effect as GrantGuardEffect,
			source,
			target
		)

	if effect is ApplyStatusEffect:
		return _resolve_apply_status(
			effect as ApplyStatusEffect,
			source,
			target
		)

	if effect is ForcedMovementEffect:
		return _resolve_forced_movement(
			effect as ForcedMovementEffect,
			source,
			target,
			session
		)

	return _create_failure_result(
		FAILURE_UNSUPPORTED_EFFECT,
		effect,
		source,
		target
	)


func _resolve_damage(
	effect: DamageEffect,
	source: CombatantState,
	target: CombatantState,
	bypass_guard: bool,
	allow_critical: bool
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = (
		target.armor
	)

	result.target_status_armor_modifier = (
		target.get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	result.target_modified_armor = (
		target.get_effective_armor()
	)

	result.armor_piercing = (
		effect.armor_piercing
	)

	result.effective_armor = (
		damage_calculator.calculate_effective_armor(
			target,
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator.calculate_raw_damage(
			source,
			effect
		)
	)

	result.critical_was_enabled = (
		allow_critical
		and effect.crit_mode
			!= DamageEffect.CritMode.DISABLED
	)

	result.critical_multiplier = (
		effect.critical_multiplier
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent(
			source,
			effect,
			allow_critical
		)
	)

	if result.critical_was_enabled:
		match effect.crit_mode:
			DamageEffect.CritMode.GUARANTEED:
				result.critical_was_guaranteed = true
				result.was_critical = true

			DamageEffect.CritMode.STANDARD:
				if result.critical_chance_percent > 0:
					result.critical_roll_percent = (
						random_number_generator
						.randi_range(
							1,
							100
						)
					)

					result.was_critical = (
						result
						.critical_roll_percent
						<= result
						.critical_chance_percent
					)

	result.raw_amount = (
		result.raw_amount_before_critical
	)

	if result.was_critical:
		result.raw_amount = (
			damage_calculator
			.apply_critical_multiplier(
				result
					.raw_amount_before_critical,
				result.critical_multiplier
			)
		)

	result.resolved_amount = (
		damage_calculator
		.calculate_resolved_damage_from_raw(
			target,
			effect,
			result.raw_amount
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount
		- result.resolved_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.guard_was_bypassed = (
		bypass_guard
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = (
		target.apply_resolved_damage(
			result.resolved_amount,
			bypass_guard
		)
	)

	result.current_guard = (
		target.current_guard
	)

	if bypass_guard:
		result.guard_absorbed_amount = 0

	else:
		result.guard_absorbed_amount = maxi(
			0,
			result.previous_guard
			- result.current_guard
		)

	result.current_value = (
		target.current_health
	)

	result.target_died = (
		result.previous_value > 0
		and result.current_value == 0
	)

	result.is_successful = true

	return result


func _resolve_heal(
	effect: HealEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	var spirit_healing := floori(
		float(
			source.get_effective_spirit()
		)
		* effect.spirit_scaling
	)

	result.raw_amount = maxi(
		0,
		effect.base_healing
		+ spirit_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = target.heal(
		result.resolved_amount
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true

	return result

func _resolve_grant_guard(
	effect: GrantGuardEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"grant_guard"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.guard_amount
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_guard
	)

	result.applied_amount = target.grant_guard(
		result.resolved_amount
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true

	return result
	
func _resolve_apply_status(
	effect: ApplyStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	if (
		effect.status_definition == null
		or not effect
		.status_definition
		.is_valid_definition()
	):
		result.failure_code = (
			FAILURE_INVALID_STATUS_DEFINITION
		)

		return result

	var status_definition := (
		effect.status_definition
	)

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)
	
	var existing_status := target.get_status(
		status_definition.status_id
	)

	result.status_was_added = (
		existing_status == null
	)

	if existing_status != null:
		result.previous_status_stack_count = (
			existing_status.stack_count
		)

		result.previous_status_remaining_turns = (
			existing_status.remaining_turns
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var applied_status := target.add_status(
		status_definition,
		source.instance_id
	)

	if applied_status == null:
		result.failure_code = (
			FAILURE_STATUS_APPLICATION_FAILED
		)

		return result

	result.current_status_stack_count = (
		applied_status.stack_count
	)

	result.current_status_remaining_turns = (
		applied_status.remaining_turns
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true

	return result
	
func _resolve_forced_movement(
	effect: ForcedMovementEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"forced_movement"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.requested_movement_distance = (
		effect.distance
	)

	result.movement_origin = (
		target.grid_position
	)

	if session == null or session.grid == null:
		result.failure_code = (
			&"invalid_session"
		)

		return result

	var resolution := (
		forced_movement_service
		.create_resolution(
			session.grid,
			source,
			target,
			effect
		)
	)

	if not resolution.is_valid:
		result.failure_code = (
			resolution.failure_code
		)

		return result

	result.movement_origin = (
		resolution.origin
	)

	result.movement_destination = (
		resolution.destination
	)

	result.movement_direction = (
		resolution.direction
	)

	result.movement_path = (
		resolution.path.duplicate()
	)

	result.applied_movement_distance = (
		resolution.get_applied_distance()
	)

	result.movement_was_blocked = (
		resolution.was_blocked
	)

	result.movement_block_reason = (
		resolution.block_reason
	)

	var committed := (
		forced_movement_service
		.commit_resolution(
			session.grid,
			target,
			resolution
		)
	)

	if not committed:
		result.failure_code = (
			&"forced_movement_commit_failed"
		)

		return result

	result.is_successful = true
	return result

func _create_failure_result(
	failure_code: StringName,
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.failure_code = failure_code

	if effect != null:
		result.effect_id = effect.effect_id

	if source != null:
		result.source_id = source.instance_id

	if target != null:
		result.target_id = target.instance_id

	return result