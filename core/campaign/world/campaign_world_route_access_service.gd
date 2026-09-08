class_name CampaignWorldRouteAccessService
extends RefCounted


var _settlement_effect_service := (
	CampaignSettlementEffectService.new()
)


func is_route_available(
	route: CampaignWorldRouteDefinition,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState
) -> bool:
	return get_route_access_error(
		route,
		settlement_definition,
		settlement_state
	).is_empty()


func get_route_access_error(
	route: CampaignWorldRouteDefinition,
	settlement_definition: CampaignSettlementDefinition,
	settlement_state: CampaignSettlementState
) -> String:
	if route == null:
		return "World route is missing."

	if route.required_home_settlement_effect_id == &"":
		return ""

	if (
		settlement_definition == null
		or settlement_state == null
	):
		return (
			"Home settlement state is unavailable."
		)

	if _settlement_effect_service.has_active_effect(
		settlement_definition,
		settlement_state,
		route.required_home_settlement_effect_id
	):
		return ""

	if not route.access_requirement_text.strip_edges().is_empty():
		return route.access_requirement_text

	return (
		"Route requirement is not satisfied: %s."
		% route.required_home_settlement_effect_id
	)