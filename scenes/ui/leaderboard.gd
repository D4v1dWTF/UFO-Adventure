extends Control

@onready var entries_label: Label = $MarginContainer/VBoxContainer/EntriesLabel

func _ready() -> void:
	var entries := LeaderboardStore.load_entries()
	if entries.is_empty():
		entries_label.text = "No records yet.\nPlay fast to set the first time!"
	else:
		entries_label.text = _format_entries(entries)

	$MarginContainer/VBoxContainer/BackButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
	)

func _format_entries(entries: Array[Dictionary]) -> String:
	var text := ""
	var index := 1
	for e in entries:
		var name := str(e.get("name", "Anonymous"))
		var time := float(e.get("time", 0.0))
		text += "%d) %s  -  %s\n" % [index, name, _format_time(time)]
		index += 1
	return text

func _format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var ms := int((t - floor(t)) * 1000.0)
	return "%02d:%02d.%03d" % [minutes, seconds, ms]
