class_name BattleActionPreviewBadge
extends Control

@onready var primary_forecast: PanelContainer = $PrimaryForecast
@onready var primary_margin: MarginContainer = $PrimaryForecast/Margin
@onready var ability_title_label: Label = $PrimaryForecast/Margin/VBox/AbilityTitleLabel
@onready var damage_label: Label = $PrimaryForecast/Margin/VBox/DamageLabel
@onready var guard_absorption_label: Label = $PrimaryForecast/Margin/VBox/GuardAbsorptionLabel
@onready var critical_outcome_label: Label = $PrimaryForecast/Margin/VBox/CriticalOutcomeLabel
@onready var additional_effects_label: Label = $PrimaryForecast/Margin/VBox/AdditionalEffectsLabel
@onready var lethal_banner_label: Label = $PrimaryForecast/Margin/VBox/LethalBannerLabel

@onready var secondary_badge: PanelContainer = $SecondaryBadge
@onready var secondary_label: Label = $SecondaryBadge/Margin/SecondaryLabel

var _preview_revision: int = 0


func _ready() -> void:
	visible = false
	if primary_forecast != null:
		primary_forecast.visible = false
	if secondary_badge != null:
		secondary_badge.visible = false


func show_target_preview(
	preview: BattleTargetPreview,
	ability_name: String = "",
	is_primary: bool = true
) -> void:
	if preview == null:
		clear_preview()
		return

	_preview_revision += 1
	var revision := _preview_revision

	visible = true

	if is_primary:
		_setup_primary_forecast(preview, ability_name)
		if secondary_badge != null:
			secondary_badge.visible = false
		if primary_forecast != null:
			primary_forecast.visible = true
			primary_forecast.modulate.a = 0.0
			_finalize_primary_layout(revision)
	else:
		_setup_secondary_badge(preview)
		if primary_forecast != null:
			primary_forecast.visible = false
		if secondary_badge != null:
			secondary_badge.visible = true


func _setup_primary_forecast(preview: BattleTargetPreview, ability_name: String) -> void:
	# 1. Ability title
	var title_text := ability_name.strip_edges().to_upper()
	if title_text.is_empty():
		title_text = "СПОСОБНОСТЬ"
	ability_title_label.text = title_text

	# 2. Damage & Guard
	var normal_guard_dmg := _sum_guard_absorption(preview.normal_effect_results)
	var normal_hp_dmg := _sum_applied_damage(preview.normal_effect_results)

	if normal_hp_dmg > 0:
		damage_label.text = "−%d HP" % normal_hp_dmg
		damage_label.visible = true
	elif normal_guard_dmg > 0:
		damage_label.text = "0 HP"
		damage_label.visible = true
	else:
		damage_label.visible = false

	# Guard absorption
	if normal_guard_dmg > 0:
		guard_absorption_label.text = "🛡 Поглощено: %d" % normal_guard_dmg
		guard_absorption_label.visible = true
	else:
		guard_absorption_label.visible = false

	# 3. Critical Outcome
	var is_guaranteed := preview.has_guaranteed_critical()
	var critical_chances := preview.get_standard_critical_chances()

	if is_guaranteed:
		critical_outcome_label.text = "КРИТ ГАРАНТИРОВАН"
		critical_outcome_label.visible = true
	elif not critical_chances.is_empty() and preview.has_critical_alternative():
		var crit_hp_dmg := _sum_applied_damage(preview.critical_effect_results)
		critical_outcome_label.text = "Крит: %d%%  →  −%d HP" % [critical_chances[0], crit_hp_dmg]
		critical_outcome_label.visible = true
	else:
		critical_outcome_label.visible = false

	# 4. Additional Effects
	var effect_lines := _build_additional_effect_lines(preview)
	if effect_lines.is_empty():
		additional_effects_label.visible = false
	else:
		additional_effects_label.text = "\n".join(effect_lines)
		additional_effects_label.visible = true

	# 5. Lethality
	if preview.normal_final_health <= 0:
		lethal_banner_label.text = "☠ СМЕРТЕЛЬНО"
		lethal_banner_label.add_theme_color_override("font_color", Color(1, 0.15, 0.15, 1))
		lethal_banner_label.visible = true
	elif preview.critical_final_health <= 0 and preview.has_critical_alternative():
		lethal_banner_label.text = "☠ Критический удар смертелен"
		lethal_banner_label.add_theme_color_override("font_color", Color(1, 0.5, 0.2, 1))
		lethal_banner_label.visible = true
	else:
		lethal_banner_label.visible = false


func _finalize_primary_layout(revision: int) -> void:
	await get_tree().process_frame
	if revision != _preview_revision or not visible or not primary_forecast.visible:
		return

	var min_size: Vector2 = primary_margin.get_combined_minimum_size()
	primary_forecast.size = Vector2(230.0, min_size.y)
	primary_forecast.position = Vector2(-115.0, -min_size.y - 12.0)
	primary_forecast.modulate.a = 1.0


func _setup_secondary_badge(preview: BattleTargetPreview) -> void:
	var lines := PackedStringArray()
	var normal_hp_dmg := _sum_applied_damage(preview.normal_effect_results)
	var normal_guard_dmg := _sum_guard_absorption(preview.normal_effect_results)

	if normal_hp_dmg > 0:
		lines.append("−%d HP" % normal_hp_dmg)
	elif normal_guard_dmg > 0:
		lines.append("🛡 −%d" % normal_guard_dmg)

	for res in preview.normal_effect_results:
		if res == null:
			continue
		if res.status_was_added and not res.status_display_name.is_empty():
			var stack_str := " ×%d" % res.current_status_stack_count if res.current_status_stack_count > 1 else ""
			lines.append("%s%s" % [res.status_display_name, stack_str])
			break

	if preview.normal_final_health <= 0:
		lines.append("☠")

	secondary_label.text = "\n".join(lines) if not lines.is_empty() else "!"


func clear_preview() -> void:
	_preview_revision += 1
	visible = false
	if primary_forecast != null:
		primary_forecast.visible = false
	if secondary_badge != null:
		secondary_badge.visible = false


func _sum_applied_damage(results: Array[BattleEffectResult]) -> int:
	var total := 0
	for res in results:
		if res != null and res.effect_kind == &"damage":
			total += res.applied_amount
	return total


func _sum_guard_absorption(results: Array[BattleEffectResult]) -> int:
	var total := 0
	for res in results:
		if res != null and res.effect_kind == &"damage":
			total += res.guard_absorbed_amount
	return total


func _build_additional_effect_lines(preview: BattleTargetPreview) -> PackedStringArray:
	var lines := PackedStringArray()

	for res in preview.normal_effect_results:
		if res == null:
			continue

		# Status added
		if res.status_was_added and not res.status_display_name.is_empty():
			var stack_str := " ×%d" % res.current_status_stack_count if res.current_status_stack_count > 1 else ""
			lines.append("%s%s" % [res.status_display_name, stack_str])

		# Status removed
		if not res.removed_status_display_names.is_empty():
			lines.append("Снято: %s" % ", ".join(res.removed_status_display_names))

		# Heal
		if res.effect_kind == &"heal" and res.applied_amount > 0:
			lines.append("+%d HP" % res.applied_amount)

		# Guard grant
		if res.effect_kind == &"grant_guard" and res.applied_amount > 0:
			lines.append("+%d ОБ" % res.applied_amount)

	# Forced movement / displacement
	if preview.normal_final_position != BattleGrid.INVALID_COORDINATE and preview.normal_final_position != preview.initial_position:
		var dist := int(abs(preview.normal_final_position.x - preview.initial_position.x) + abs(preview.normal_final_position.y - preview.initial_position.y))
		lines.append("Смещение (%d кл.)" % dist)

	return lines