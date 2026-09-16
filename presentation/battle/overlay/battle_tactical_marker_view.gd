@tool
class_name BattleTacticalMarkerView
extends BattleSlotVisual


const LAYERS: Dictionary = {
	"Path": BattleTacticalState.Kind.PATH,
	"ValidTarget": BattleTacticalState.Kind.VALID_TARGET,
	"InvalidTarget": BattleTacticalState.Kind.INVALID_TARGET,
	"AoE": BattleTacticalState.Kind.AOE,
	"Obstacle": BattleTacticalState.Kind.OBSTACLE,
	"Swap": BattleTacticalState.Kind.SWAP,
	"Selected": BattleTacticalState.Kind.SELECTED,
	"Hover": BattleTacticalState.Kind.HOVER,
}


@export_flags(
	"Hover:1",
	"Selected:2",
	"Path:8",
	"ValidTarget:16",
	"InvalidTarget:32",
	"AoE:64",
	"Obstacle:256",
	"Swap:512"
)
var editor_preview_flags: int = 0:
	set(value):
		editor_preview_flags = value

		if (
			Engine.is_editor_hint()
			and is_node_ready()
		):
			set_flags(value)


var flags: int = 0
var _friendly_base: bool = true


func _ready() -> void:
	set_flags(
		editor_preview_flags
		if Engine.is_editor_hint()
		else flags
	)


func set_base_side(is_friendly: bool) -> void:
	_friendly_base = is_friendly
	_refresh_base_visibility()


func _refresh_base_visibility() -> void:
	var friendly := (
		get_node_or_null(^"BaseFriendly")
		as CanvasItem
	)

	var enemy := (
		get_node_or_null(^"BaseEnemy")
		as CanvasItem
	)

	if friendly != null:
		friendly.visible = _friendly_base

	if enemy != null:
		enemy.visible = not _friendly_base


func set_flags(value: int) -> void:
	flags = value

	_refresh_base_visibility()

	for layer_name in LAYERS:
		var layer := (
			get_node_or_null(
				NodePath(layer_name)
			)
			as CanvasItem
		)

		if layer == null:
			continue

		layer.visible = (
			flags
			& int(LAYERS[layer_name])
		) != 0

	# Every authored tactical slot keeps its neutral Base.
	visible = true
