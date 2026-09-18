extends SceneTree

var failures: int = 0
var clicks: int = 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var menu := load("res://presentation/common/ui/common_top_menu.tscn").instantiate() as CommonTopMenu
	root.add_child(menu)
	menu.menu_pressed.connect(func(): clicks += 1)
	for id in [&"menu", &"skills", &"quests", &"map", &"inventory"]:
		var button := menu.get_node("Buttons/" + String(id).capitalize()) as TextureButton
		check(button.texture_normal != null and button.texture_hover != null and button.texture_pressed != null, "%s states exist." % id)
		check(button.texture_hover.get_size() == button.texture_normal.get_size() and button.texture_pressed.get_size() == button.texture_normal.get_size(), "%s family crop matches." % id)
		if id != &"menu":
			check(button.disabled and button.texture_disabled != null, "%s uses authored disabled art." % id)
			check(button.texture_disabled.get_size() == button.texture_normal.get_size(), "Disabled crop matches.")
		menu.set_button_enabled(id, true)
		check(not button.disabled, "Enabled API works.")
		menu.set_button_enabled(id, false)
		check(button.disabled == (id != &"menu"), "Menu remains enabled by user contract.")
	menu.get_node("Buttons/Menu").pressed.emit()
	check(clicks == 1, "Menu signal forwarded once.")
	check(menu.mouse_filter == Control.MOUSE_FILTER_IGNORE and menu.get_node("Background").mouse_filter == Control.MOUSE_FILTER_IGNORE, "Decorations pass battlefield input.")
	menu.queue_free()
	await process_frame
	print("COMMON TOP MENU SMOKE: ", "GREEN" if failures == 0 else "FAILED")
	quit(0 if failures == 0 else 1)
