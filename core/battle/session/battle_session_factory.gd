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
		var battle_build := (
			spawn.create_battle_build()
		)

		if (
			battle_build == null
			or not battle_build.is_valid()
		):
			session.clear()
			return null

		var combatant := session.add_combatant(
			spawn.instance_id,
			battle_build.combatant_definition,
			spawn.team_id,
			spawn.coordinate,
			battle_build.loadout
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
