class_name BattleVFXDefinition
extends Resource

@export var effect_id: StringName
@export var scene: PackedScene
## Safety lifetime for reusable scenes that do not free themselves.
@export_range(0.05, 30.0) var lifetime: float = 0.5
