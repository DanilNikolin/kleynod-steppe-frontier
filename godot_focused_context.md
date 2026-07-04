# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/encounters/battle_encounter_definition.gd', 'core/battle/session/battle_session_factory.gd']`
- Allow addons: `False`
- Included files planned: `2`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_bandage.tres
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_fire_line.tres
│   │       ├── debug_full_cleanse.tres
│   │       ├── debug_full_dispel.tres
│   │       ├── debug_guaranteed_critical.tres
│   │       ├── debug_guard_stance.tres
│   │       ├── debug_hamstring.tres
│   │       ├── debug_place_fire_surface.tres
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_rending_cut.tres
│   │       ├── debug_sabre_slash.tres
│   │       ├── debug_shield_bash.tres
│   │       ├── debug_spirit_mend.tres
│   │       ├── debug_stunning_blow.tres
│   │       ├── debug_swap_positions.tres
│   │       ├── debug_sweeping_slash.tres
│   │       └── debug_teleport.tres
│   ├── combatants
│   │   └── debug
│   │       ├── debug
│   │       │   └── debug_steppe_basher.tres
│   │       ├── debug_protected_shaman.tres
│   │       ├── debug_steppe_cleanser.tres
│   │       ├── debug_steppe_disabler.tres
│   │       ├── debug_steppe_guarder.tres
│   │       ├── debug_steppe_healer.tres
│   │       ├── debug_steppe_pyromancer.tres
│   │       ├── debug_steppe_raider.tres
│   │       └── debug_wooden_wall.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_basher_loadout.tres
│   │       ├── debug_steppe_cleanser_loadout.tres
│   │       ├── debug_steppe_disabler_loadout.tres
│   │       ├── debug_steppe_guarder_loadout.tres
│   │       ├── debug_steppe_healer_loadout.tres
│   │       ├── debug_steppe_pyromancer_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   ├── statuses
│   │   └── debug
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_bleeding.tres
│   │       ├── debug_cracked_defense.tres
│   │       ├── debug_immobilized.tres
│   │       ├── debug_regeneration.tres
│   │       └── debug_stunned.tres
│   └── surfaces
│       └── debug
│           └── debug_fire_surface.tres
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
│       │   └── utility
│       │       ├── battle_ai_plan.gd
│       │       ├── battle_ai_plan_evaluator.gd
│       │       ├── battle_ai_plan_generator.gd
│       │       ├── battle_ai_planning_report.gd
│       │       └── battle_ai_score_breakdown.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── apply_status_effect.gd
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   ├── effect_resolver.gd
│       │   ├── forced_movement_effect.gd
│       │   ├── grant_guard_effect.gd
│       │   ├── heal_effect.gd
│       │   ├── place_surface_effect.gd
│       │   ├── remove_status_effect.gd
│       │   ├── swap_positions_effect.gd
│       │   └── teleport_effect.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   ├── battle_surface_spawn_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_forced_movement_resolution.gd
│       │   ├── battle_movement_plan.gd
│       │   ├── battle_movement_service.gd
│       │   ├── battle_relocation_result.gd
│       │   ├── battle_relocation_service.gd
│       │   └── core
│       │       └── battle
│       │           └── movement
│       │               └── battle_forced_movement_service.gd
│       ├── previews
│       │   ├── battle_action_preview_result.gd
│       │   ├── battle_action_preview_service.gd
│       │   ├── battle_preview_combatant_state.gd
│       │   ├── battle_preview_grid_state.gd
│       │   ├── battle_surface_placement_preview.gd
│       │   └── battle_target_preview.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── restrictions
│       │   └── battle_action_restriction.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── simulation
│       │   ├── battle_action_simulation_request.gd
│       │   ├── battle_action_simulation_result.gd
│       │   └── battle_action_simulation_service.gd
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   ├── battle_status_instance.gd
│       │   ├── battle_status_periodic_processor.gd
│       │   ├── battle_status_periodic_trigger.gd
│       │   └── battle_status_periodic_trigger_result.gd
│       ├── surfaces
│       │   ├── battle_surface_effect_controller.gd
│       │   ├── battle_surface_effect_definition.gd
│       │   ├── battle_surface_effect_instance.gd
│       │   └── battle_surface_trigger_result.gd
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
│   ├── battle
│   │   ├── abilities
│   │   │   ├── battle_ability_panel.gd
│   │   │   ├── battle_ability_panel.tscn
│   │   │   └── battle_ability_presentation_builder.gd
│   │   ├── actions
│   │   │   ├── battle_ability_presentation_profile.gd
│   │   │   ├── battle_action_outcome.gd
│   │   │   └── battle_action_runner.gd
│   │   ├── ai
│   │   │   ├── battle_ai_planning_debug_formatter.gd
│   │   │   ├── battle_utility_ai_turn_outcome.gd
│   │   │   └── battle_utility_ai_turn_runner.gd
│   │   ├── combatants
│   │   │   ├── battle_combatant_hover_panel.gd
│   │   │   ├── battle_combatant_hover_panel.tscn
│   │   │   ├── battle_combatant_presenter.gd
│   │   │   ├── combatant_view.gd
│   │   │   ├── combatant_view.tscn
│   │   │   ├── combatant_visual.gd
│   │   │   ├── placeholder_combatant_visual.tscn
│   │   │   └── statuses
│   │   │       ├── battle_status_chip.gd
│   │   │       ├── battle_status_chip.tscn
│   │   │       ├── battle_status_strip.gd
│   │   │       └── battle_status_strip.tscn
│   │   ├── grid
│   │   │   ├── battle_grid_overlay_presenter.gd
│   │   │   ├── battle_grid_view.gd
│   │   │   └── battle_grid_view.tscn
│   │   ├── movement
│   │   │   ├── battle_movement_outcome.gd
│   │   │   └── battle_movement_runner.gd
│   │   ├── previews
│   │   │   ├── battle_action_preview_badge.gd
│   │   │   ├── battle_action_preview_badge.tscn
│   │   │   ├── battle_action_preview_formatter.gd
│   │   │   └── battle_action_preview_presenter.gd
│   │   └── surfaces
│   │       ├── battle_surface_hover_panel.gd
│   │       └── battle_surface_hover_panel.tscn
│   └── common
│       └── controls
│           └── collapsible_panel_controller.gd
├── project.godot
└── scenes
    ├── debug
    │   ├── battle_grid_sandbox.gd
    │   ├── battle_grid_sandbox.tscn
    │   ├── controllers
    │   │   └── battle_sandbox_interaction_controller.gd
    │   └── presentation
    │       └── battle_debug_log_presenter.gd
    └── debug_sechevik.tres
```

---

## 📌 INCLUDED FILES

## FILE: `core/battle/encounters/battle_encounter_definition.gd`
```gdscript
@tool
class_name BattleEncounterDefinition
extends Resource


@export_group("Identity")

@export
var encounter_id: StringName = &""

@export
var display_name: String = "Unnamed Encounter"

@export_multiline
var description: String = ""


@export_group("Grid")

@export_range(1, 100, 1)
var rows: int = 5

@export_range(1, 100, 1)
var columns: int = 10

@export_group("Sides")

@export
var side_rules: BattleSideRules = BattleSideRules.new()

@export_group("Initial Combatants")

@export
var combatant_spawns: Array[CombatantSpawnDefinition] = []


@export_group("Initial Surfaces")

@export
var surface_spawns: Array[BattleSurfaceSpawnDefinition] = []


@export_group("Reinforcements")

@export
var reinforcement_waves: Array[BattleReinforcementWaveDefinition] = []


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if encounter_id == &"":
		errors.append(
			"Encounter ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Encounter display name is empty."
		)

	if rows <= 0:
		errors.append(
			"Encounter must contain at least one row."
		)

	if columns <= 0:
		errors.append(
			"Encounter must contain at least one column."
		)

	if side_rules == null:
		errors.append(
			"Battle side rules are not assigned."
		)

	else:
		for side_error in (
			side_rules.get_validation_errors(
				columns
			)
		):
			errors.append(
				"Battle sides: %s"
				% side_error
			)
	if combatant_spawns.is_empty():
		errors.append(
			"Encounter must contain at least one "
			+"initial combatant."
		)

	var used_instance_ids: Dictionary = {}
	var initial_teams_by_instance_id: Dictionary = {}

	var used_initial_coordinates: Dictionary = {}
	var used_surface_ids_by_coordinate: Dictionary = {}

	var used_team_ids: Dictionary = {}
	var used_wave_ids: Dictionary = {}

	for spawn_index in range(
		combatant_spawns.size()
	):
		var spawn := combatant_spawns[spawn_index]

		if spawn == null:
			errors.append(
				"Initial combatant spawn at index %d is null."
				% spawn_index
			)

			continue

		for spawn_error in spawn.get_validation_errors():
			errors.append(
				"Initial combatant spawn %d: %s"
				% [
					spawn_index,
					spawn_error,
				]
			)

		if spawn.instance_id != &"":
			if used_instance_ids.has(
				spawn.instance_id
			):
				errors.append(
					"Duplicate combatant instance ID: %s."
					% spawn.instance_id
				)

			else:
				used_instance_ids[
					spawn.instance_id
				] = true

				initial_teams_by_instance_id[
					spawn.instance_id
				] = spawn.team_id

		if not is_coordinate_inside(
			spawn.coordinate
		):
			errors.append(
				"Initial combatant '%s' has an invalid "
				% spawn.instance_id
				+"start coordinate: %s."
				% spawn.coordinate
			)

		elif used_initial_coordinates.has(
			spawn.coordinate
		):
			errors.append(
				"Multiple initial combatants use "
				+"coordinate %s."
				% spawn.coordinate
			)

		else:
			used_initial_coordinates[
				spawn.coordinate
			] = true

		if spawn.team_id != &"":
			used_team_ids[
				spawn.team_id
			] = true

		if (
			side_rules != null
			and spawn.team_id != &""
		):
			if not side_rules.is_team_supported(
				spawn.team_id
			):
				errors.append(
					"Initial combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			elif (
				is_coordinate_inside(
					spawn.coordinate
				)
				and not side_rules.is_coordinate_allowed(
					spawn.team_id,
					spawn.coordinate,
					rows,
					columns
				)
			):
				errors.append(
					"Initial combatant '%s' starts "
					% spawn.instance_id
					+"outside its team side: %s."
					% spawn.coordinate
				)

	for surface_spawn_index in range(
		surface_spawns.size()
	):
		var surface_spawn := surface_spawns[
			surface_spawn_index
		]

		if surface_spawn == null:
			errors.append(
				"Initial surface spawn at index %d is null."
				% surface_spawn_index
			)

			continue

		for spawn_error in (
			surface_spawn.get_validation_errors()
		):
			errors.append(
				"Initial surface spawn %d: %s"
				% [
					surface_spawn_index,
					spawn_error,
				]
			)

		if not is_coordinate_inside(
			surface_spawn.coordinate
		):
			errors.append(
				"Initial surface spawn %d has an invalid "
				% surface_spawn_index
				+"coordinate: %s."
				% surface_spawn.coordinate
			)

		var surface_definition := (
			surface_spawn.surface_definition
		)

		if (
			surface_definition != null
			and surface_definition.surface_effect_id
				!= &""
			and is_coordinate_inside(
				surface_spawn.coordinate
			)
		):
			var used_surface_ids: Dictionary = (
				used_surface_ids_by_coordinate.get(
					surface_spawn.coordinate,
					{}
				)
			)

			if used_surface_ids.has(
				surface_definition.surface_effect_id
			):
				errors.append(
					"Duplicate initial surface '%s' "
					% surface_definition.surface_effect_id
					+"at coordinate %s."
					% surface_spawn.coordinate
				)

			else:
				used_surface_ids[
					surface_definition.surface_effect_id
				] = true

				used_surface_ids_by_coordinate[
					surface_spawn.coordinate
				] = used_surface_ids

		if (
			surface_spawn.source_team_id != &""
			and side_rules != null
			and not side_rules.is_team_supported(
				surface_spawn.source_team_id
			)
		):
			errors.append(
				"Initial surface spawn %d uses "
				% surface_spawn_index
				+"unsupported source team ID: %s."
				% surface_spawn.source_team_id
			)

		if surface_spawn.source_instance_id != &"":
			if not initial_teams_by_instance_id.has(
				surface_spawn.source_instance_id
			):
				errors.append(
					"Initial surface spawn %d references "
					% surface_spawn_index
					+"unknown initial source combatant: %s."
					% surface_spawn.source_instance_id
				)

			else:
				var combatant_team_id: StringName = (
					initial_teams_by_instance_id.get(
						surface_spawn.source_instance_id,
						&""
					)
				)

				if (
					surface_spawn.source_team_id != &""
					and surface_spawn.source_team_id
						!= combatant_team_id
				):
					errors.append(
						"Initial surface spawn %d source "
						% surface_spawn_index
						+"team does not match combatant '%s'."
						% surface_spawn.source_instance_id
					)

		if (
			surface_definition != null
			and surface_definition.target_relation
				!= BattleSurfaceEffectDefinition
					.TargetRelation
					.ALL
			and surface_spawn.source_instance_id == &""
			and surface_spawn.source_team_id == &""
		):
			errors.append(
				"Initial surface spawn %d requires "
				% surface_spawn_index
				+"a source combatant or source team "
				+"for its target relation."
			)
			
	for wave_index in range(
		reinforcement_waves.size()
	):
		var wave := reinforcement_waves[wave_index]

		if wave == null:
			errors.append(
				"Reinforcement wave at index %d is null."
				% wave_index
			)

			continue

		for wave_error in wave.get_validation_errors():
			errors.append(
				"Reinforcement wave %d: %s"
				% [
					wave_index,
					wave_error,
				]
			)

		if wave.wave_id != &"":
			if used_wave_ids.has(
				wave.wave_id
			):
				errors.append(
					"Duplicate reinforcement wave ID: %s."
					% wave.wave_id
				)
			else:
				used_wave_ids[
					wave.wave_id
				] = true

		for spawn_index in range(
			wave.combatant_spawns.size()
		):
			var spawn := (
				wave.combatant_spawns[
					spawn_index
				]
			)

			if spawn == null:
				continue

			if spawn.instance_id != &"":
				if used_instance_ids.has(
					spawn.instance_id
				):
					errors.append(
						"Duplicate combatant instance ID "
						+"across encounter: %s."
						% spawn.instance_id
					)
				else:
					used_instance_ids[
						spawn.instance_id
					] = true

			if spawn.team_id != &"":
				used_team_ids[
					spawn.team_id
				] = true

			if (
				side_rules != null
				and spawn.team_id != &""
				and not side_rules.is_team_supported(
					spawn.team_id
				)
			):
				errors.append(
					"Reinforcement combatant '%s' uses "
					% spawn.instance_id
					+"unsupported team ID: %s."
					% spawn.team_id
				)

			for candidate_coordinate in (
				spawn.get_candidate_coordinates()
			):
				if not is_coordinate_inside(
					candidate_coordinate
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has an invalid candidate "
						+"coordinate: %s."
						% candidate_coordinate
					)

					continue

				if (
					side_rules != null
					and side_rules.is_team_supported(
						spawn.team_id
					)
					and not side_rules.is_coordinate_allowed(
						spawn.team_id,
						candidate_coordinate,
						rows,
						columns
					)
				):
					errors.append(
						"Reinforcement combatant '%s' "
						% spawn.instance_id
						+"has a candidate outside "
						+"its team side: %s."
						% candidate_coordinate
					)

	if used_team_ids.size() < 2:
		errors.append(
			"Encounter must contain combatants "
			+"from at least two teams, including "
			+"reinforcement waves."
		)

	return errors


func is_coordinate_inside(
	coordinate: Vector2i
) -> bool:
	return (
		coordinate.x >= 0
		and coordinate.x < columns
		and coordinate.y >= 0
		and coordinate.y < rows
	)
```

---

## FILE: `core/battle/session/battle_session_factory.gd`
```gdscript
class_name BattleSessionFactory
extends RefCounted


func create_from_encounter(
	encounter: BattleEncounterDefinition
) -> BattleSession:
	if encounter == null:
		return null

	if not encounter.is_valid_definition():
		return null

	var session := BattleSession.new(
		encounter.rows,
		encounter.columns,
		encounter.side_rules
	)

	for spawn in encounter.combatant_spawns:
		var combatant := session.add_combatant(
			spawn.instance_id,
			spawn.combatant_definition,
			spawn.team_id,
			spawn.coordinate,
			spawn.get_effective_loadout()
		)

		if combatant == null:
			session.clear()
			return null

	for surface_spawn in encounter.surface_spawns:
		var surface_instance := (
			session
				.surface_effect_controller
				.place_effect(
					session,
					surface_spawn.coordinate,
					surface_spawn.surface_definition,
					surface_spawn.source_instance_id,
					surface_spawn.source_team_id
				)
		)

		if surface_instance == null:
			session.clear()
			return null

	return session
```

---


## ✅ STATS
- Total files in tree: 154
- Readable files: 150
- Included files written: 2
- Trimmed files: 0
- Total lines written: 526
