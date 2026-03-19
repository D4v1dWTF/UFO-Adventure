extends Area2D

@export var speed := 520.0
var _dir := Vector2.RIGHT

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	# Bullet scene uses VisibleOnScreenEnabler2D.
	if has_node("VisibleOnScreenEnabler2D"):
		$VisibleOnScreenEnabler2D.screen_exited.connect(func(): queue_free())

func set_direction(d: Vector2) -> void:
	_dir = d.normalized()
	if _dir.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func _physics_process(delta: float) -> void:
	global_position += _dir * speed * delta

func _on_area_entered(a: Area2D) -> void:
	# If it has a 'hit' method, call it.
	if a.has_method("hit"):
		a.hit()
	queue_free()

func _on_body_entered(_b: Node) -> void:
	if _b != null and _b.has_method("hit"):
		_b.hit()
	queue_free()
