class_name BattleSurfaceEffectInstance
extends RefCounted


var definition: BattleSurfaceEffectDefinition

var coordinate: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var source_instance_id: StringName = &""
var source_team_id: StringName = &""

## Для постоянной поверхности остаётся 0.
var remaining_rounds: int = 0


var is_permanent: bool:
	get:
		return (
			definition != null
			and definition.duration_rounds == 0
		)


func _init(
	p_definition: BattleSurfaceEffectDefinition,
	p_coordinate: Vector2i,
	p_source_instance_id: StringName = &"",
	p_source_team_id: StringName = &""
) -> void:
	assert(
		p_definition != null,
		"Surface instance requires a definition."
	)

	definition = p_definition
	coordinate = p_coordinate

	refresh(
		p_definition,
		p_source_instance_id,
		p_source_team_id
	)


func refresh(
	p_definition: BattleSurfaceEffectDefinition,
	p_source_instance_id: StringName,
	p_source_team_id: StringName
) -> void:
	if p_definition == null:
		return

	definition = p_definition
	source_instance_id = p_source_instance_id
	source_team_id = p_source_team_id

	remaining_rounds = maxi(
		0,
		definition.duration_rounds
	)