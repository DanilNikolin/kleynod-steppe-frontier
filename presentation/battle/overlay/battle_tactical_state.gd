class_name BattleTacticalState
extends RefCounted

signal changed

enum Kind { HOVER = 1, SELECTED = 2, REACHABLE = 4, PATH = 8,
	VALID_TARGET = 16, INVALID_TARGET = 32, AOE = 64, SURFACE = 128,
	OBSTACLE = 256, SWAP = 512 }

var slots: Dictionary = {}
var hovered := BattleGrid.INVALID_COORDINATE
var aim_coordinates: Array[Vector2i] = []
var impact_coordinates: Array[Vector2i] = []
var surface_previews: Array[BattleSurfacePlacementPreview] = []
var surface_coordinates: Array[Vector2i] = []


func add_state(coordinate: Vector2i, kind: Kind) -> void:
	slots[coordinate] = int(slots.get(coordinate, 0)) | kind
	changed.emit()


func get_flags(coordinate: Vector2i) -> int:
	var flags := int(slots.get(coordinate, 0))
	if coordinate == hovered:
		flags |= Kind.HOVER
	if surface_coordinates.has(coordinate):
		flags |= Kind.SURFACE
	if impact_coordinates.has(coordinate):
		flags |= Kind.AOE
	return flags


func set_hover(coordinate: Vector2i) -> void:
	hovered = coordinate
	changed.emit()


func clear_tactical() -> void:
	slots.clear()
	aim_coordinates.clear()
	impact_coordinates.clear()
	changed.emit()


func clear_targeting_markers() -> void:
	aim_coordinates.clear()
	impact_coordinates.clear()
	changed.emit()


func set_targeting_markers(aim: Array[Vector2i], impact: Array[Vector2i]) -> void:
	aim_coordinates = aim.duplicate()
	impact_coordinates = impact.duplicate()
	changed.emit()


func set_surfaces(coordinates: Array[Vector2i]) -> void:
	surface_coordinates = coordinates.duplicate()
	changed.emit()


func set_surface_previews(values: Array[BattleSurfacePlacementPreview]) -> void:
	surface_previews = values.duplicate()
	changed.emit()


func clear_surface_previews() -> void:
	surface_previews.clear()
	changed.emit()
