extends Area2D

@export var off_texture: Texture2D
@export var on_texture: Texture2D

var _activated: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	# If textures aren't set, keep the existing texture.
	if off_texture == null:
		off_texture = sprite.texture

	body_entered.connect(func(b):
		if b != null and b.is_in_group("player"):
			if not _activated:
				_activate()
	)
	_update_ui()

func _activate() -> void:
	_activated = true
	GameState.set_checkpoint(global_position)
	_update_ui()

func _update_ui() -> void:
	if _activated and on_texture != null:
		sprite.texture = on_texture
	elif (not _activated) and off_texture != null:
		sprite.texture = off_texture

	if _activated:
		label.text = "Beacon active"
	else:
		label.text = ""
