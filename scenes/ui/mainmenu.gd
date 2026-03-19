extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start)
	$CenterContainer/VBoxContainer/LeaderBoardButton.pressed.connect(_on_leaderboard)
	$CenterContainer/VBoxContainer/Settingbutton.pressed.connect(_on_settings)
	$CenterContainer/VBoxContainer/Exit.pressed.connect(_on_exit)

func _on_start() -> void:
	# Start a new run and go to our only mission for now
	GameState.new_run()
	get_tree().change_scene_to_file("res://scenes/levels/mission_1.tscn")

func _on_leaderboard() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settingsmenu.tscn")

func _on_exit() -> void:
	get_tree().quit()
