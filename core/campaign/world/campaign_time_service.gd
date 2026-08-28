class_name CampaignTimeService
extends RefCounted


const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 24
const MINUTES_PER_DAY: int = (
	MINUTES_PER_HOUR
	* HOURS_PER_DAY
)

const MAX_CAMPAIGN_DAY: int = 999999999


func advance_minutes(
	state: CampaignState,
	minutes: int
) -> bool:
	if state == null:
		return false

	if minutes < 0:
		return false

	if minutes == 0:
		return true

	if (
		state.current_minute_of_day < 0
		or state.current_minute_of_day
			>= MINUTES_PER_DAY
	):
		return false

	var total_minutes := (
		state.current_minute_of_day
		+ minutes
	)

	var day_delta := floori(
		float(total_minutes)
		/ float(MINUTES_PER_DAY)
	)

	if (
		state.current_day
		> MAX_CAMPAIGN_DAY - day_delta
	):
		return false

	var previous_day := (
		state.current_day
	)

	var previous_minute := (
		state.current_minute_of_day
	)

	state.current_day += (
		day_delta
	)

	state.current_minute_of_day = (
		total_minutes
		% MINUTES_PER_DAY
	)

	if not state.is_valid_state():
		state.current_day = (
			previous_day
		)

		state.current_minute_of_day = (
			previous_minute
		)

		return false

	return true


func get_hour(
	state: CampaignState
) -> int:
	if state == null:
		return 0

	return floori(
		float(state.current_minute_of_day)
		/ float(MINUTES_PER_HOUR)
	)


func get_minute(
	state: CampaignState
) -> int:
	if state == null:
		return 0

	return (
		state.current_minute_of_day
		% MINUTES_PER_HOUR
	)


func get_time_text(
	state: CampaignState
) -> String:
	return (
		"%02d:%02d"
		% [
			get_hour(state),
			get_minute(state),
		]
	)