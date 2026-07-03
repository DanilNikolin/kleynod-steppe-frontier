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
