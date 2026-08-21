class_name HeroEquipmentResolution
extends RefCounted


var is_valid: bool = false
var errors: PackedStringArray = []

var stat_bonuses := HeroBuildStatBonuses.new()

var equipped_items: Array[HeroEquipmentItemInstance] = []
var primary_ability: AbilityDefinition
var granted_abilities: Array[AbilityDefinition] = []