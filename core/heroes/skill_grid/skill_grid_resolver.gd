class_name SkillGridResolver
extends RefCounted


func resolve(
	grid: SkillGridDefinition,
	progression: HeroProgressionState
) -> SkillGridResolution:
	var result := SkillGridResolution.new()

	if grid == null:
		result.errors.append(
			"Skill Grid is not assigned."
		)

		return result

	if progression == null:
		result.errors.append(
			"Hero progression state is not assigned."
		)

		return result

	for error in grid.get_validation_errors():
		result.errors.append(
			"Skill Grid: %s"
			% error
		)

	for error in progression.get_validation_errors():
		result.errors.append(
			"Progression: %s"
			% error
		)

	if not result.errors.is_empty():
		return result

	var purchased_ids: Dictionary = {}

	for node_id in progression.purchased_node_ids:
		var node := grid.get_node_definition(
			node_id
		)

		if node == null:
			result.errors.append(
				"Purchased unknown node: %s."
				% node_id
			)

			continue

		purchased_ids[
			node_id
		] = true

	if not result.errors.is_empty():
		return result

	for node_id in progression.purchased_node_ids:
		var node := grid.get_node_definition(
			node_id
		)

		if node == null:
			continue

		# A. Block attachment validation
		if node.block_id != &"":
			if not progression.attached_skill_block_ids.has(
				node.block_id
			):
				result.errors.append(
					"Purchased node '%s' belongs to unattached block '%s'."
					% [
						node.node_id,
						node.block_id,
					]
				)

		# B. Hard prerequisites validation (AND logic)
		for prerequisite_id in (
			node.prerequisite_node_ids
		):
			if purchased_ids.has(
				prerequisite_id
			):
				continue

			result.errors.append(
				"Purchased node '%s' requires '%s'."
				% [
					node.node_id,
					prerequisite_id,
				]
			)

		# C. Graph path validation (OR logic / entry node check)
		if not node.path_parent_node_ids.is_empty():
			var has_any_path_parent_purchased := false

			for path_parent_id in (
				node.path_parent_node_ids
			):
				if purchased_ids.has(
					path_parent_id
				):
					has_any_path_parent_purchased = true
					break

			if not has_any_path_parent_purchased:
				result.errors.append(
					"Purchased node '%s' has no purchased path parents."
					% node.node_id
				)
		elif node.block_id != &"":
			var block := grid.get_block_definition(
				node.block_id
			)

			if (
				block == null
				or not block.entry_node_ids.has(
					node.node_id
				)
			):
				result.errors.append(
					"Purchased node '%s' is not an entry node in block '%s'."
					% [
						node.node_id,
						node.block_id,
					]
				)

	if not result.errors.is_empty():
		return result

	for node_id in progression.purchased_node_ids:
		var node := grid.get_node_definition(
			node_id
		)

		if node == null:
			continue

		result.spent_skill_points += (
			node.skill_point_cost
		)

		_apply_node(
			node,
			result
		)

	result.is_valid = true
	return result


func _apply_node(
	node: SkillGridNodeDefinition,
	result: SkillGridResolution
) -> void:
	match node.node_type:
		SkillGridNodeDefinition.NodeType.BRANCH_RANK:
			match node.branch:
				SkillGridNodeDefinition.Branch.STRENGTH:
					result.stat_bonuses.strength_rank_bonus += (
						node.branch_rank_amount
					)

				SkillGridNodeDefinition.Branch.AGILITY:
					result.stat_bonuses.agility_rank_bonus += (
						node.branch_rank_amount
					)

				SkillGridNodeDefinition.Branch.SPIRIT:
					result.stat_bonuses.spirit_rank_bonus += (
						node.branch_rank_amount
					)

		SkillGridNodeDefinition.NodeType.LEARN_ABILITY:
			if node.granted_ability != null:
				result.add_learned_ability_id(
					node.granted_ability.ability_id
				)

		SkillGridNodeDefinition.NodeType.ACTIVE_SLOT:
			result.stat_bonuses.active_slot_bonus += (
				node.active_slot_amount
			)

		SkillGridNodeDefinition.NodeType.HERO_CORE, \
		SkillGridNodeDefinition.NodeType.UTILITY, \
		SkillGridNodeDefinition.NodeType.GEAR_SYNERGY:
			result.add_unlocked_feature_id(
				node.feature_id
			)

		SkillGridNodeDefinition.NodeType.RARE_STAT:
			_apply_rare_stat_node(
				node,
				result
			)


func _apply_rare_stat_node(
	node: SkillGridNodeDefinition,
	result: SkillGridResolution
) -> void:
	match node.rare_stat:
		SkillGridNodeDefinition.RareStat.MAX_HEALTH:
			result.stat_bonuses.max_health_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.MAX_STAMINA:
			result.stat_bonuses.max_stamina_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.START_STAMINA:
			result.stat_bonuses.start_stamina_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.ARMOR:
			result.stat_bonuses.armor_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.STAMINA_REGENERATION:
			result.stat_bonuses.stamina_regeneration_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.START_GUARD:
			result.stat_bonuses.start_guard_bonus += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.CRIT_CHANCE_PERCENT:
			result.stat_bonuses.crit_chance_bonus_percent += (
				node.rare_stat_amount
			)

		SkillGridNodeDefinition.RareStat.CRIT_DAMAGE_PERCENT:
			result.stat_bonuses.crit_damage_bonus_percent += (
				node.rare_stat_amount
			)