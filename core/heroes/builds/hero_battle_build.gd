class_name HeroBattleBuild
extends RefCounted


var combatant_definition: CombatantDefinition
var loadout: CombatantLoadoutDefinition

var core_module: HeroCoreModuleDefinition

var strength_rank: int = 0
var agility_rank: int = 0
var spirit_rank: int = 0

var active_slot_count: int = 0

var known_personal_ability_ids: Array[StringName] = []
var selected_personal_ability_ids: Array[StringName] = []

var equipment_ability_ids: Array[StringName] = []
var equipped_items: Array[HeroEquipmentItemInstance] = []

var unlocked_feature_ids: Array[StringName] = []


## Источники постоянных бонусов сборки.
##
## Equipment пока нулевой, но интерфейс и resolver
## уже готовы принять его без переделки архитектуры.
var skill_grid_bonuses := HeroBuildStatBonuses.new()
var equipment_bonuses := HeroBuildStatBonuses.new()
var total_bonuses := HeroBuildStatBonuses.new()


func is_valid() -> bool:
	return (
		combatant_definition != null
		and combatant_definition.is_valid_definition()
		and loadout != null
		and loadout.is_valid_definition()
		and (
			core_module == null
			or core_module.is_valid_definition()
		)
	)