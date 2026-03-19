extends CanvasLayer

@onready var lives_label: Label = $PanelContainer/VBoxContainer/LivesLabel
@onready var light_label: Label = $PanelContainer/VBoxContainer/LightBallLabel
@onready var bullets_label: Label = $PanelContainer/VBoxContainer/BulletLabel
@onready var kills_label: Label = $PanelContainer/VBoxContainer/KillLabel
@onready var burgers_label: Label = $PanelContainer/VBoxContainer/BurgerLabel
@onready var timer_label: Label = $PanelContainer/VBoxContainer/TimerLabel
@onready var fuel_bar: ProgressBar = $PanelContainer/VBoxContainer/FuelBar
@onready var respawns_label: Label = $PanelContainer/VBoxContainer/RespawnsLabel
@onready var pause_overlay: Control = $PauseOverlay
@onready var countdown_label: Label = $PauseOverlay/CenterContainer/Panel/VBox/CountdownLabel

var _pause_active: bool = false
var _countdown: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	GameState.stats_changed.connect(_refresh)
	GameState.burgers_changed.connect(_refresh)
	GameState.bullets_changed.connect(_refresh)
	GameState.kills_changed.connect(_refresh)
	GameState.total_time_changed.connect(_refresh)
	GameState.respawns_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	lives_label.text = "Lives: %d" % GameState.lives
	light_label.text = "Light balls: %d" % GameState.light_balls
	bullets_label.text = "Bullets: %d" % GameState.bullets_shot
	kills_label.text = "Kills: %d" % GameState.kills
	# Burger counter hidden
	burgers_label.visible = false

	respawns_label.text = "Respawns: %d" % GameState.respawns

	var tt := _format_time(GameState.total_time)
	timer_label.text = "Time: %s" % tt

func _process(delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	if p != null and p.has_method("fuel_ratio"):
		fuel_bar.value = float(p.fuel_ratio()) * fuel_bar.max_value

	# Handle pause toggle
	var pause_pressed := Input.is_action_just_pressed("pause") or Input.is_key_pressed(KEY_ESCAPE)
	if pause_pressed and not GameState.run_finished:
		if not _pause_active and _countdown <= 0.0:
			_enter_pause()

	# Handle countdown
	if _countdown > 0.0:
		_countdown -= delta
		if _countdown <= 0.0:
			_countdown = 0.0
			_exit_pause()
		else:
			var secs := int(ceil(_countdown))
			countdown_label.text = "Resuming in %d..." % secs

func _format_time(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var ms := int((t - floor(t)) * 1000.0)
	return "%02d:%02d.%03d" % [minutes, seconds, ms]

func _enter_pause() -> void:
	_pause_active = true
	_countdown = 0.0
	get_tree().paused = true
	pause_overlay.visible = true
	countdown_label.text = ""
	var buttons := $PauseOverlay/CenterContainer/Panel/VBox/Buttons
	buttons.get_node("ContinueButton").disabled = false
	buttons.get_node("MenuButton").disabled = false

	# Connect buttons if needed.
	var continue_btn: Button = buttons.get_node("ContinueButton")
	if not continue_btn.pressed.is_connected(_on_continue_pressed):
		continue_btn.pressed.connect(_on_continue_pressed)

	var menu_btn: Button = buttons.get_node("MenuButton")
	if not menu_btn.pressed.is_connected(_on_menu_pressed):
		menu_btn.pressed.connect(_on_menu_pressed)

func _on_continue_pressed() -> void:
	# Start 3 second countdown while still paused, timers frozen
	_countdown = 3.0
	countdown_label.text = "Resuming in 3..."
	var buttons := $PauseOverlay/CenterContainer/Panel/VBox/Buttons
	buttons.get_node("ContinueButton").disabled = true

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/mainmenu.tscn")

func _exit_pause() -> void:
	_pause_active = false
	get_tree().paused = false
	pause_overlay.visible = false
	countdown_label.text = ""
