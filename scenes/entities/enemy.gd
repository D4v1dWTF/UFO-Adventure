extends CharacterBody2D

@export var speed := 130.0
@export var gravity := 1200.0
var _dir := -1.0
@export var sprite_faces_left_by_default: bool = true

@export var hover_amp_px: float = 2.6
@export var hover_speed_hz: float = 1.3
@export var hover_speed_jitter: float = 0.45
@export var hover_phase_jitter: float = 6.283185

var _hover_t: float = 0.0
var _hover_speed_mul: float = 1.0
var _hover_phase: float = 0.0
var _sprite_base_pos: Vector2 = Vector2.ZERO

var _damage_target: Node = null

func _ready() -> void:
	$DamageArea.body_entered.connect(_on_damage_body_entered)
	$DamageArea.body_exited.connect(_on_damage_body_exited)
	# Set sprite facing defaults in Inspector if needed.
	$Sprite2D.flip_h = false
	_sprite_base_pos = $Sprite2D.position
	var rng := RandomNumberGenerator.new()
	rng.seed = int(get_instance_id())
	_hover_speed_mul = rng.randf_range(1.0 - hover_speed_jitter, 1.0 + hover_speed_jitter)
	_hover_phase = rng.randf_range(0.0, hover_phase_jitter)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = _dir * speed
	move_and_slide()

	# Simple wall turn-around
	if is_on_wall():
		_dir *= -1.0
		_update_facing()
	_apply_hover(delta)

	# Apply contact damage while overlapping.
	if _damage_target != null and is_instance_valid(_damage_target) and _damage_target.has_method("take_contact_damage"):
		_damage_target.take_contact_damage()

func _update_facing() -> void:
	# Flip sprite based on movement.
	var moving_right := _dir > 0.0
	# Flip logic depends on default art facing.
	if sprite_faces_left_by_default:
		$Sprite2D.flip_h = moving_right
	else:
		# Art faces RIGHT by default
		$Sprite2D.flip_h = not moving_right

func _apply_hover(delta: float) -> void:
	_hover_t += delta
	var y := sin((_hover_t * TAU * hover_speed_hz * _hover_speed_mul) + _hover_phase) * hover_amp_px
	$Sprite2D.position = _sprite_base_pos + Vector2(0, y)

func _on_damage_body_entered(b: Node) -> void:
	if b.has_method("take_contact_damage"):
		_damage_target = b

func _on_damage_body_exited(b: Node) -> void:
	if b == _damage_target:
		_damage_target = null

func hit() -> void:
	GameState.add_kill()
	queue_free()
