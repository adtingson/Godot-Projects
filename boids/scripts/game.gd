extends Node2D

const BIRD = preload("res://scenes/bird.tscn")

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var CHICK = BIRD.instantiate()
		CHICK.global_position = get_global_mouse_position()
		CHICK.global_rotation = randf_range(0,TAU)
		add_child(CHICK)
