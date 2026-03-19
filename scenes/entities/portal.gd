extends Area2D

@export var portal_texture: Texture2D
@export var teleport_to: Vector2 = Vector2.ZERO
@export var target_portal: NodePath
@export var cooldown_seconds: float = 0.35
@export var player_teleport_guard_seconds: float = 0.6

# Destinations won't teleport.
# This helps prevent teleport loops.
@export var auto_disable_as_destination: bool = true
@export var destination_match_epsilon_px: float = 3.0

# This portal always teleports.
@export var force_active: bool = false

var _cooldown_left: float = 0.0
var _can_teleport: bool = true

func _ready() -> void:
	add_to_group("ufo_portals")

	if portal_texture != null and has_node("Sprite2D"):
		$Sprite2D.texture = portal_texture

	# Optional: set teleport_to from another portal node.
	if target_portal != NodePath("") and has_node(target_portal):
		var t := get_node(target_portal)
		if t is Node2D:
			teleport_to = t.global_position

	body_entered.connect(_on_body_entered)

	# Wait 1 frame so all portals are in the scene tree.
	await get_tree().process_frame
	_update_can_teleport()

func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = max(0.0, _cooldown_left - delta)

func _update_can_teleport() -> void:
	_can_teleport = true
	if force_active:
		return
	if not auto_disable_as_destination:
		return

	# If another portal targets here, this is a destination.
	var my_pos := global_position
	for n in get_tree().get_nodes_in_group("ufo_portals"):
		if n == self:
			continue
		# Compare teleport target to our position.
		# We read teleport_to via get so this works safely.
		var other_tp_variant: Variant = n.get("teleport_to")
		if typeof(other_tp_variant) != TYPE_VECTOR2:
			continue
		var other_tp: Vector2 = other_tp_variant
		if other_tp.distance_to(my_pos) <= destination_match_epsilon_px:
			_can_teleport = false
			return

func _on_body_entered(b: Node) -> void:
	if _cooldown_left > 0.0:
		return
	if not _can_teleport:
		return
	if b == null:
		return
	if not b.is_in_group("player"):
		return

	# Prevent instant teleport loops when portals overlap.
	var now_ms := Time.get_ticks_msec()
	if b.has_meta("portal_cooldown_until_ms"):
		var until_ms := int(b.get_meta("portal_cooldown_until_ms"))
		if now_ms < until_ms:
			return

	var guard_until_ms := now_ms + int(player_teleport_guard_seconds * 1000.0)

	_cooldown_left = cooldown_seconds
	b.global_position = teleport_to
	b.set_meta("portal_cooldown_until_ms", guard_until_ms)

	# Stop movement immediately to prevent weird physics.
	if b is CharacterBody2D:
		b.velocity = Vector2.ZERO

	# Clear floating/hurt visuals if player implements it.
	if b.has_method("on_teleport"):
		b.on_teleport()
