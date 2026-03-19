extends Control

var _waiting_for_action: String = ""

@onready var hint: Label = $MarginContainer/VBoxContainer/HintLabel
@onready var conflict_dialog: AcceptDialog = $KeyConflictDialog

func _ready() -> void:
	_refresh_labels()

	$MarginContainer/VBoxContainer/GridContainer/RebindLeftButton.pressed.connect(func(): _start_rebind("move_left"))
	$MarginContainer/VBoxContainer/GridContainer/RebindRightButton.pressed.connect(func(): _start_rebind("move_right"))
	$MarginContainer/VBoxContainer/GridContainer/RebindJumpButton.pressed.connect(func(): _start_rebind("jump"))
	$MarginContainer/VBoxContainer/GridContainer/RebindShootButton.pressed.connect(func(): _start_rebind("shoot"))
	$MarginContainer/VBoxContainer/GridContainer/RebindFloatCancelButton.pressed.connect(func(): _start_rebind("float_cancel"))
	$MarginContainer/VBoxContainer/GridContainer/RebindFloatDownButton.pressed.connect(func(): _start_rebind("float_down"))

	$MarginContainer/VBoxContainer/BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
	)

func _start_rebind(action: String) -> void:
	_waiting_for_action = action
	hint.text = "Press a key to bind for: %s (Esc to cancel)" % action

func _unhandled_input(event: InputEvent) -> void:
	if _waiting_for_action == "":
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			_waiting_for_action = ""
			hint.text = "Cancelled."
			return

		# Prevent duplicate keybinds.
		var conflict_action := SettingsStore.find_action_using_key(event.physical_keycode, _waiting_for_action)
		if conflict_action != "":
			var key_name := OS.get_keycode_string(event.physical_keycode)
			conflict_dialog.dialog_text = "Key '%s' is already used by '%s'.\nPlease choose a different key." % [key_name, conflict_action]
			conflict_dialog.popup_centered()
			hint.text = "Key already used. Choose a different key."
			return

		SettingsStore.set_binding(_waiting_for_action, event.physical_keycode)
		_waiting_for_action = ""
		hint.text = "Saved."
		_refresh_labels()

func _refresh_labels() -> void:
	var grid := $MarginContainer/VBoxContainer/GridContainer

	grid.get_node("RebindLeftButton").text = SettingsStore.key_name_for("move_left")
	grid.get_node("RebindRightButton").text = SettingsStore.key_name_for("move_right")
	grid.get_node("RebindJumpButton").text = SettingsStore.key_name_for("jump")
	grid.get_node("RebindShootButton").text = SettingsStore.key_name_for("shoot")
	grid.get_node("RebindFloatCancelButton").text = SettingsStore.key_name_for("float_cancel")
	grid.get_node("RebindFloatDownButton").text = SettingsStore.key_name_for("float_down")
