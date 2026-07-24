class_name SkillGridResolution
extends RefCounted


var is_valid: bool = false
var errors: PackedStringArray = []

var spent_skill_points: int = 0

var stat_bonuses := HeroBuildStatBonuses.new()

var learned_ability_ids: Array[StringName] = []
var unlocked_feature_ids: Array[StringName] = []


## Совместимые переходные свойства.
## Новый код должен обращаться через stat_bonuses.

var strength_bonus: int:
	get:
		return stat_bonuses.strength_rank_bonus


var agility_bonus: int:
	get:
		return stat_bonuses.agility_rank_bonus


var spirit_bonus: int:
	get:
		return stat_bonuses.spirit_rank_bonus


var active_slot_bonus: int:
	get:
		return stat_bonuses.active_slot_bonus


var max_health_bonus: int:
	get:
		return stat_bonuses.max_health_bonus


var max_stamina_bonus: int:
	get:
		return stat_bonuses.max_stamina_bonus


var start_stamina_bonus: int:
	get:
		return stat_bonuses.start_stamina_bonus


var armor_bonus: int:
	get:
		return stat_bonuses.armor_bonus


func add_learned_ability_id(
	ability_id: StringName
) -> void:
	if (
		ability_id != &""
		and not learned_ability_ids.has(
			ability_id
		)
	):
		learned_ability_ids.append(
			ability_id
		)


func add_unlocked_feature_id(
	feature_id: StringName
) -> void:
	if (
		feature_id != &""
		and not unlocked_feature_ids.has(
			feature_id
		)
	):
		unlocked_feature_ids.append(
			feature_id
		)