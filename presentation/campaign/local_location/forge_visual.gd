class_name ForgeVisual
extends LocalBuildableVisual

@export var weapon_overlay_path: NodePath = NodePath("Built/Visual/EquipmentOverlay/WeaponEquipment")
@export var armor_overlay_path: NodePath = NodePath("Built/Visual/EquipmentOverlay/ArmorEquipment")

var _weapon_overlay: Sprite2D
var _armor_overlay: Sprite2D

var _major_module_id: StringName = &""


func _ready() -> void:
	_weapon_overlay = get_node_or_null(weapon_overlay_path) as Sprite2D
	_armor_overlay = get_node_or_null(armor_overlay_path) as Sprite2D

	super._ready()

	_apply_major_module_visual()


func set_major_module(module_id: StringName) -> void:
	_major_module_id = module_id
	_apply_major_module_visual()


func _apply_major_module_visual() -> void:
	if _weapon_overlay != null:
		_weapon_overlay.visible = false
	if _armor_overlay != null:
		_armor_overlay.visible = false

	match _major_module_id:
		&"weapon_equipment":
			if _weapon_overlay != null:
				_weapon_overlay.visible = true
		&"armor_equipment":
			if _armor_overlay != null:
				_armor_overlay.visible = true
		_:
			pass
