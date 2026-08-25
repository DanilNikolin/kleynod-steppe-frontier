class_name BattleActionPreviewService
extends RefCounted


const FAILURE_PREVIEW_EFFECT_FAILED: StringName = (
	&"preview_effect_failed"
)

const FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED: StringName = (
	&"preview_movement_commit_failed"
)


var action_service: BattleActionService

var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)


func _init(
	p_action_service: BattleActionService
) -> void:
	assert(
		p_action_service != null,
		"Action preview service requires "
		+"a battle action service."
	)

	action_service = p_action_service


func create_preview(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleActionPreviewResult:
	var result := (
		BattleActionPreviewResult.new()
	)

	if command != null:
		result.aim_coordinate = (
			command.aim_coordinate
		)

		if command.actor != null:
			result.actor_id = (
				command.actor.instance_id
			)

		if command.ability != null:
			result.ability_id = (
				command.ability.ability_id
			)

	var failure_code := (
		action_service.get_validation_failure(
			session,
			command
		)
	)

	if (
		failure_code != &""
		and not _is_previewable_surface_failure(
			failure_code
		)
	):
		result.failure_code = failure_code
		return result

	var targeting_result := (
		action_service.get_targeting_result(
			session,
			command
		)
	)

	if not targeting_result.is_valid:
		result.failure_code = (
			targeting_result.failure_code
		)

		return result

	result.surface_placement_previews = (
		_create_surface_placement_previews(
			session,
			command,
			targeting_result
		)
	)

	## Невозможное размещение всё равно считается
	## успешно построенным preview.
	## Само действие выполнить по-прежнему нельзя.
	if failure_code != &"":
		result.failure_code = failure_code
		result.is_valid = (
			not result
				.surface_placement_previews
				.is_empty()
		)

		return result

	var normal_simulation := _simulate(
		session,
		command,
		targeting_result,
		false
	)

	if not bool(
		normal_simulation.get(
			"is_valid",
			false
		)
	):
		result.failure_code = (
			normal_simulation.get(
				"failure_code",
				FAILURE_PREVIEW_EFFECT_FAILED
			)
		)

		return result

	var critical_simulation := _simulate(
		session,
		command,
		targeting_result,
		true
	)

	if not bool(
		critical_simulation.get(
			"is_valid",
			false
		)
	):
		result.failure_code = (
			critical_simulation.get(
				"failure_code",
				FAILURE_PREVIEW_EFFECT_FAILED
			)
		)

		return result

	var normal_states: Dictionary = (
		normal_simulation[
			"states"
		]
	)

	var critical_states: Dictionary = (
		critical_simulation[
			"states"
		]
	)

	var normal_results: Dictionary = (
		normal_simulation[
			"results_by_target"
		]
	)

	var critical_results: Dictionary = (
		critical_simulation[
			"results_by_target"
		]
	)

	for original_target in (
		_get_preview_targets(
			command,
			targeting_result,
			normal_states
		)
	):
		if original_target == null:
			continue

		var target_id := (
			original_target.instance_id
		)

		var normal_state = (
			normal_states.get(
				target_id
			) as BattlePreviewCombatantState
		)

		var critical_state = (
			critical_states.get(
				target_id
			) as BattlePreviewCombatantState
		)

		if (
			normal_state == null
			or critical_state == null
		):
			continue

		var target_preview := (
			BattleTargetPreview.new()
		)

		target_preview.target_id = target_id

		if original_target.definition != null:
			target_preview.display_name = (
				original_target
				.definition
				.display_name
			)

		target_preview.initial_health = (
			original_target.current_health
		)

		target_preview.initial_guard = (
			original_target.current_guard
		)

		target_preview.initial_position = (
			original_target.grid_position
		)

		target_preview.normal_final_health = (
			normal_state.current_health
		)

		target_preview.normal_final_guard = (
			normal_state.current_guard
		)

		target_preview.normal_final_position = (
			normal_state.grid_position
		)

		target_preview.critical_final_health = (
			critical_state.current_health
		)

		target_preview.critical_final_guard = (
			critical_state.current_guard
		)

		target_preview.critical_final_position = (
			critical_state.grid_position
		)

		target_preview.normal_effect_results = (
			_get_effect_results(
				normal_results,
				target_id
			)
		)

		target_preview.critical_effect_results = (
			_get_effect_results(
				critical_results,
				target_id
			)
		)

		result.target_previews.append(
			target_preview
		)

	result.is_valid = true
	return result


func _is_previewable_surface_failure(
	failure_code: StringName
) -> bool:
	return (
		failure_code
			== BattleSurfaceEffectController
				.FAILURE_SURFACE_CELL_HAS_OBSTACLE
		or failure_code
			== BattleSurfaceEffectController
				.FAILURE_INVALID_SURFACE_COORDINATE
	)


func _create_surface_placement_previews(
	session: BattleSession,
	command: BattleActionCommand,
	targeting_result: BattleTargetingResult
) -> Array[BattleSurfacePlacementPreview]:
	var result: Array[BattleSurfacePlacementPreview] = []

	if (
		session == null
		or session.surface_effect_controller == null
		or command == null
		or command.ability == null
		or targeting_result == null
	):
		return result

	var previews_by_key: Dictionary = {}
	var ordered_keys: PackedStringArray = []

	var surface_controller := (
		session.surface_effect_controller
	)

	for coordinate in (
		targeting_result.affected_coordinates
	):
		for effect in command.ability.effects:
			if not effect is PlaceSurfaceEffect:
				continue

			var place_effect := (
				effect as PlaceSurfaceEffect
			)

			var definition := (
				place_effect.surface_definition
			)

			if definition == null:
				continue

			var preview_key := (
				"%d:%d:%s"
				% [
					coordinate.x,
					coordinate.y,
					definition.surface_effect_id,
				]
			)

			var placement_preview := (
				previews_by_key.get(
					preview_key
				) as BattleSurfacePlacementPreview
			)

			if placement_preview == null:
				placement_preview = (
					BattleSurfacePlacementPreview.new()
				)

				placement_preview.coordinate = (
					coordinate
				)

				placement_preview.surface_effect_id = (
					definition.surface_effect_id
				)

				var existing_instance := (
					surface_controller.get_effect_at(
						coordinate,
						definition.surface_effect_id
					)
				)

				placement_preview.will_add = (
					existing_instance == null
				)

				placement_preview.will_update = (
					existing_instance != null
				)

				if existing_instance != null:
					placement_preview.previous_is_permanent = (
						existing_instance.is_permanent
					)

					placement_preview.previous_remaining_rounds = (
						existing_instance.remaining_rounds
					)

				previews_by_key[
					preview_key
				] = placement_preview

				ordered_keys.append(
					preview_key
				)

			## Если в одной способности несколько
			## PlaceSurfaceEffect с одинаковым ID,
			## итоговые данные берём от последнего.
			placement_preview.surface_display_name = (
				definition.display_name
			)

			placement_preview.final_is_permanent = (
				definition.duration_rounds == 0
			)

			placement_preview.final_remaining_rounds = (
				maxi(
					0,
					definition.duration_rounds
				)
			)

			placement_preview.presentation_color = (
				definition.presentation_color
			)

			placement_preview.failure_code = (
				surface_controller.get_placement_failure(
					session,
					coordinate,
					definition
				)
			)

			placement_preview.can_place = (
				placement_preview.failure_code == &""
			)

			if not placement_preview.can_place:
				placement_preview.will_add = false
				placement_preview.will_update = false

	for preview_key in ordered_keys:
		var placement_preview := (
			previews_by_key.get(
				preview_key
			) as BattleSurfacePlacementPreview
		)

		if placement_preview != null:
			result.append(
				placement_preview
			)

	return result

func _get_preview_targets(
	command: BattleActionCommand,
	targeting_result: BattleTargetingResult,
	normal_states: Dictionary
) -> Array[CombatantState]:
	var result: Array[CombatantState] = []
	var used_ids: Dictionary = {}

	for target in (
		targeting_result.affected_combatants
	):
		if target == null:
			continue

		if used_ids.has(
			target.instance_id
		):
			continue

		used_ids[target.instance_id] = true
		result.append(target)

	if (
		command == null
		or command.actor == null
	):
		return result

	var actor_preview_state = (
		normal_states.get(
			command.actor.instance_id
		) as BattlePreviewCombatantState
	)

	var actor_position_changed: bool = (
		actor_preview_state != null
		and actor_preview_state.grid_position
			!= command.actor.grid_position
	)

	var ability_affects_source := (
		_has_source_recipient_effect(
			command.ability
		)
	)

	if (
		actor_preview_state != null
		and (
			actor_position_changed
			or ability_affects_source
		)
		and not used_ids.has(
			command.actor.instance_id
		)
	):
		used_ids[
			command.actor.instance_id
		] = true

		result.append(
			command.actor
		)

	return result


func _has_source_recipient_effect(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	for effect in ability.effects:
		if (
			effect != null
			and effect.targets_source()
		):
			return true

	return false


func _get_relocation_effect(
	ability: AbilityDefinition
) -> BattleEffect:
	if ability == null:
		return null

	for effect in ability.effects:
		if (
			effect is SwapPositionsEffect
			or effect is TeleportEffect
		):
			return effect

	return null


func _simulate_relocation(
	effect: BattleEffect,
	source: BattlePreviewCombatantState,
	preview_states: Dictionary,
	preview_grid: BattlePreviewGridState,
	targeting_result: BattleTargetingResult
) -> Dictionary:
	var results_by_target: Dictionary = {}
	var effect_result := BattleEffectResult.new()

	effect_result.effect_id = effect.effect_id
	effect_result.source_id = source.instance_id
	effect_result.applied_amount = 1

	if effect is SwapPositionsEffect:
		if (
			targeting_result
			.affected_combatants
			.size() != 1
		):
			return {
				"is_valid": false,
				"failure_code": (
					BattleActionService
					.FAILURE_INVALID_RELOCATION_TARGET
				),
			}

		var original_target := (
			targeting_result
			.affected_combatants[0]
		)

		var target := (
			preview_states.get(
				original_target.instance_id
			) as BattlePreviewCombatantState
		)

		if target == null:
			return {
				"is_valid": false,
				"failure_code": (
					BattleActionService
					.FAILURE_INVALID_RELOCATION_TARGET
				),
			}

		var source_origin := source.grid_position
		var target_origin := target.grid_position

		if not preview_grid.try_swap_occupants(
			source.instance_id,
			target.instance_id
		):
			return {
				"is_valid": false,
				"failure_code": (
					FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED
				),
			}

		source.grid_position = target_origin
		target.grid_position = source_origin

		effect_result.effect_kind = (
			&"swap_positions"
		)

		effect_result.relocation_kind = &"swap"

		effect_result.target_id = (
			target.instance_id
		)

		effect_result.secondary_target_id = (
			target.instance_id
		)

		effect_result.movement_origin = (
			source_origin
		)

		effect_result.movement_destination = (
			target_origin
		)

		effect_result.secondary_movement_origin = (
			target_origin
		)

		effect_result.secondary_movement_destination = (
			source_origin
		)

		effect_result.is_successful = true

		results_by_target[
			source.instance_id
		] = [effect_result]

		results_by_target[
			target.instance_id
		] = [effect_result]

	elif effect is TeleportEffect:
		if (
			targeting_result
			.affected_coordinates
			.size() != 1
		):
			return {
				"is_valid": false,
				"failure_code": (
					BattleActionService
					.FAILURE_NO_AFFECTED_COORDINATES
				),
			}

		var origin := source.grid_position
		var destination := (
			targeting_result
			.affected_coordinates[0]
		)

		if not preview_grid.try_move_occupant(
			source.instance_id,
			destination
		):
			return {
				"is_valid": false,
				"failure_code": (
					FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED
				),
			}

		source.grid_position = destination

		effect_result.effect_kind = &"teleport"
		effect_result.relocation_kind = &"teleport"

		effect_result.target_id = (
			source.instance_id
		)

		effect_result.movement_origin = origin

		effect_result.movement_destination = (
			destination
		)

		effect_result.is_successful = true

		results_by_target[
			source.instance_id
		] = [effect_result]

	else:
		return {
			"is_valid": false,
			"failure_code": (
				BattleActionService
					.FAILURE_INVALID_RELOCATION_ABILITY
			),
		}

	return {
		"is_valid": true,
		"failure_code": &"",
		"states": preview_states,
		"results_by_target": results_by_target,
	}


func _simulate(
	session: BattleSession,
	command: BattleActionCommand,
	targeting_result: BattleTargetingResult,
	force_standard_critical: bool
) -> Dictionary:
	var preview_states: Dictionary = {}

	for combatant in session.get_all_combatants():
		if combatant == null:
			continue

		preview_states[
			combatant.instance_id
		] = BattlePreviewCombatantState.new(
			combatant
		)

	var preview_grid := (
		BattlePreviewGridState.new(
			session
		)
	)

	var results_by_target: Dictionary = {}

	var source = (
		preview_states.get(
			command.actor.instance_id
		) as BattlePreviewCombatantState
	)

	if source == null:
		return {
			"is_valid": false,
			"failure_code": (
				BattleActionService
					.FAILURE_INVALID_ACTOR
			),
		}

	var relocation_effect := (
		_get_relocation_effect(
			command.ability
		)
	)

	if relocation_effect != null:
		return _simulate_relocation(
			relocation_effect,
			source,
			preview_states,
			preview_grid,
			targeting_result
		)

	var resolved_source_effect_ids: Dictionary = {}

	for original_target in (
		targeting_result.affected_combatants
	):
		if original_target == null:
			continue

		var target = (
			preview_states.get(
				original_target.instance_id
			) as BattlePreviewCombatantState
		)

		if target == null:
			continue

		for effect in command.ability.effects:
			if effect == null:
				continue

			## Координатные эффекты рассчитываются
			## отдельно от состояния бойца.
			if (
				effect is PlaceSurfaceEffect
				or effect is SwapPositionsEffect
				or effect is TeleportEffect
			):
				continue

			var resolved_target: BattlePreviewCombatantState = (
				target
			)

			if effect.targets_source():
				if not effect.repeats_for_affected_targets():
					if resolved_source_effect_ids.has(
						effect.effect_id
					):
						continue

					resolved_source_effect_ids[
						effect.effect_id
					] = true

				resolved_target = source

			elif not target.is_alive:
				## Смерть выбранной цели пропускает
				## последующие TARGET-эффекты,
				## но не отменяет SOURCE-эффекты.
				continue

			var effect_result := _preview_effect(
				effect,
				source,
				resolved_target,
				preview_grid,
				force_standard_critical
			)

			_append_effect_result(
				results_by_target,
				resolved_target.instance_id,
				effect_result
			)

			if (
				effect_result == null
				or not effect_result.is_successful
			):
				return {
					"is_valid": false,
					"failure_code": (
						effect_result.failure_code
						if effect_result != null
						else FAILURE_PREVIEW_EFFECT_FAILED
					),
				}

			if effect_result.target_died:
				preview_grid.remove_occupant(
					resolved_target.instance_id
				)

	## Поддержка способностей, где SOURCE-эффект есть,
	## а affected_combatants пуст — например,
	## действие по свободной клетке с усилением себя.
	for effect in command.ability.effects:
		if (
			effect == null
			or not effect.targets_source()
			or effect.repeats_for_affected_targets()
			or resolved_source_effect_ids.has(
				effect.effect_id
			)
		):
			continue

		if (
			effect is PlaceSurfaceEffect
			or effect is SwapPositionsEffect
			or effect is TeleportEffect
		):
			continue

		resolved_source_effect_ids[
			effect.effect_id
		] = true

		var effect_result := _preview_effect(
			effect,
			source,
			source,
			preview_grid,
			force_standard_critical
		)

		_append_effect_result(
			results_by_target,
			source.instance_id,
			effect_result
		)

		if (
			effect_result == null
			or not effect_result.is_successful
		):
			return {
				"is_valid": false,
				"failure_code": (
					effect_result.failure_code
					if effect_result != null
					else FAILURE_PREVIEW_EFFECT_FAILED
				),
			}

	return {
		"is_valid": true,
		"failure_code": &"",
		"states": preview_states,
		"results_by_target": (
			results_by_target
		),
	}


func _append_effect_result(
	results_by_target: Dictionary,
	target_id: StringName,
	effect_result: BattleEffectResult
) -> void:
	if (
		target_id == &""
		or effect_result == null
	):
		return

	var target_results: Array = (
		results_by_target.get(
			target_id,
			[]
		)
	)

	target_results.append(
		effect_result
	)

	results_by_target[
		target_id
	] = target_results


func _preview_effect(
	effect: BattleEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	preview_grid: BattlePreviewGridState,
	force_standard_critical: bool
) -> BattleEffectResult:
	if effect is HeroCoreEffect:
		return target.preview_hero_core_effect(
			effect as HeroCoreEffect,
			source.instance_id
		)

	if effect is HealthCostEffect:
		return _preview_health_cost(
			effect as HealthCostEffect,
			source,
			target
		)

	if effect is RestoreStaminaEffect:
		return _preview_restore_stamina(
			effect as RestoreStaminaEffect,
			source,
			target
		)

	if effect is DamageEffect:
		return _preview_damage(
			effect as DamageEffect,
			source,
			target,
			force_standard_critical
		)

	if effect is HealEffect:
		return _preview_heal(
			effect as HealEffect,
			source,
			target
		)

	if effect is GrantGuardEffect:
		return _preview_grant_guard(
			effect as GrantGuardEffect,
			source,
			target
		)

	if effect is ApplyStatusEffect:
		return _preview_apply_status(
			effect as ApplyStatusEffect,
			source,
			target
		)

	if effect is RemoveStatusEffect:
		return _preview_remove_status(
			effect as RemoveStatusEffect,
			source,
			target
		)

	if effect is ForcedMovementEffect:
		return _preview_forced_movement(
			effect as ForcedMovementEffect,
			source,
			target,
			preview_grid
		)

	var result := BattleEffectResult.new()
	result.failure_code = (
		BattleActionService
			.FAILURE_UNSUPPORTED_EFFECT
	)

	return result


func _preview_health_cost(
	effect: HealthCostEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"health_cost"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = (
		effect.health_cost
	)

	result.resolved_amount = (
		effect.health_cost
	)

	result.previous_value = (
		target.current_health
	)

	if not target.can_pay_health_cost(
		effect.health_cost,
		effect.minimum_remaining_health
	):
		result.failure_code = (
			EffectResolver
				.FAILURE_HEALTH_COST_CANNOT_BE_PAID
		)

		return result

	result.applied_amount = (
		target.pay_health_cost(
			effect.health_cost,
			effect.minimum_remaining_health
		)
	)

	result.current_value = (
		target.current_health
	)

	if (
		result.applied_amount
		!= effect.health_cost
	):
		result.failure_code = (
			EffectResolver
				.FAILURE_HEALTH_COST_CANNOT_BE_PAID
		)

		return result

	result.is_successful = true
	return result


func _preview_restore_stamina(
	effect: RestoreStaminaEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"restore_stamina"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = (
		effect.stamina_amount
	)

	result.resolved_amount = (
		effect.stamina_amount
	)

	result.previous_stamina = (
		target.current_stamina
	)

	result.previous_value = (
		target.current_stamina
	)

	result.previous_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.applied_amount = (
		target.restore_stamina(
			effect.stamina_amount,
			&"ability_preview"
		)
	)

	result.current_stamina = (
		target.current_stamina
	)

	result.current_value = (
		target.current_stamina
	)

	result.current_stamina_restoration_debt = (
		target.get_stamina_restoration_debt()
	)

	result.stamina_restoration_debt_paid_amount = maxi(
		0,
		result.previous_stamina_restoration_debt
			- result
				.current_stamina_restoration_debt
	)

	result.is_successful = true
	return result


func _preview_damage(
	effect: DamageEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	force_standard_critical: bool
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = target.armor

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
		damage_calculator
		.calculate_effective_armor_from_value(
			target.get_effective_armor(),
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator
		.calculate_raw_damage_from_effect(
			effect
		)
	)

	result.critical_was_enabled = (
		effect.crit_mode
		!= DamageEffect.CritMode.DISABLED
	)

	result.critical_was_guaranteed = (
		effect.crit_mode
		== DamageEffect.CritMode.GUARANTEED
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent_from_values(
			effect,
			source.crit_chance_bonus_percent,
			true
		)
	)

	result.critical_multiplier = (
		damage_calculator
		.calculate_critical_multiplier_from_values(
			effect,
			source.crit_damage_bonus_percent
		)
	)

	result.was_critical = (
		result.critical_was_guaranteed
		or (
			effect.crit_mode
				== DamageEffect.CritMode.STANDARD
			and force_standard_critical
			and result.critical_chance_percent > 0
		)
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
		.calculate_resolved_damage_from_values(
			result.effective_armor,
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

	result.previous_value = (
		target.current_health
	)

	var remaining_damage := (
		result.resolved_amount
	)

	var absorbed_amount := mini(
		remaining_damage,
		target.current_guard
	)

	target.current_guard -= absorbed_amount
	remaining_damage -= absorbed_amount

	result.guard_absorbed_amount = (
		absorbed_amount
	)

	if remaining_damage > 0:
		var previous_health := (
			target.current_health
		)

		target.current_health = maxi(
			0,
			target.current_health
			- remaining_damage
		)

		result.applied_amount = (
			previous_health
			- target.current_health
		)

	result.target_died = (
		result.previous_value > 0
		and target.current_health == 0
	)

	if result.target_died:
		target.current_guard = 0

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true
	return result


func _preview_heal(
	effect: HealEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.base_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	target.current_health = mini(
		target.max_health,
		target.current_health
		+ result.resolved_amount
	)

	result.applied_amount = (
		target.current_health
		- result.previous_value
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true
	return result


func _preview_grant_guard(
	effect: GrantGuardEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
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

	target.current_guard = mini(
		target.max_health,
		target.current_guard
		+ result.resolved_amount
	)

	result.applied_amount = (
		target.current_guard
		- result.previous_guard
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true
	return result


func _preview_apply_status(
	effect: ApplyStatusEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	var status_definition := (
		effect.status_definition
	)

	if (
		status_definition == null
		or not status_definition
			.is_valid_definition()
	):
		result.failure_code = (
			&"invalid_status_definition"
		)

		return result

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)

	if target.has_status_id_immunity(
		status_definition.status_id
	):
		result.status_application_blocked_by_immunity = true
		result.status_immunity_kind = &"status_id"
		result.status_immunity_value = (
			status_definition.status_id
		)

		result.is_successful = true
		return result

	var matching_immunity_tag := (
		target.get_matching_status_immunity_tag(
			status_definition
		)
	)

	if matching_immunity_tag != &"":
		result.status_application_blocked_by_immunity = true
		result.status_immunity_kind = &"tag"
		result.status_immunity_value = (
			matching_immunity_tag
		)

		result.is_successful = true
		return result

	var previous_snapshot := (
		target.get_status_snapshot(
			status_definition.status_id
		)
	)

	result.status_was_added = (
		previous_snapshot.is_empty()
	)

	if not previous_snapshot.is_empty():
		result.previous_status_stack_count = int(
			previous_snapshot.get(
				"stack_count",
				0
			)
		)

		result.previous_status_remaining_turns = int(
			previous_snapshot.get(
				"remaining_turns",
				0
			)
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	if not target.apply_status_definition(
		status_definition
	):
		result.failure_code = (
			&"status_application_failed"
		)

		return result

	var current_snapshot := (
		target.get_status_snapshot(
			status_definition.status_id
		)
	)

	result.current_status_stack_count = int(
		current_snapshot.get(
			"stack_count",
			0
		)
	)

	result.current_status_remaining_turns = int(
		current_snapshot.get(
			"remaining_turns",
			0
		)
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true
	return result


func _preview_remove_status(
	effect: RemoveStatusEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"remove_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var matching_status_ids := (
		target.get_status_ids_matching_removal(
			effect
		)
	)

	for status_id in matching_status_ids:
		var snapshot := target.get_status_snapshot(
			status_id
		)

		var status_definition := (
			snapshot.get(
				"definition"
			) as BattleStatusDefinition
		)

		if status_definition == null:
			continue

		result.removed_status_ids.append(
			status_id
		)

		result.removed_status_display_names.append(
			status_definition.display_name
		)

		target.remove_status_snapshot(
			status_id
		)

	result.applied_amount = (
		result.removed_status_ids.size()
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true
	return result
	
func _preview_forced_movement(
	effect: ForcedMovementEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	preview_grid: BattlePreviewGridState
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

	var resolution := (
		forced_movement_service
		.create_resolution_from_coordinates(
			source.grid_position,
			target.grid_position,
			target.is_alive,
			effect,
			Callable(
				preview_grid,
				"is_inside"
			),
			Callable(
				preview_grid,
				"is_walkable"
			)
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

	for coordinate in resolution.path:
		if not preview_grid.try_move_occupant(
			target.instance_id,
			coordinate
		):
			result.failure_code = (
				FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED
			)

			return result

		target.grid_position = coordinate

	result.is_successful = true
	return result


func _get_effect_results(
	results_by_target: Dictionary,
	target_id: StringName
) -> Array[BattleEffectResult]:
	var result: Array[BattleEffectResult] = []

	if not results_by_target.has(
		target_id
	):
		return result

	for value in results_by_target[
		target_id
	]:
		var effect_result := (
			value as BattleEffectResult
		)

		if effect_result != null:
			result.append(
				effect_result
			)

	return result
