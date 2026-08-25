class_name BattleExperienceRewardService
extends RefCounted


func get_defeated_team_experience(
	session: BattleSession,
	team_id: StringName
) -> int:
	if (
		session == null
		or team_id == &""
	):
		return 0

	var result: int = 0

	for combatant in session.get_team_combatants(
		team_id,
		false
	):
		if (
			combatant == null
			or combatant.is_alive
			or combatant.definition == null
		):
			continue

		result += maxi(
			combatant.definition.experience_reward,
			0
		)

	return result
