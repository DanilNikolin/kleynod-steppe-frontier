class_name BattleAbilitySlot
extends TextureButton

const ACTIVE = preload("res://Graphics/UI/battle/abilities/ability_slot_active.png")
const INACTIVE = preload("res://Graphics/UI/battle/abilities/ability_slot_inactive.png")
const HOVER = preload("res://Graphics/UI/battle/abilities/ability_slot_hover.png")
const PRESSED = preload("res://Graphics/UI/battle/abilities/ability_slot_pressed.png")
const SELECTED = preload("res://Graphics/UI/battle/abilities/ability_slot_selected.png")
var ability: AbilityDefinition

func _ready() -> void:
	button_up.connect(_release_visual.call_deferred)

func _release_visual() -> void:
	# Binding during pressed can leave BaseButton latched until the next click.
	# Clear only its transient press state; selection is owned by the panel.
	set_pressed_no_signal(false)


func bind_ability(combatant: CombatantState, value: AbilityDefinition, index: int) -> void:
	ability = value
	texture_normal = ACTIVE
	texture_hover = HOVER
	texture_pressed = PRESSED
	$Backing.texture = ACTIVE
	var profile := value.presentation_profile as BattleAbilityPresentationProfile
	$AbilityIcon.texture = profile.icon if profile != null else null
	$AbilityIcon.visible = $AbilityIcon.texture != null
	$CostBadge.show()
	$CostLabel.show()
	$CostLabel.text = str(value.stamina_cost)
	$HotkeyLabel.text = str(index + 1)
	tooltip_text = value.display_name
	var remaining := combatant.get_ability_lock_remaining_turns(value.ability_id)
	var total := value.initial_lock_turns if combatant.get_ability_lock_kind(value.ability_id) == CombatantState.AbilityLockKind.INITIAL else value.cooldown_turns
	$CooldownOverlay.max_value = maxi(1, total)
	$CooldownOverlay.value = remaining
	$CooldownOverlay.visible = remaining > 0

func bind_empty(index: int) -> void:
	ability = null
	texture_normal = INACTIVE
	texture_hover = null
	texture_pressed = null
	$CooldownOverlay.hide()
	$Backing.texture = INACTIVE
	$AbilityIcon.hide()
	$CostBadge.hide()
	$CostLabel.hide()
	$HotkeyLabel.text = str(index + 1)
	tooltip_text = ""
	disabled = true
	set_pressed_no_signal(false)

## Selection persists independently of the transient mouse-down button state.
func set_selected(value: bool) -> void:
	var selected := value and ability != null
	texture_normal = SELECTED if selected else (ACTIVE if ability != null else INACTIVE)
	# Hover must not conceal the selection immediately after mouse release.
	texture_hover = SELECTED if selected else (HOVER if ability != null else null)
