class_name BlacksmithNpcVisual
extends LocalResidentNpcVisual

@export var body_path: NodePath = NodePath("Visual/Body")
@export var intermittent_controller_path: NodePath = NodePath(
	"Visual/Body/IntermittentController"
)
@export var sitting_animation_name: StringName = &"Sitting"

var _body: AnimatedSprite2D
var _intermittent_controller: IntermittentDetailAnimation

var _waiting_for_workplace: bool = false
var _present: bool = false


func _ready() -> void:
	if not body_path.is_empty():
		_body = get_node_or_null(body_path) as AnimatedSprite2D
	if not intermittent_controller_path.is_empty():
		_intermittent_controller = get_node_or_null(intermittent_controller_path) as IntermittentDetailAnimation

	super._ready()
	_apply_activity_state()


func set_present(present: bool) -> void:
	_present = present
	super.set_present(present)
	_apply_activity_state()


func set_waiting_for_workplace(waiting: bool) -> void:
	if _waiting_for_workplace == waiting:
		return

	_waiting_for_workplace = waiting
	_apply_activity_state()


func _apply_activity_state() -> void:
	# A. NPC NOT PRESENT
	if not _present:
		if _intermittent_controller != null:
			_intermittent_controller.set_active(false)
		if _body != null:
			_body.stop()
		return

	# B. WAITING FOR WORKPLACE
	if _waiting_for_workplace:
		if _intermittent_controller != null:
			_intermittent_controller.set_active(false)

		if _body != null and _body.sprite_frames != null:
			if (
				_body.sprite_frames.has_animation(sitting_animation_name)
				and _body.sprite_frames.get_frame_count(sitting_animation_name) > 0
			):
				_body.speed_scale = 1.0
				if _body.animation != sitting_animation_name or not _body.is_playing():
					_body.play(sitting_animation_name)
		return

	# C. NORMAL BUILT MODE
	if _intermittent_controller != null:
		_intermittent_controller.set_active(true)
