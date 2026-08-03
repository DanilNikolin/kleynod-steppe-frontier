@tool
class_name BaydaCoreModuleDefinition
extends HeroCoreModuleDefinition


@export_group("Health Thresholds")

## HP 8 и выше:
## базовая Max Stamina.
@export_range(2, 9999, 1)
var safe_health_minimum: int = 8

## HP 5–7:
## первый опасный порог.
@export_range(2, 9999, 1)
var wounded_health_minimum: int = 5

## HP 2–4:
## критический порог.
@export_range(2, 9999, 1)
var critical_health_minimum: int = 2


@export_group("Maximum Stamina Bonuses")

@export_range(0, 999, 1)
var wounded_max_stamina_bonus: int = 3

@export_range(0, 999, 1)
var critical_max_stamina_bonus: int = 6

@export_range(0, 999, 1)
var last_stand_max_stamina_bonus: int = 10


@export_group("Threshold Reward")

## За каждый пересечённый вниз HP-порог.
@export_range(0, 999, 1)
var stamina_per_crossed_threshold: int = 2


@export_group("Unbroken")

@export_range(0, 999, 1)
var unbroken_stamina_cost: int = 5


func create_runtime_state(
	owner
) -> HeroCoreRuntimeState:
	if owner == null:
		return null

	if not is_valid_definition():
		return null

	var result := BaydaCoreRuntimeState.new()

	result.initialize(
		self,
		owner
	)

	return result


func get_health_tier(
	health: int
) -> int:
	if health >= safe_health_minimum:
		return 0

	if health >= wounded_health_minimum:
		return 1

	if health >= critical_health_minimum:
		return 2

	return 3


func get_max_stamina_bonus_for_health(
	health: int
) -> int:
	match get_health_tier(health):
		1:
			return wounded_max_stamina_bonus

		2:
			return critical_max_stamina_bonus

		3:
			return last_stand_max_stamina_bonus

	return 0


func get_validation_errors() -> PackedStringArray:
	var errors := super.get_validation_errors()

	if (
		safe_health_minimum
		<= wounded_health_minimum
	):
		errors.append(
			"Safe health minimum must be greater "
			+"than wounded health minimum."
		)

	if (
		wounded_health_minimum
		<= critical_health_minimum
	):
		errors.append(
			"Wounded health minimum must be greater "
			+"than critical health minimum."
		)

	if critical_health_minimum <= 1:
		errors.append(
			"Critical health minimum must be greater than 1."
		)

	if (
		critical_max_stamina_bonus
		< wounded_max_stamina_bonus
	):
		errors.append(
			"Critical Max Stamina bonus cannot be lower "
			+"than wounded bonus."
		)

	if (
		last_stand_max_stamina_bonus
		< critical_max_stamina_bonus
	):
		errors.append(
			"Last Stand Max Stamina bonus cannot be lower "
			+"than critical bonus."
		)

	return errors