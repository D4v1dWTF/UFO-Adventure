extends Node2D

@export var burgers_required := 1
@export var start_lives: int = 3

var _spawn_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameState.set_burgers_required(burgers_required)
	GameState.reset_mission_timer()

	var p := _get_player()
	if p != null:
		_spawn_pos = p.global_position
		# Tell GameState where to respawn when no beacon is active
		GameState.set_respawn_start(_spawn_pos)
	GameState.respawn_requested.connect(_on_respawn_requested)

func _process(delta: float) -> void:
	if not GameState.run_finished:
		GameState.tick_time(delta)

func _get_player() -> Node:
	return get_tree().get_first_node_in_group("player")

func _on_respawn_requested(pos: Vector2) -> void:
	var p := _get_player()
	if p == null:
		return
	p.global_position = pos
	if p is CharacterBody2D:
		p.velocity = Vector2.ZERO
	if p.has_method("on_respawn"):
		p.on_respawn()

	# Restore lives only when lives are out.
	# Otherwise, respawn with remaining lives.
	if GameState.lives <= 0:
		GameState.lives = start_lives
	GameState.stats_changed.emit()
