@tool
class_name BattleAbilityPresentationProfile
extends Resource


enum FeedbackKind {
	AUTO,
	NONE,
	DAMAGE,
	HEAL,
	GUARD,
	STATUS,
	CLEANSE,
	CONTROL,
	SURFACE,
}


enum ActorMotion {
	AUTO,
	NONE,
	LUNGE,
}


enum FeedbackRepeatMode {
	SINGLE,
	PER_DAMAGE_EFFECT,
}


const DAMAGE_FLASH_COLOR := Color(
	1.0,
	0.28,
	0.22,
	1.0
)

const HEAL_FLASH_COLOR := Color(
	0.38,
	1.0,
	0.56,
	1.0
)

const GUARD_FLASH_COLOR := Color(
	0.35,
	0.72,
	1.0,
	1.0
)

const STATUS_FLASH_COLOR := Color(
	0.76,
	0.42,
	1.0,
	1.0
)

const CLEANSE_FLASH_COLOR := Color(
	1.0,
	0.88,
	0.42,
	1.0
)

const CONTROL_FLASH_COLOR := Color(
	1.0,
	0.58,
	0.22,
	1.0
)

const SURFACE_FLASH_COLOR := Color(
	1.0,
	0.46,
	0.18,
	1.0
)


@export_group("Feedback")

@export
var feedback_kind: FeedbackKind = (
	FeedbackKind.AUTO
)

@export
var feedback_repeat_mode: FeedbackRepeatMode = (
	FeedbackRepeatMode.SINGLE
)


@export_group("Animation")

## Пустое значение использует автоматический ключ.
@export
var actor_animation_key: StringName = &""

## Пустое значение использует автоматический ключ.
@export
var target_animation_key: StringName = &""


@export_group("Motion")

@export
var actor_motion: ActorMotion = (
	ActorMotion.AUTO
)

@export_range(0.0, 96.0, 1.0)
var lunge_distance: float = 22.0


@export_group("Flash")

@export
var use_custom_flash_color: bool = false

@export
var custom_flash_color: Color = Color.WHITE


@export_group("Future Hooks")

## Идентификаторы пока только отправляются сигналами.
## Реальные VFX и звук подключим отдельными presenter-системами.
@export
var impact_vfx_id: StringName = &""

@export
var sound_id: StringName = &""


func get_feedback_repeat_count(
	action_result: BattleActionResult
) -> int:
	if (
		feedback_repeat_mode
		!= FeedbackRepeatMode.PER_DAMAGE_EFFECT
	):
		return 1

	if action_result == null:
		return 1

	var used_damage_effect_ids: Dictionary = {}
	var anonymous_damage_count: int = 0

	for effect_result in action_result.effect_results:
		if (
			effect_result == null
			or not effect_result.is_successful
			or effect_result.effect_kind != &"damage"
		):
			continue

		if effect_result.effect_id == &"":
			anonymous_damage_count += 1
			continue

		used_damage_effect_ids[
			effect_result.effect_id
		] = true

	return maxi(
		1,
		used_damage_effect_ids.size()
		+ anonymous_damage_count
	)


func resolve_feedback_kind(
	action_result: BattleActionResult
) -> int:
	if feedback_kind != FeedbackKind.AUTO:
		return feedback_kind

	if action_result == null:
		return FeedbackKind.NONE

	var has_damage := false
	var has_heal := false
	var has_guard := false
	var has_status := false
	var has_cleanse := false
	var has_control := false
	var has_surface := false

	for effect_result in action_result.effect_results:
		if (
			effect_result == null
			or not effect_result.is_successful
		):
			continue

		match effect_result.effect_kind:
			&"damage":
				has_damage = true

			&"heal":
				has_heal = true

			&"grant_guard":
				has_guard = true

			&"apply_status":
				has_status = true

			&"remove_status":
				has_cleanse = true

			&"forced_movement":
				has_control = true

			&"place_surface":
				has_surface = true

	if has_damage:
		return FeedbackKind.DAMAGE

	if has_heal:
		return FeedbackKind.HEAL

	if has_guard:
		return FeedbackKind.GUARD

	if has_cleanse:
		return FeedbackKind.CLEANSE

	if has_status:
		return FeedbackKind.STATUS

	if has_control:
		return FeedbackKind.CONTROL

	if has_surface:
		return FeedbackKind.SURFACE

	return FeedbackKind.NONE


func get_actor_animation_key(
	resolved_feedback_kind: int
) -> StringName:
	if actor_animation_key != &"":
		return actor_animation_key

	match resolved_feedback_kind:
		FeedbackKind.DAMAGE:
			return &"attack"

		FeedbackKind.CONTROL:
			return &"attack"

		FeedbackKind.HEAL:
			return &"cast"

		FeedbackKind.GUARD:
			return &"support"

		FeedbackKind.STATUS:
			return &"cast"

		FeedbackKind.CLEANSE:
			return &"cast"

		FeedbackKind.SURFACE:
			return &"cast"

	return &"idle"


func get_target_animation_key(
	resolved_feedback_kind: int
) -> StringName:
	if target_animation_key != &"":
		return target_animation_key

	match resolved_feedback_kind:
		FeedbackKind.DAMAGE:
			return &"hit"

		FeedbackKind.CONTROL:
			return &"hit"

		FeedbackKind.HEAL:
			return &"heal"

		FeedbackKind.GUARD:
			return &"block"

		FeedbackKind.STATUS:
			return &"status"

		FeedbackKind.CLEANSE:
			return &"cleanse"

	return &"idle"


func should_use_actor_lunge(
	resolved_feedback_kind: int
) -> bool:
	match actor_motion:
		ActorMotion.NONE:
			return false

		ActorMotion.LUNGE:
			return true

	return (
		resolved_feedback_kind
			== FeedbackKind.DAMAGE
		or resolved_feedback_kind
			== FeedbackKind.CONTROL
	)


func get_flash_color(
	resolved_feedback_kind: int
) -> Color:
	if use_custom_flash_color:
		return custom_flash_color

	match resolved_feedback_kind:
		FeedbackKind.DAMAGE:
			return DAMAGE_FLASH_COLOR

		FeedbackKind.HEAL:
			return HEAL_FLASH_COLOR

		FeedbackKind.GUARD:
			return GUARD_FLASH_COLOR

		FeedbackKind.STATUS:
			return STATUS_FLASH_COLOR

		FeedbackKind.CLEANSE:
			return CLEANSE_FLASH_COLOR

		FeedbackKind.CONTROL:
			return CONTROL_FLASH_COLOR

		FeedbackKind.SURFACE:
			return SURFACE_FLASH_COLOR

	return Color.WHITE