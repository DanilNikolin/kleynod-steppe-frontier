class_name BattleCampaignBridge
extends Node

## Composition adapter; campaign result/reward rules remain in CampaignRuntime.
var screen: BattleScreen
var campaign: CampaignRuntimeService
var request: CampaignBattleRequest
var completing: bool = false


func configure(value: BattleScreen, runtime: CampaignRuntimeService, context: CampaignBattleRequest) -> void:
	campaign = runtime
	screen = value
	request = context
	screen.encounter_definition = request.encounter_definition
	screen.environment_scene = request.battle_environment_scene


func complete(winner: StringName) -> void:
	if completing:
		return
	completing = true
	# battle_finished is emitted during the commit, before its visuals finish.
	await get_tree().process_frame
	while screen.flow.action_runner.active_executions > 0 or screen.flow.movement_runner.active_executions > 0:
		await get_tree().process_frame
	if campaign.pending_battle_request != request:
		return
	if not campaign.complete_pending_battle_from_session_and_return(screen.session, winner):
		push_error("Campaign rejected battle completion for request %s." % request.request_id)
