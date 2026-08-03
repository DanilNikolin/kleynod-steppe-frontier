extends Control


const BAYDA_HERO: HeroDefinition = preload(
	"res://content/heroes/bayda/"
	+"debug_bayda_core_hero.tres"
)

const DEBUG_PROGRESSION: HeroProgressionState = preload(
	"res://content/heroes/debug/"
	+"debug_sechevik_progression_purchase_test.tres"
)


var build_resolver := HeroBattleBuildResolver.new()

var bayda: CombatantState

var _last_event: String = "Sandbox запущен."


func _ready() -> void:
	_reset_bayda()


func _reset_bayda() -> void:
	var progression := (
		DEBUG_PROGRESSION.duplicate(true)
		as HeroProgressionState
	)

	var battle_build := build_resolver.resolve(
		BAYDA_HERO,
		progression
	)

	if battle_build == null:
		push_error(
			"Failed to resolve Bayda battle build."
		)

		return

	if BAYDA_HERO.core_module == null:
		push_error(
			"Debug Bayda Hero has no Core Module."
		)

		return

	if battle_build.core_module == null:
		push_error(
			"HeroBattleBuildResolver lost Bayda Core Module."
		)

		return

	bayda = CombatantState.new(
		&"debug_bayda",
		battle_build.combatant_definition,
		&"team_player",
		battle_build.loadout,
		Vector2i.ZERO,
		battle_build.core_module
	)

	if bayda.hero_core_runtime_state == null:
		push_error(
			"CombatantState failed to create "
			+"Bayda Core Runtime State."
		)

		bayda = null
		return

	if not (
		bayda.hero_core_runtime_state
		is BaydaCoreRuntimeState
	):
		push_error(
			"CombatantState created the wrong "
			+"Hero Core Runtime type."
		)

		bayda = null
		return

	_last_event = "Байда сброшен."

	_rebuild_interface()


func _rebuild_interface() -> void:
	for child in get_children():
		remove_child(
			child
		)

		child.queue_free()

	var margin := MarginContainer.new()

	margin.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	margin.add_theme_constant_override(
		"margin_left",
		24
	)

	margin.add_theme_constant_override(
		"margin_top",
		24
	)

	margin.add_theme_constant_override(
		"margin_right",
		24
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		24
	)

	add_child(
		margin
	)

	var root := VBoxContainer.new()

	root.add_theme_constant_override(
		"separation",
		12
	)

	margin.add_child(
		root
	)

	var title := Label.new()

	title.text = "Bayda Core Debug Sandbox"
	title.add_theme_font_size_override(
		"font_size",
		24
	)

	root.add_child(
		title
	)

	var state_label := Label.new()

	state_label.text = _get_state_text()
	state_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	root.add_child(
		state_label
	)

	var button_row := HFlowContainer.new()

	button_row.add_theme_constant_override(
		"h_separation",
		8
	)

	button_row.add_theme_constant_override(
		"v_separation",
		8
	)

	root.add_child(
		button_row
	)

	_add_button(
		button_row,
		"Урон 3",
		Callable(
			self,
			"_apply_direct_damage"
		).bind(3)
	)

	_add_button(
		button_row,
		"Урон 6",
		Callable(
			self,
			"_apply_direct_damage"
		).bind(6)
	)

	_add_button(
		button_row,
		"Смертельный урон 99",
		Callable(
			self,
			"_apply_direct_damage"
		).bind(99)
	)

	_add_button(
		button_row,
		"Multi-hit 99 + 99",
		Callable(
			self,
			"_apply_multi_hit"
		)
	)

	_add_button(
		button_row,
		"Лечение 3",
		Callable(
			self,
			"_heal_bayda"
		).bind(3)
	)

	_add_button(
		button_row,
		"Обнулить Stamina",
		Callable(
			self,
			"_spend_all_stamina"
		)
	)

	_add_button(
		button_row,
		"Сброс",
		Callable(
			self,
			"_reset_bayda"
		)
	)


func _add_button(
	parent: Control,
	button_text: String,
	callback: Callable
) -> void:
	var button := Button.new()

	button.text = button_text
	button.pressed.connect(
		callback
	)

	parent.add_child(
		button
	)


func _apply_direct_damage(
	amount: int
) -> void:
	if bayda == null or not bayda.is_alive:
		_last_event = (
			"Байда уже погиб."
		)

		_rebuild_interface()
		return

	var applied_amount := (
		bayda.apply_resolved_damage(
			amount,
			false,
			BattleDamageKind.DIRECT
		)
	)

	_last_event = (
		"Прямой урон: запрошено %d, применено %d."
		% [
			amount,
			applied_amount,
		]
	)

	_rebuild_interface()


func _apply_multi_hit() -> void:
	if bayda == null or not bayda.is_alive:
		_last_event = (
			"Байда уже погиб."
		)

		_rebuild_interface()
		return

	bayda.begin_incoming_action_resolution()

	var first_applied := (
		bayda.apply_resolved_damage(
			99,
			false,
			BattleDamageKind.DIRECT
		)
	)

	var second_applied := (
		bayda.apply_resolved_damage(
			99,
			false,
			BattleDamageKind.DIRECT
		)
	)

	bayda.end_incoming_action_resolution()

	_last_event = (
		"Multi-hit: первый удар %d, второй удар %d."
		% [
			first_applied,
			second_applied,
		]
	)

	_rebuild_interface()


func _heal_bayda(
	amount: int
) -> void:
	if bayda == null or not bayda.is_alive:
		_last_event = (
			"Мёртвого Байду лечить нельзя."
		)

		_rebuild_interface()
		return

	var healed_amount := bayda.heal(
		amount
	)

	_last_event = (
		"Лечение: запрошено %d, применено %d."
		% [
			amount,
			healed_amount,
		]
	)

	_rebuild_interface()


func _spend_all_stamina() -> void:
	if bayda == null:
		return

	var spent_amount := (
		bayda.current_stamina
	)

	bayda.spend_stamina(
		spent_amount
	)

	_last_event = (
		"Потрачено Stamina: %d."
		% spent_amount
	)

	_rebuild_interface()


func _get_state_text() -> String:
	if bayda == null:
		return "Байда не создан."

	return (
		"Последнее действие:\n%s\n\n"
		% _last_event
		+"Жив: %s\n"
		% (
			"да"
			if bayda.is_alive
			else "нет"
		)
		+"HP: %d/%d\n"
		% [
			bayda.current_health,
			bayda.max_health,
		]
		+"Stamina: %d/%d\n"
		% [
			bayda.current_stamina,
			bayda.max_stamina,
		]
		+"Guard: %d\n\n"
		% bayda.current_guard
		+"%s"
		% bayda.get_hero_core_debug_summary()
	)