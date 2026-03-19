extends CharacterBody2D

@export var speed := 200.0
@export var jump_velocity := -570.0
@export var gravity := 1200.0
@export var invuln_seconds := 1.0

@export var bullet_scene: PackedScene

var _invuln := false

@onready var muzzle: Marker2D = $Muzzle
@onready var invuln_timer: Timer = $InvulnTimer
@onready var cam: Camera2D = $Camera2D

# Float mode / fuel
@export var fuel_max: float = 100.0
@export var fuel_regen_per_sec: float = 55.0
@export var fuel_up_drain_per_sec: float = 65.0
@export var float_up_speed: float = 260.0
@export var float_fall_speed: float = 120.0
@export var light_ball_fuel_bonus: float = 18.0
@export var normal_zoom: Vector2 = Vector2(1.1, 1.1)
@export var float_zoom: Vector2 = Vector2(0.9, 0.9)
@export var sprite_faces_right_by_default: bool = true

# Enemy contact slow
@export var contact_slow_multiplier: float = 0.45
@export var spawn_invuln_seconds: float = 1.5

var fuel: float = 100.0
var _floating: bool = false

var _move_speed_multiplier: float = 1.0

@export var hover_amp_px: float = 3.0
@export var hover_speed_hz: float = 1.6
@export var hover_speed_jitter: float = 0.35
@export var hover_phase_jitter: float = 6.283185

var _hover_t: float = 0.0
var _hover_speed_mul: float = 1.0
var _hover_phase: float = 0.0
var _sprite_base_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	fuel = fuel_max
	cam.make_current()
	cam.zoom = normal_zoom
	$Sprite2D.flip_h = false if sprite_faces_right_by_default else true

	_sprite_base_pos = $Sprite2D.position
	var rng := RandomNumberGenerator.new()
	rng.seed = int(get_instance_id())
	_hover_speed_mul = rng.randf_range(1.0 - hover_speed_jitter, 1.0 + hover_speed_jitter)
	_hover_phase = rng.randf_range(0.0, hover_phase_jitter)

	invuln_timer.one_shot = true
	invuln_timer.wait_time = invuln_seconds
	invuln_timer.timeout.connect(func():
		_invuln = false
		modulate = Color.WHITE
		_move_speed_multiplier = 1.0
	)

func _physics_process(delta: float) -> void:
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0
	if Input.is_action_pressed("move_right"):
		dir += 1.0

	velocity.x = dir * speed * _move_speed_multiplier

	# Cancel float -> drop
	if _floating and Input.is_action_just_pressed("float_cancel"):
		_floating = false
		cam.zoom = normal_zoom

	if is_on_floor():
		# On ground: regen fuel and allow normal jump
		_floating = false
		cam.zoom = normal_zoom
		fuel = min(fuel_max, fuel + fuel_regen_per_sec * delta)

		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		# In air: either falling normally or floating
		if Input.is_action_just_pressed("jump") and (not _floating) and fuel > 0.0:
			# Second press in air enters float mode
			_floating = true
			cam.zoom = float_zoom

		if _floating and fuel > 0.0:
			# Float mode: no gravity.
			# Hold jump or float_down to move vertically. Both use fuel.
			# If neither is held, hover in place with no fuel cost.
			var moving_vertically := false

			if Input.is_action_pressed("jump"):
				velocity.y = -float_up_speed
				moving_vertically = true
			elif Input.is_action_pressed("float_down"):
				velocity.y = float_fall_speed
				moving_vertically = true

			if moving_vertically:
				fuel = max(0.0, fuel - fuel_up_drain_per_sec * delta)
				if fuel <= 0.0:
					_floating = false
					cam.zoom = normal_zoom
					if velocity.y < 0.0:
						velocity.y = 0.0
			else:
				velocity.y = 0.0
		else:
			velocity.y += gravity * delta

	move_and_slide()

	# Shoot
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if bullet_scene == null:
		return
	var b := bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = muzzle.global_position
	GameState.add_bullet_shot()

	# Direction: based on sprite flip
	var facing := 1.0
	if $Sprite2D.flip_h:
		facing = -1.0
	b.set_direction(Vector2(facing, 0))

func set_facing_from_motion() -> void:
	if abs(velocity.x) > 1.0:
		var want_face_right := velocity.x > 0.0
		$Sprite2D.flip_h = (want_face_right != sprite_faces_right_by_default)

func _process(_delta: float) -> void:
	set_facing_from_motion()
	_apply_hover(_delta)

func _apply_hover(delta: float) -> void:
	_hover_t += delta
	var y := sin((_hover_t * TAU * hover_speed_hz * _hover_speed_mul) + _hover_phase) * hover_amp_px
	$Sprite2D.position = _sprite_base_pos + Vector2(0, y)

func take_contact_damage() -> void:
	if _invuln:
		return
	_invuln = true
	modulate = Color(1, 0.6, 0.6) # flash
	invuln_timer.start()

	_move_speed_multiplier = contact_slow_multiplier


	_floating = false
	cam.zoom = normal_zoom

	GameState.take_damage(1)
	# Respawn only when you actually run out of lives.
	if GameState.lives <= 0:
		GameState.request_respawn(global_position)

func on_respawn() -> void:
	# Prevent instant damage after respawn.
	# Keep invulnerability without red flash.
	_invuln = true
	if invuln_timer != null:
		invuln_timer.wait_time = spawn_invuln_seconds
		invuln_timer.start()

	modulate = Color.WHITE
	_move_speed_multiplier = 1.0
	_floating = false
	cam.zoom = normal_zoom

func on_teleport() -> void:
	# Teleport uses the same respawn invulnerability.
	on_respawn()

func add_fuel(amount: float) -> void:
	fuel = clamp(fuel + amount, 0.0, fuel_max)

func fuel_ratio() -> float:
	if fuel_max <= 0.0:
		return 0.0
	return fuel / fuel_max
