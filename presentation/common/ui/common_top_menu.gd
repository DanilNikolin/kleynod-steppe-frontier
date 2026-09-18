class_name CommonTopMenu
extends Control

signal menu_pressed
signal skills_pressed
signal quests_pressed
signal map_pressed
signal inventory_pressed

func _ready() -> void:
	$Buttons/Menu.pressed.connect(menu_pressed.emit)
	$Buttons/Skills.pressed.connect(skills_pressed.emit)
	$Buttons/Quests.pressed.connect(quests_pressed.emit)
	$Buttons/Map.pressed.connect(map_pressed.emit)
	$Buttons/Inventory.pressed.connect(inventory_pressed.emit)

func set_button_enabled(button_id: StringName, enabled: bool) -> void:
	var paths := {&"menu": "Menu", &"skills": "Skills", &"quests": "Quests", &"map": "Map", &"inventory": "Inventory"}
	if not paths.has(button_id):
		push_warning("Unknown top menu button: %s" % button_id)
		return
	var button := get_node("Buttons/" + paths[button_id]) as TextureButton
	button.disabled = false if button_id == &"menu" else not enabled
