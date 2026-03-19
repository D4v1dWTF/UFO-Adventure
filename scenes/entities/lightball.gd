extends Area2D

@export var hover_amp_px: float = 3.5
@export var hover_speed_hz: float = 1.9
@export var hover_speed_jitter: float = 0.5
@export var hover_phase_jitter: float = 6.283185

var _hover_t: float = 0.0
var _hover_speed_mul: float = 1.0
var _hover_phase: float = 0.0
var _sprite_base_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_sprite_base_pos = $Sprite2D.position
	var rng := RandomNumberGenerator.new()
	rng.seed = int(get_instance_id())
	_hover_speed_mul = rng.randf_range(1.0 - hover_speed_jitter, 1.0 + hover_speed_jitter)
	_hover_phase = rng.randf_range(0.0, hover_phase_jitter)

	body_entered.connect(func(b):
		GameState.add_light_ball()
		if b != null and b.has_method("add_fuel"):
			b.add_fuel(18.0)
		queue_free()
	)

func _process(delta: float) -> void:
	_hover_t += delta
	var y := sin((_hover_t * TAU * hover_speed_hz * _hover_speed_mul) + _hover_phase) * hover_amp_px
	$Sprite2D.position = _sprite_base_pos + Vector2(0, y)
