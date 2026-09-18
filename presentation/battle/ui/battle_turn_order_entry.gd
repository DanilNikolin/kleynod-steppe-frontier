class_name BattleTurnOrderEntry
extends Control

const FRIENDLY = preload("res://Graphics/UI/battle/turn_order/turn_friendly_frame.png")
const ENEMY = preload("res://Graphics/UI/battle/turn_order/turn_enemy_frame.png")
var combatant_id: StringName

func bind_combatant(combatant: CombatantState, is_friendly: bool) -> void:
	combatant_id = combatant.instance_id
	$Portrait.texture = combatant.definition.portrait
	$Portrait.visible = $Portrait.texture != null
	$Frame.texture = FRIENDLY if is_friendly else ENEMY
	$Frame.size = $Frame.texture.get_size()
