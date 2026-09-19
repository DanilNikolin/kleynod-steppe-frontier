class_name BattleStatusVisualResolver
extends RefCounted

# This order is the display priority, independent of status IDs and rank resources.
const SEMANTICS = ["stun", "immobilized", "bleeding", "burning", "poison", "armor_down", "counterattack", "armor_up", "reactive_guard", "reactive_stamina", "stamina_regen_up"]
const TAGS = ["stun", "immobilized", "bleeding", "burning", "poison", "armor_debuff", "counterattack", "armor_buff", "", "stamina_reaction", "stamina_regeneration_buff"]
const TEXTURES = {
	"stun": preload("res://Graphics/UI/battle/statuses/status_stun.png"),
	"immobilized": preload("res://Graphics/UI/battle/statuses/status_immobilized.png"),
	"bleeding": preload("res://Graphics/UI/battle/statuses/status_bleeding.png"),
	"burning": preload("res://Graphics/UI/battle/statuses/status_burning.png"),
	"poison": preload("res://Graphics/UI/battle/statuses/status_poison.png"),
	"armor_down": preload("res://Graphics/UI/battle/statuses/status_armor_down.png"),
	"counterattack": preload("res://Graphics/UI/battle/statuses/status_counterattack.png"),
	"armor_up": preload("res://Graphics/UI/battle/statuses/status_armor_up.png"),
	"reactive_guard": preload("res://Graphics/UI/battle/statuses/status_reactive_guard.png"),
	"reactive_stamina": preload("res://Graphics/UI/battle/statuses/status_reactive_stamina.png"),
	"stamina_regen_up": preload("res://Graphics/UI/battle/statuses/status_stamina_regen_up.png"),
}

static func resolve(definition: BattleStatusDefinition) -> Array[String]:
	var result: Array[String] = []
	for i in range(SEMANTICS.size()):
		var matches := definition.has_tag(StringName(TAGS[i]))
		if SEMANTICS[i] == "reactive_guard":
			matches = definition.has_tag(&"reaction") and definition.has_tag(&"guard")
		if matches:
			result.append(SEMANTICS[i])
	return result

static func calculate_magnitude(semantic: String, status: BattleStatusInstance) -> int:
	if status == null or status.definition == null:
		return 0
	match semantic:
		"bleeding", "burning", "poison":
			return status.stack_count
		"armor_down":
			var total_armor_mod: int = 0
			for modifier in status.definition.stat_modifiers:
				if modifier != null and modifier.stat == BattleStatModifier.Stat.ARMOR:
					total_armor_mod += modifier.get_total_amount(status.stack_count)
			if total_armor_mod < 0:
				return abs(total_armor_mod)
			return 0
		"armor_up":
			var total_armor_mod: int = 0
			for modifier in status.definition.stat_modifiers:
				if modifier != null and modifier.stat == BattleStatModifier.Stat.ARMOR:
					total_armor_mod += modifier.get_total_amount(status.stack_count)
			if total_armor_mod > 0:
				return total_armor_mod
			return 0
		"stamina_regen_up":
			var total_regen_mod: int = 0
			for modifier in status.definition.stat_modifiers:
				if modifier != null and modifier.stat == BattleStatModifier.Stat.STAMINA_REGENERATION:
					total_regen_mod += modifier.get_total_amount(status.stack_count)
			if total_regen_mod > 0:
				return total_regen_mod
			return 0
		"stun", "immobilized", "counterattack", "reactive_guard", "reactive_stamina":
			return 0
		_:
			return 0

static func entries(state: CombatantState, polarity: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state == null:
		return result
	for status in state.get_active_statuses():
		if polarity >= 0 and status.definition.polarity != polarity:
			continue
		var semantics := resolve(status.definition)
		if semantics.is_empty():
			result.append({"semantic": "", "status": status, "priority": SEMANTICS.size(), "magnitude": 0})
		for semantic in semantics:
			var mag := calculate_magnitude(semantic, status)
			result.append({"semantic": semantic, "status": status, "priority": SEMANTICS.find(semantic), "magnitude": mag})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.priority != b.priority:
			return a.priority < b.priority
		return String(a.status.status_id) < String(b.status.status_id))
	return result
