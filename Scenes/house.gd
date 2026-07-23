extends Node2D


@export var level := 0

func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var drs = get_tree().get_nodes_in_group("DR")
			var closest = null
			var closest_distance = INF

			for dr in drs:
				if dr.going:
					continue
				var distance = global_position.distance_to(dr.global_position)
				
				if distance < closest_distance:
					closest_distance = distance
					closest = dr
			
			if closest:
				closest.move_here(global_position, level)
