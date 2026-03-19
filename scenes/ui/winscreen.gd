extends Control

@onready var time_label: Label = $CenterContainer/Panel/VBox/TimeLabel
@onready var name_edit: LineEdit = $CenterContainer/Panel/VBox/NameEdit

func _ready() -> void:
	time_label.text = "Time: %s" % _format_time(GameState.final_time)
	name_edit.grab_focus()

	$CenterContainer/Panel/VBox/ButtonRow/SubmitButton.pressed.connect(_submit_name)
	$CenterContainer/Panel/VBox/ButtonRow/SkipButton.pressed.connect(_skip)
	$CenterContainer/Panel/VBox/ToLeaderboardButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")
	)
	$CenterContainer/Panel/VBox/ToMenuButton.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")
	)

func _submit_name() -> void:
	var n := name_edit.text.strip_edges()
	if n == "":
		n = "Anonymous"
	LeaderboardStore.add_entry(n, GameState.final_time)
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")

func _skip() -> void:
	LeaderboardStore.add_entry("Anonymous", GameState.final_time)
	get_tree().change_scene_to_file("res://scenes/ui/leaderboard.tscn")

func _format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var ms := int((t - floor(t)) * 1000.0)
	return "%02d:%02d.%03d" % [minutes, seconds, ms]

