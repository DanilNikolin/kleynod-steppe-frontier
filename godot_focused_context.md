# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/damage/damage_calculator.gd', 'core/battle/effects/effect_resolver.gd']`
- Allow addons: `False`
- Included files planned: `3`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_sabre_slash.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   └── statuses
│       └── debug
│           └── debug_cracked_defense.tres
├── core
│   └── battle
│       ├── abilities
│       │   └── ability_definition.gd
│       ├── actions
│       │   ├── battle_action_command.gd
│       │   ├── battle_action_result.gd
│       │   ├── battle_action_service.gd
│       │   └── battle_effect_result.gd
│       ├── ai
│       │   ├── basic_melee_ai_controller.gd
│       │   └── basic_melee_ai_turn_plan.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   └── effect_resolver.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   └── battle_status_instance.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   └── battle
│       ├── abilities
│       │   ├── battle_ability_panel.gd
│       │   └── battle_ability_panel.tscn
│       ├── actions
│       │   ├── battle_action_outcome.gd
│       │   └── battle_action_runner.gd
│       ├── ai
│       │   ├── basic_melee_ai_turn_outcome.gd
│       │   └── basic_melee_ai_turn_runner.gd
│       ├── combatants
│       │   ├── battle_combatant_presenter.gd
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   └── placeholder_combatant_visual.tscn
│       ├── grid
│       │   ├── battle_grid_overlay_presenter.gd
│       │   ├── battle_grid_view.gd
│       │   └── battle_grid_view.tscn
│       └── movement
│           ├── battle_movement_outcome.gd
│           └── battle_movement_runner.gd
├── project.godot
└── scenes
	├── debug
	│   ├── battle_grid_sandbox.gd
	│   └── battle_grid_sandbox.tscn
	└── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `core/battle/damage/damage_calculator.gd`
```gdscript
class_name DamageCalculator
extends RefCounted


func calculate_raw_damage(
	attacker: CombatantState,
	effect: DamageEffect
) -> int:
	if attacker == null or effect == null:
		return 0

	var attribute_damage := floori(
		float(attacker.strength)
		* effect.strength_scaling
	)

	return maxi(
		0,
		effect.base_damage + attribute_damage
	)


func calculate_effective_armor(
	target: CombatantState,
	effect: DamageEffect
) -> int:
	if target == null or effect == null:
		return 0

	return maxi(
		0,
		target.armor - effect.armor_piercing
	)


func calculate_resolved_damage(
	attacker: CombatantState,
	target: CombatantState,
	effect: DamageEffect
) -> int:
	var raw_damage := calculate_raw_damage(
		attacker,
		effect
	)

	if raw_damage <= 0:
		return 0

	var effective_armor := calculate_effective_armor(
		target,
		effect
	)

	var damage_after_armor := maxi(
		0,
		raw_damage - effective_armor
	)

	var allowed_minimum := mini(
		effect.minimum_damage,
		raw_damage
	)

	return maxi(
		allowed_minimum,
		damage_after_armor
	)
```

---

## FILE: `core/battle/effects/effect_resolver.gd`
```gdscript
class_name EffectResolver
extends RefCounted


const FAILURE_INVALID_EFFECT: StringName = &"invalid_effect"
const FAILURE_INVALID_SOURCE: StringName = &"invalid_source"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_UNSUPPORTED_EFFECT: StringName = &"unsupported_effect"


var damage_calculator := DamageCalculator.new()


func can_resolve(effect: BattleEffect) -> bool:
	return effect is DamageEffect


func resolve(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
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
			target
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
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = (
		damage_calculator.calculate_raw_damage(
			source,
			effect
		)
	)

	result.resolved_amount = (
		damage_calculator.calculate_resolved_damage(
			source,
			target,
			effect
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount - result.resolved_amount
	)

	result.previous_value = target.current_health

	result.applied_amount = target.apply_resolved_damage(
		result.resolved_amount
	)

	result.current_value = target.current_health

	result.target_died = (
		result.previous_value > 0
		and result.current_value == 0
	)

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
```

---

## FILE: `project.godot`
```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="kleynod-steppe-frontier"
config/features=PackedStringArray("4.5", "Forward Plus")
config/icon="res://icon.svg"

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

---


## ✅ STATS
- Total files in tree: 67
- Readable files: 63
- Included files written: 3
- Trimmed files: 0
- Total lines written: 221
