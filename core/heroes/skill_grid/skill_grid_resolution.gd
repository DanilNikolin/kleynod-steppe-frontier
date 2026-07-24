class_name SkillGridResolution
extends RefCounted


var is_valid: bool = false
var errors: PackedStringArray = []

var spent_skill_points: int = 0

var strength_bonus: int = 0
var agility_bonus: int = 0
var spirit_bonus: int = 0

var active_slot_bonus: int = 0

var max_health_bonus: int = 0
var max_stamina_bonus: int = 0
var start_stamina_bonus: int = 0
var armor_bonus: int = 0
var initiative_bonus: int = 0

var learned_ability_ids: Array[StringName] = []
var unlocked_feature_ids: Array[StringName] = []


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