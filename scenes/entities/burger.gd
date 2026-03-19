extends Area2D

func _ready() -> void:
	body_entered.connect(func(_b):
		GameState.add_burger()
		# Goal met: finish the run and show the win screen.
		if GameState.burgers_collected >= GameState.burgers_required:
			GameState.finish_run()
			get_tree().change_scene_to_file("res://scenes/ui/winscreen.tscn")
		queue_free()
	)
