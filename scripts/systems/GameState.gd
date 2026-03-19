extends Node

signal stats_changed
signal burgers_changed
signal bullets_changed
signal kills_changed
signal total_time_changed
signal respawn_requested(pos: Vector2)
signal respawns_changed
signal run_finished_changed

var lives: int = 3
var light_balls: int = 0
var bullets_shot: int = 0
var kills: int = 0
var burgers_collected: int = 0
var burgers_required: int = 0

var mission_time: float = 0.0
var total_time: float = 0.0

# Checkpoint system
var checkpoint_active: bool = false
var checkpoint_pos: Vector2 = Vector2.ZERO

# Where to respawn when no beacon has been activated
var respawn_start_set: bool = false
var respawn_start_pos: Vector2 = Vector2.ZERO

# Single run finish
var run_finished: bool = false
var final_time: float = 0.0

var respawns: int = 0

func new_run() -> void:
	lives = 3
	light_balls = 0
	bullets_shot = 0
	kills = 0
	burgers_collected = 0
	burgers_required = 0

	mission_time = 0.0
	total_time = 0.0
	checkpoint_active = false
	checkpoint_pos = Vector2.ZERO
	respawn_start_set = false
	respawn_start_pos = Vector2.ZERO
	respawns = 0
	run_finished = false
	final_time = 0.0

	stats_changed.emit()
	bullets_changed.emit()
	kills_changed.emit()
	burgers_changed.emit()
	total_time_changed.emit()
	run_finished_changed.emit()
	respawns_changed.emit()

func set_burgers_required(count: int) -> void:
	burgers_required = count
	burgers_collected = 0
	burgers_changed.emit()

func add_burger() -> void:
	burgers_collected += 1
	burgers_changed.emit()

func add_light_ball() -> void:
	light_balls += 1

	# Every 15 light balls -> +1 life
	if light_balls % 15 == 0:
		lives += 1

	stats_changed.emit()

func add_bullet_shot() -> void:
	bullets_shot += 1
	bullets_changed.emit()

func add_kill() -> void:
	kills += 1
	kills_changed.emit()

func take_damage(amount: int) -> void:
	lives -= amount
	stats_changed.emit()

func set_checkpoint(pos: Vector2) -> void:
	checkpoint_active = true
	checkpoint_pos = pos

func set_respawn_start(pos: Vector2) -> void:
	respawn_start_set = true
	respawn_start_pos = pos

func request_respawn(fallback_pos: Vector2) -> void:
	var p := fallback_pos
	if checkpoint_active:
		p = checkpoint_pos
	elif respawn_start_set:
		p = respawn_start_pos
	respawns += 1
	respawns_changed.emit()
	respawn_requested.emit(p)

func reset_mission_timer() -> void:
	mission_time = 0.0

func tick_time(delta: float) -> void:
	mission_time += delta
	total_time += delta
	total_time_changed.emit()

func finish_run() -> void:
	if run_finished:
		return
	run_finished = true
	final_time = mission_time
	run_finished_changed.emit()
