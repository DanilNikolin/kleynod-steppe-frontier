class_name CampaignDialogueSession
extends RefCounted


## Transient conversation. Authored resources stay immutable; successful
## encounters and choices may update the campaign's saved gameplay state.
var definition: CampaignDialogueDefinition
var node: CampaignDialogueNode
var revision: int = 0
var closed: bool = true
## A service pauses choices until the UI returns to the conversation.
var pending_trader_id: StringName = &""
var _runtime: CampaignRuntimeService
var _state: CampaignState
var _campaign: CampaignDefinition
var _world_node_id: StringName
var _interaction_id: StringName


func begin(runtime: CampaignRuntimeService, interaction_id: StringName) -> bool:
	close()
	_runtime = runtime
	_state = runtime.get_campaign_state()
	_campaign = runtime.campaign_definition
	_interaction_id = interaction_id
	definition = runtime.get_dialogue_for_interaction(interaction_id)
	if _state == null or definition == null or runtime.has_pending_battle():
		return false
	if not definition.get_validation_errors().is_empty() or not definition.get_reference_errors(_campaign).is_empty():
		return false
	_world_node_id = _state.current_world_node_id
	node = definition.get_entry(_state, _campaign)
	closed = node == null
	if not closed:
		var resident := runtime.get_resident_for_local_interaction(interaction_id)
		if resident != null and not resident.wandering_world_node_ids.is_empty():
			# Select first-meeting entry before recording it. Opening the conversation
			# counts as meeting, including when the player closes without an answer.
			_state.get_resident(resident.resident_id).has_met = true
	return not closed


func close() -> void:
	closed = true
	pending_trader_id = &""
	revision += 1


func get_context_error() -> String:
	if closed or not is_instance_valid(_runtime):
		return "Разговор завершён."
	if _runtime.get_campaign_state() != _state or _runtime.campaign_definition != _campaign:
		return "Кампания изменилась. Начните разговор заново."
	if _runtime.has_pending_battle() or _state.current_world_node_id != _world_node_id:
		return "Сейчас нельзя продолжить разговор."
	if _runtime.get_dialogue_for_interaction(_interaction_id) != definition:
		return "Собеседник больше недоступен здесь."
	return ""


func get_choice_error(choice: CampaignDialogueChoice) -> String:
	var error := get_context_error()
	if not error.is_empty():
		return error
	if pending_trader_id != &"":
		return "Сначала завершите торговлю."
	if node == null or choice == null or node.get_choice(choice.choice_id) != choice:
		return "Ответ больше недоступен."
	if not node.is_available(_state, _campaign):
		return "Обстоятельства изменились. Начните разговор заново."
	for condition in choice.conditions:
		if not condition.matches(_state, _campaign):
			return condition.unavailable_text
	if choice.action == CampaignDialogueChoice.Action.NONE and choice.next_node_id != &"":
		var destination := definition.get_node(choice.next_node_id)
		if destination == null or not destination.is_available(_state, _campaign):
			return "Эта тема сейчас недоступна."
	return _get_action_error(choice)


func choose(choice_id: StringName, expected_revision: int) -> String:
	if expected_revision != revision:
		return "Этот ответ уже обработан."
	var choice: CampaignDialogueChoice = node.get_choice(choice_id) if node != null else null
	var error := get_choice_error(choice)
	if not error.is_empty():
		return error
	# Consume the displayed revision before invoking any gameplay action.
	revision += 1
	var applied := true
	match choice.action:
		CampaignDialogueChoice.Action.ESTABLISH_SUPPLIER:
			applied = _runtime.establish_supplier(choice.target_id, _interaction_id).is_empty()
		CampaignDialogueChoice.Action.REVEAL_RESIDENT_LOCATION:
			_state.get_resident(choice.target_id).location_clue_known = true
		CampaignDialogueChoice.Action.OPEN_TRADING:
			pending_trader_id = choice.target_id
		CampaignDialogueChoice.Action.START_QUEST:
			applied = _runtime.start_quest(choice.target_id)
		CampaignDialogueChoice.Action.TURN_IN_QUEST:
			applied = _runtime.turn_in_quest(choice.target_id)
		CampaignDialogueChoice.Action.INVITE_RESIDENT:
			applied = _runtime.invite_resident(choice.target_id)
	if not applied:
		return "Не удалось выполнить действие. Мир не подтвердил результат."
	if choice.next_node_id == &"":
		close()
	else:
		node = definition.get_node(choice.next_node_id)
	return ""


func _get_action_error(
	choice: CampaignDialogueChoice
) -> String:
	if choice.action == CampaignDialogueChoice.Action.ESTABLISH_SUPPLIER:
		return _runtime.get_supplier_relationship_error(choice.target_id, _interaction_id)
	if choice.action == CampaignDialogueChoice.Action.NONE:
		return ""

	if choice.action == CampaignDialogueChoice.Action.REVEAL_RESIDENT_LOCATION:
		var target := _campaign.get_resident(choice.target_id)
		var target_state := _state.get_resident(choice.target_id)
		if target == null or target_state == null or target.wandering_world_node_ids.is_empty() or not target_state.is_at_origin():
			return "О местонахождении этого мастера ничего не известно."
		return ""

	if choice.action == CampaignDialogueChoice.Action.OPEN_TRADING:
		var trader := (
			_runtime.get_trader_for_interaction(
				_interaction_id
			)
		)

		if (
			trader == null
			or trader.trader_id != choice.target_id
		):
			return "У собеседника нет такой торговли."

		var trader_state := (
			_runtime.get_trader_state(
				choice.target_id
			)
		)

		if (
			trader_state == null
			or not trader_state.is_valid_state()
		):
			return "Торговля сейчас недоступна."

		return ""

	var resident := (
		_runtime.get_resident_for_local_interaction(
			_interaction_id
		)
	)

	if (
		choice.action
		== CampaignDialogueChoice.Action.INVITE_RESIDENT
	):
		if resident == null:
			return (
				"Это действие требует разговора "
				+ "с нужным персонажем."
			)

		if choice.target_id != resident.resident_id:
			return (
				"Приглашение адресовано "
				+ "другому персонажу."
			)

		var resident_state := (
			_state.get_resident(
				choice.target_id
			)
		)

		if (
			resident_state == null
			or not resident_state.is_at_origin()
		):
			return "Этот персонаж уже переселился."

		if not resident_state.recruitment_unlocked:
			return (
				"Сначала заслужите доверие собеседника."
			)

		if (
			_state.reputation
			< resident.required_reputation
		):
			return (
				"Нужна репутация: %d."
				% resident.required_reputation
			)

		var recruitment_error := _runtime.get_resident_recruitment_error(choice.target_id)
		if not recruitment_error.is_empty():
			return recruitment_error

		return ""

	var quest := (
		_campaign.get_quest(
			choice.target_id
		)
	)

	var quest_state := (
		_state.get_quest(
			choice.target_id
		)
	)

	if (
		quest == null
		or quest_state == null
	):
		return "Задание недоступно."

	var giver_definition: CampaignResidentDefinition = null
	var giver_state: CampaignResidentState = null

	if quest.uses_resident_giver():
		if (
			resident == null
			or quest.giver_resident_id
				!= resident.resident_id
		):
			return (
				"Это задание нужно обсудить "
				+ "с его поручителем."
			)

		giver_definition = resident

		giver_state = (
			_state.get_resident(
				resident.resident_id
			)
		)

		if giver_state == null:
			return "Поручитель задания недоступен."

	elif quest.uses_local_interaction_giver():
		if (
			quest.giver_world_node_id
				!= _world_node_id
			or quest.giver_local_interaction_id
				!= _interaction_id
		):
			return (
				"Это задание нужно получить "
				+ "в другом месте."
			)

	else:
		return "Источник задания недоступен."

	var error: String

	if (
		choice.action
		== CampaignDialogueChoice.Action.START_QUEST
	):
		error = (
			_runtime.quest_service.get_start_error(
				_state,
				quest,
				quest_state,
				giver_definition,
				giver_state,
				_runtime.get_home_settlement_definition()
			)
		)

		return (
			""
			if error.is_empty()
			else "Сейчас нельзя принять это задание."
		)

	if (
		choice.action
		== CampaignDialogueChoice.Action.TURN_IN_QUEST
	):
		error = (
			_runtime.quest_service.get_turn_in_error(
				_state,
				quest,
				quest_state,
				giver_definition,
				giver_state,
				_runtime.get_home_settlement_definition()
			)
		)

		return (
			""
			if error.is_empty()
			else "Задание сейчас нельзя сдать."
		)

	return "Неизвестное действие разговора."


func resume_from_trading() -> String:
	if pending_trader_id == &"":
		return "Разговор не ожидает возвращения из торговли."
	var error := get_context_error()
	pending_trader_id = &""
	revision += 1
	if not error.is_empty():
		close()
		return error
	return ""


func get_node_text() -> String:
	var result := node.text
	for resident in _campaign.residents:
		var token := "{resident_location:%s}" % resident.resident_id
		if not result.contains(token):
			continue
		var state := _state.get_resident(resident.resident_id)
		var location := _campaign.world_map_definition.get_node(_runtime.resident_service.get_origin_world_node_id(resident, state))
		result = result.replace(token, location.display_name if location != null else "неизвестно")
	return result
