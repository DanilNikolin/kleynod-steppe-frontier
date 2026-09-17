class_name BattleEnvironmentAnimatedProp
extends AnimatedSprite2D

## Helper script for environment animated props (e.g. grass, leaves, ambient FX).
## Automatically randomizes the starting frame/phase and playback speed slightly
## so multiple instances don't animate in robotic synchrony.

@export var randomize_start_frame: bool = true
@export var random_speed_variation: float = 0.15


func _ready() -> void:
	if sprite_frames == null:
		return
	
	var anim_name: StringName = autoplay if not autoplay.is_empty() else animation
	if anim_name.is_empty() or not sprite_frames.has_animation(anim_name):
		var anims := sprite_frames.get_animation_names()
		if anims.is_empty():
			return
		anim_name = anims[0]

	if random_speed_variation > 0.0:
		speed_scale = randf_range(1.0 - random_speed_variation, 1.0 + random_speed_variation)

	var frame_count: int = sprite_frames.get_frame_count(anim_name)
	if randomize_start_frame and frame_count > 1:
		frame = randi() % frame_count

	play(anim_name)
