class_name ConstructionTransitionFX
extends Node2D


@export var dust_burst_emitter: CPUParticles2D
@export var fine_debris_emitter: CPUParticles2D

var _transition_count: int = 0


func _ready() -> void:
	if dust_burst_emitter == null:
		dust_burst_emitter = get_node_or_null("DustBurst") as CPUParticles2D
	if fine_debris_emitter == null:
		fine_debris_emitter = get_node_or_null("FineDebris") as CPUParticles2D


func play_transition(_intensity: float = 1.0) -> void:
	_transition_count += 1

	if dust_burst_emitter == null:
		dust_burst_emitter = get_node_or_null("DustBurst") as CPUParticles2D
	if fine_debris_emitter == null:
		fine_debris_emitter = get_node_or_null("FineDebris") as CPUParticles2D

	if dust_burst_emitter != null:
		dust_burst_emitter.restart()
		dust_burst_emitter.emitting = true
	if fine_debris_emitter != null:
		fine_debris_emitter.restart()
		fine_debris_emitter.emitting = true


func get_transition_count() -> int:
	return _transition_count
