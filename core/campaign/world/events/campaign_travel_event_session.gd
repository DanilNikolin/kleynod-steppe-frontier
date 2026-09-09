class_name CampaignTravelEventSession
extends RefCounted


var definition: CampaignTravelEventDefinition

var node: CampaignTravelEventNode

var revision: int = 0

var closed: bool = true


var _runtime: CampaignRuntimeService

var _state: CampaignState

var _pending_travel: CampaignPendingTravel

var _rng := (
	RandomNumberGenerator.new()
)


func begin(
	runtime: CampaignRuntimeService
) -> bool:
	close()

	_runtime = runtime

	if runtime == null:
		return false

	_state = runtime.get_campaign_state()

	_pending_travel = (
		runtime.get_pending_travel()
	)

	if (
		_state == null
		or _pending_travel == null
		or not _pending_travel.has_reached_event()
	):
		return false

	definition = (
		_pending_travel.event_definition
	)

	if (
		definition == null
		or not definition.is_valid_definition()
	):
		return false

	node = definition.get_entry()

	if node == null:
		return false

	_rng.randomize()

	closed = false

	return true


func close() -> void:
	closed = true
	node = null

	revision += 1


func get_context_error() -> String:
	if closed:
		return "Событие завершено."

	if _runtime == null:
		return "Событие больше недоступно."

	if (
		_runtime.get_campaign_state()
		!= _state
	):
		return (
			"Состояние кампании изменилось."
		)

	if (
		_runtime.get_pending_travel()
		!= _pending_travel
	):
		return (
			"Путешествие изменилось."
		)

	if (
		_pending_travel == null
		or not _pending_travel
			.has_reached_event()
	):
		return (
			"Отряд больше не находится "
			+"у этого события."
		)

	if (
		_pending_travel.event_definition
		!= definition
	):
		return (
			"Событие путешествия изменилось."
		)

	return ""


func get_choice_error(
	choice: CampaignTravelEventChoice
) -> String:
	var context_error := (
		get_context_error()
	)

	if not context_error.is_empty():
		return context_error

	if (
		node == null
		or choice == null
		or node.get_choice(
			choice.choice_id
		) != choice
	):
		return (
			"Этот вариант больше недоступен."
		)

	match choice.action:
		CampaignTravelEventChoice.Action.PAY_GOLD:
			if (
				_state.inventory_state == null
				or _state.inventory_state.gold
					< choice.gold_cost
			):
				return (
					"Недостаточно золота. Нужно: %d."
					% choice.gold_cost
				)

		CampaignTravelEventChoice.Action.START_BATTLE:
			if _runtime.has_pending_battle():
				return (
					"Бой уже ожидает запуска."
				)

			if _runtime.get_location(
				choice.battle_location_id
			) == null:
				return (
					"Боевая ситуация недоступна."
				)

	return ""


## chance_roll:
## -1.0 = обычный runtime RNG.
## [0, 1) = deterministic injected roll
## для smoke/tests.
func choose(
	choice_id: StringName,
	expected_revision: int,
	chance_roll: float = -1.0
) -> String:
	if expected_revision != revision:
		return (
			"Этот выбор уже был обработан."
		)

	var choice := (
		node.get_choice(
			choice_id
		)
		if node != null
		else null
	)

	var error := (
		get_choice_error(
			choice
		)
	)

	if not error.is_empty():
		return error

	revision += 1

	match choice.action:
		CampaignTravelEventChoice.Action.NONE:
			return _move_to(
				choice.next_node_id
			)

		CampaignTravelEventChoice.Action.CHANCE:
			var roll := chance_roll

			if roll < 0.0:
				roll = _rng.randf()

			if (
				roll < 0.0
				or roll >= 1.0
			):
				return (
					"Некорректный бросок проверки."
				)

			var target_node_id := (
				choice.success_node_id
				if roll
					< choice.success_chance
				else choice.failure_node_id
			)

			return _move_to(
				target_node_id
			)

		CampaignTravelEventChoice.Action.PAY_GOLD:
			var previous_gold := (
				_state.inventory_state.gold
			)

			_state.inventory_state.gold -= (
				choice.gold_cost
			)

			if not _state.is_valid_state():
				_state.inventory_state.gold = (
					previous_gold
				)

				return (
					"Не удалось применить плату."
				)

			var move_error := (
				_move_to(
					choice.next_node_id
				)
			)

			if not move_error.is_empty():
				_state.inventory_state.gold = (
					previous_gold
				)

				return move_error

			return ""

		CampaignTravelEventChoice.Action.RESOLVE_EVENT:
			if not (
				_runtime
					.resolve_pending_travel_event()
			):
				return (
					"Не удалось завершить событие."
				)

			close()

			return ""

		CampaignTravelEventChoice.Action.START_BATTLE:
			if not (
				_runtime.start_travel_event_battle(
					choice.battle_location_id
				)
			):
				return (
					"Не удалось начать бой."
				)

			close()

			return ""

	return "Неизвестное действие события."


func _move_to(
	target_node_id: StringName
) -> String:
	if (
		definition == null
		or target_node_id == &""
	):
		return (
			"Следующий этап события недоступен."
		)

	var destination := (
		definition.get_node(
			target_node_id
		)
	)

	if destination == null:
		return (
			"Следующий этап события недоступен."
		)

	node = destination

	return ""