extends Node

func _ready() -> void:
	SettingsStore.load_settings()
	get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
