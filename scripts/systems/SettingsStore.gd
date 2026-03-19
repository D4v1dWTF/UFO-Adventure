extends Node

const PATH := "user://settings.json"

# action -> physical_keycode
var bindings := {
	"move_left": KEY_A,
	"move_right": KEY_D,
	"jump": KEY_W,
	"shoot": KEY_J,
	"float_cancel": KEY_SPACE,
	"float_down": KEY_S,
}

func load_settings() -> void:
	if not FileAccess.file_exists(PATH):
		apply_to_input_map()
		save_settings()
		return

	var f := FileAccess.open(PATH, FileAccess.READ)
	var txt := f.get_as_text()
	f.close()

	var data = JSON.parse_string(txt)
	if typeof(data) == TYPE_DICTIONARY and data.has("bindings"):
		for a in data["bindings"].keys():
			bindings[a] = int(data["bindings"][a])

	apply_to_input_map()

func save_settings() -> void:
	var data := {"bindings": bindings}
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()

func apply_to_input_map() -> void:
	for action in bindings.keys():
		if not InputMap.has_action(action):
			continue
		# Clear existing events
		InputMap.action_erase_events(action)
		# Add key event
		var ev := InputEventKey.new()
		ev.physical_keycode = bindings[action]
		InputMap.action_add_event(action, ev)

func set_binding(action: String, physical_keycode: int) -> void:
	bindings[action] = physical_keycode
	apply_to_input_map()
	save_settings()

func key_name_for(action: String) -> String:
	var code := int(bindings.get(action, 0))
	return OS.get_keycode_string(code)

func find_action_using_key(physical_keycode: int, exclude_action: String = "") -> String:
	for a in bindings.keys():
		if a == exclude_action:
			continue
		if int(bindings.get(a, 0)) == physical_keycode:
			return str(a)
	return ""
