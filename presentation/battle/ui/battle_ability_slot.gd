class_name BattleAbilitySlot
extends TextureButton

const ACTIVE = preload("res://Graphics/UI/battle/abilities/ability_slot_active.png")
const INACTIVE = preload("res://Graphics/UI/battle/abilities/ability_slot_inactive.png")
var ability: AbilityDefinition

func bind_ability(_combatant: CombatantState, value: AbilityDefinition, index: int) -> void:
	ability = value
	texture_normal = ACTIVE
	$Backing.texture = ACTIVE
	var profile := value.presentation_profile as BattleAbilityPresentationProfile
	$AbilityIcon.texture = profile.icon if profile != null else null
	$AbilityIcon.visible = $AbilityIcon.texture != null
	$CostBadge.show()
	$CostLabel.show()
	$CostLabel.text = str(value.stamina_cost)
	$HotkeyLabel.text = str(index + 1)
	tooltip_text = value.display_name

func bind_empty(index: int) -> void:
	ability = null
	texture_normal = INACTIVE
	$Backing.texture = INACTIVE
	$AbilityIcon.hide()
	$CostBadge.hide()
	$CostLabel.hide()
	$HotkeyLabel.text = str(index + 1)
	tooltip_text = ""
	disabled = true
	set_pressed_no_signal(false)
