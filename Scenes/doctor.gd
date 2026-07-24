extends AnimatedSprite2D

@onready var level_changers = get_tree().current_scene.get_node("LevelChangers").get_children()

var level := 0
var going := false
var color := ""

func _ready() -> void:
	level = int(String(get_parent().get_parent().name)[-1])
	
func move_here(cord: Vector2, lv: int, first_pos = null, second_pos = null) -> void:
	going = true
	if first_pos:
		first_pos.get_node("Area2D/CollisionShape2D").disabled = true
	
	var path_follow = get_parent()

	# Get to the correct level first
	while level != lv:
		var closest = null
		var closest_distance = INF

		for changer in level_changers:
			var name = String(changer.name).to_lower()

			if lv > level:
				if not name.begins_with("up"):
					continue
			else:
				if not name.begins_with("down"):
					continue

			var y_difference = abs(global_position.y - changer.global_position.y)

			if y_difference > 10:
				continue

			var d = global_position.distance_to(changer.global_position) + changer.global_position.distance_to(cord) * 0.5

			if d < closest_distance:
				closest_distance = d
				closest = changer
		
		if closest == null:
			push_error("No suitable level changer found!")
			return

		
		# Move to the level changer
		var step := 0.001
		if closest.global_position.x < global_position.x:
			step = -step
		
		while abs(global_position.x - closest.global_position.x) > 1:
			var old_x = global_position.x
			path_follow.progress_ratio += step
			await get_tree().process_frame

			if global_position.x > old_x:
				flip_h = false  # facing right
			elif global_position.x < old_x:
				flip_h = true   # facing left
		
		await use_stairs(closest)
		path_follow = get_parent()
	
	# Move to final destination
	var step := 0.001
	if cord.x < global_position.x:
		step = -step
	
	while global_position.distance_to(cord) > 50:
		var old_x = global_position.x
		path_follow.progress_ratio += step
		await get_tree().process_frame

		if global_position.x > old_x:
			flip_h = false  # facing right
		elif global_position.x < old_x:
			flip_h = true   # facing left
	
	play("default")
	if first_pos and second_pos:
		color = first_pos.color
		play(color)
		first_pos.harvest()
		first_pos.full = false
		first_pos.color = ""
		first_pos.get_node("Area2D/CollisionShape2D").disabled = false
		move_here(second_pos.global_position, second_pos.level, null, second_pos)
			
		
	if not first_pos and second_pos:
		if second_pos.name.begins_with("House"):
			second_pos.cure()
		elif second_pos.name.begins_with("Doctor"):
			second_pos.place_herb(color)

		going = false
	
	
func use_stairs(changer):
	var changer_name = String(changer.name)
	var stair_number = changer_name[-1]
	var stairs = get_tree().current_scene.get_node("Stairs" + stair_number)
	
	var old_follow = get_parent()
	
	var stair_follow = PathFollow2D.new()
	stair_follow.rotates = false
	stairs.add_child(stair_follow)
	
	old_follow.remove_child(self)
	stair_follow.add_child(self)
	
	var going_down = changer_name.to_lower().begins_with("down")
	
	if going_down:
		stair_follow.progress_ratio = 1.0
	else:
		stair_follow.progress_ratio = 0.0
	
	var target := 0.0 if going_down else 1.0
	var step := 0.002
	
	while abs(stair_follow.progress_ratio - target) > 0.001:
		if going_down:
			stair_follow.progress_ratio -= step
		else:
			stair_follow.progress_ratio += step
		
		await get_tree().process_frame
	
	stair_follow.progress_ratio = target

	# update level
	if going_down:
		level -= 1
	else:
		level += 1


	# Switch to the new level path
	var new_level_number = level
	var new_level_path = get_tree().current_scene.get_node("Level" + str(new_level_number))

	
	var new_follow = PathFollow2D.new()
	new_follow.rotates = false
	new_level_path.add_child(new_follow)
	
	var old_position = global_position

	stair_follow.remove_child(self)
	new_follow.add_child(self)

	new_follow.progress_ratio = get_closest_progress(new_level_path, old_position)

	
func get_closest_progress(path: Path2D, pos: Vector2) -> float:
	var closest_ratio := 0.0
	var closest_distance := INF
	
	var test_follow = PathFollow2D.new()
	path.add_child(test_follow)
	
	for i in range(501):
		var ratio = i / 500.0
		test_follow.progress_ratio = ratio
		
		var distance = test_follow.global_position.distance_to(pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_ratio = ratio
	
	test_follow.queue_free()
	
	return closest_ratio
	
