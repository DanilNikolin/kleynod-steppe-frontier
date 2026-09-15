extends SceneTree

func _init() -> void:
	call_deferred("run")

func run() -> void:
	print("--- Running Forge Visual & Overlay Verification ---")
	var forge_scene := load("res://scenes/campaign/local_location/objects/forge.tscn")
	assert(forge_scene != null, "forge.tscn must load")
	var forge: Node2D = forge_scene.instantiate()
	root.add_child(forge)

	assert(forge is ForgeVisual, "Forge root node must be ForgeVisual")
	assert(forge is LocalBuildableVisual, "ForgeVisual must extend LocalBuildableVisual")

	var built := forge.get_node_or_null("Built") as Node2D
	assert(built != null, "Built node must exist")

	var visual := built.get_node_or_null("Visual") as Node2D
	assert(visual != null, "Built/Visual node must exist")

	var overlay_root := visual.get_node_or_null("EquipmentOverlay") as Node2D
	assert(overlay_root != null, "EquipmentOverlay node must exist")

	var weapon_sp := overlay_root.get_node_or_null("WeaponEquipment") as Sprite2D
	assert(weapon_sp != null, "WeaponEquipment Sprite2D must exist")
	assert(weapon_sp.visible == false, "WeaponEquipment must be hidden by default")

	var armor_sp := overlay_root.get_node_or_null("ArmorEquipment") as Sprite2D
	assert(armor_sp != null, "ArmorEquipment Sprite2D must exist")
	assert(armor_sp.visible == false, "ArmorEquipment must be hidden by default")

	# Test 1: BUILT + no major module
	const LocalBuildSiteViewScript = preload("res://presentation/campaign/local_location/local_build_site_view.gd")
	forge.set_build_state(LocalBuildSiteViewScript.BuildVisualState.BUILT)
	forge.set_major_module(&"")
	assert(weapon_sp.visible == false, "Weapon overlay must be hidden with empty module")
	assert(armor_sp.visible == false, "Armor overlay must be hidden with empty module")

	# Test 2: BUILT + weapon_equipment
	forge.set_major_module(&"weapon_equipment")
	assert(weapon_sp.visible == true, "Weapon overlay must be visible for weapon_equipment")
	assert(armor_sp.visible == false, "Armor overlay must be hidden for weapon_equipment")

	# Test 3: BUILT + armor_equipment
	forge.set_major_module(&"armor_equipment")
	assert(weapon_sp.visible == false, "Weapon overlay must be hidden for armor_equipment")
	assert(armor_sp.visible == true, "Armor overlay must be visible for armor_equipment")

	# Test 4: Switching back to empty
	forge.set_major_module(&"")
	assert(weapon_sp.visible == false, "Weapon overlay must be hidden after reset")
	assert(armor_sp.visible == false, "Armor overlay must be hidden after reset")

	# Test 5: EMPTY state hides Built entirely
	forge.set_build_state(LocalBuildSiteViewScript.BuildVisualState.EMPTY)
	assert(built.visible == false, "Built must be hidden in EMPTY state")

	# Test 6: CONSTRUCTING state hides Built entirely
	forge.set_build_state(LocalBuildSiteViewScript.BuildVisualState.CONSTRUCTING, 0.5)
	assert(built.visible == false, "Built must be hidden in CONSTRUCTING state")

	print("FORGE VISUAL VERIFICATION SUCCESSFUL")
	quit(0)
