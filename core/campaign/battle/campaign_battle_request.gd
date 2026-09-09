class_name CampaignBattleRequest
extends RefCounted


var request_id: StringName = &""

var location_id: StringName = &""

var party_member_hero_ids: Array[StringName] = []
var player_spawn_instance_ids: Array[StringName] = []

var encounter_definition: BattleEncounterDefinition

## Не сохраняется.
## Контекст боя, начатого из Adventure Area.
var adventure_area_id: StringName = &""

var adventure_site_id: StringName = &""

## Не сохраняется.
## Event ID, если battle был начат
## из случайного события путешествия.
var travel_event_id: StringName = &""