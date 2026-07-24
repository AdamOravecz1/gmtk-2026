extends Node2D

@export var level := 0

@onready var arrow_scene := preload("res://Scenes/arrow.tscn")
var arrow: Node2D = null

var color = ""
var full := false

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and !event.pressed:
		if arrow:
			arrow.queue_free()
			arrow = null
			await get_tree().process_frame
			get_tree().current_scene.garden = null

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if full and arrow == null and event.pressed:
			arrow = arrow_scene.instantiate()
			add_child(arrow)
			arrow.z_index = 100
			arrow.start_location = global_position
			get_tree().current_scene.garden = self
		elif get_tree().current_scene.garden and not event.pressed:
			if can_mix(get_tree().current_scene.garden.color):
				get_tree().current_scene.find_closest_dr(self)


func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func place_herb(c):
	if color == "":
		color = c
	else:
		color = mix_colors(color, c)

	full = true
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.modulate = get_tree().current_scene.color_lookup[color]


func mix_colors(a: String, b: String) -> String:
	if a == b:
		return a

	# Primary + primary -> secondary
	var mixes = {
		"redyellow": "orange",
		"yellowred": "orange",

		"redblue": "purple",
		"bluered": "purple",

		"yellowblue": "green",
		"blueyellow": "green"
	}

	var key = a + b

	if key in mixes:
		return mixes[key]

	# Secondary + missing primary -> white
	var secondary_mixes = {
		"orangeblue": "white",
		"blueorange": "white",

		"greenred": "white",
		"redgreen": "white",

		"purpleyellow": "white",
		"yellowpurple": "white"
	}

	if key in secondary_mixes:
		return secondary_mixes[key]

	return a

func can_mix(incoming_color: String) -> bool:
	if color == "":
		return true

	if color == "white":
		return false

	if color == incoming_color:
		return false

	var possible_mixes = [
		["red", "yellow"],
		["red", "blue"],
		["yellow", "blue"],

		["orange", "blue"],
		["green", "red"],
		["purple", "yellow"]
	]

	for pair in possible_mixes:
		if color in pair and incoming_color in pair:
			return true

	return false	

func harvest():
	color = ""
	full = false
	$AnimatedSprite2D.visible = false
