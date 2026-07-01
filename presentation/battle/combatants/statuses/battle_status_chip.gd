class_name BattleStatusChip
extends PanelContainer


const MAX_ABBREVIATION_CHARACTERS: int = 3


@onready
var value_label: Label = (
	$ContentMargin/ValueLabel
)


var status: BattleStatusInstance


func _ready() -> void:
	refresh_from_status()


func bind_status(
	new_status: BattleStatusInstance
) -> void:
	status = new_status
	refresh_from_status()


func refresh_from_status() -> void:
	if not is_node_ready():
		return

	if (
		status == null
		or status.definition == null
	):
		visible = false
		value_label.text = ""
		return

	visible = true

	var abbreviation := _build_abbreviation(
		status.definition.display_name
	)

	var chip_text := abbreviation

	if status.stack_count > 1:
		chip_text += "×%d" % status.stack_count

	chip_text += (
		" · %d"
		% maxi(
			0,
			status.remaining_turns
		)
	)

	value_label.text = chip_text


func _build_abbreviation(
	display_name: String
) -> String:
	var normalized_name := (
		display_name.strip_edges()
	)

	if normalized_name.is_empty():
		return "?"

	var words := normalized_name.split(
		" ",
		false
	)

	if words.size() > 1:
		var abbreviation := ""

		for word_value in words:
			var word := String(
				word_value
			)

			if word.is_empty():
				continue

			abbreviation += (
				word.left(1).to_upper()
			)

			if (
				abbreviation.length()
				>= MAX_ABBREVIATION_CHARACTERS
			):
				break

		if not abbreviation.is_empty():
			return abbreviation

	return (
		normalized_name
		.left(
			MAX_ABBREVIATION_CHARACTERS
		)
		.to_upper()
	)