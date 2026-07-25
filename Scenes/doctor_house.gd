extends Node2D

@export var level := 0

@onready var arrow_scene := preload("res://Scenes/arrow.tscn")
var arrow: Node2D = null

var color = ""
var full := false

var mouse_on_top := false

const color_symbol := {
	"red": 1,
	"blue": 0,
	"yellow": 2,
	"green": 5,
	"orange": 3,
	"purple": 4,
	"white": 6
}

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	
func _process(delta: float) -> void:
	if get_tree().current_scene.mouse_on_dr:
		disable_highlight()
	elif mouse_on_top and not get_tree().current_scene.dragging_dr:
		enable_higlight()

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not get_tree().current_scene.mouse_on_dr:
		if full and arrow == null and event.pressed:
			arrow = arrow_scene.instantiate()
			add_child(arrow)
			arrow.z_index = 100
			arrow.start_location = global_position
			get_tree().current_scene.garden = self
		elif get_tree().current_scene.garden and not event.pressed:
			if can_mix(get_tree().current_scene.garden.color):
				get_tree().current_scene.find_closest_dr(get_tree().current_scene.garden, self)





func _on_area_2d_mouse_entered() -> void:
	if (full or get_tree().current_scene.garden) and not get_tree().current_scene.dragging_dr and get_tree().current_scene.garden != self:
		mouse_on_top = true
		($Sprite2D.material as ShaderMaterial).set_shader_parameter("outline_size", 1.0)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		get_tree().current_scene.hover_count += 1


func _on_area_2d_mouse_exited() -> void:
	await get_tree().process_frame
	get_tree().current_scene.hover_count -= 1
	($Sprite2D.material as ShaderMaterial).set_shader_parameter("outline_size", 0.0)
	if get_tree().current_scene.hover_count <= 0:
		mouse_on_top = false
		get_tree().current_scene.hover_count = 0
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		

func disable_highlight():
	($Sprite2D.material as ShaderMaterial).set_shader_parameter("outline_size", 0.0)

	
func enable_higlight():
	($Sprite2D.material as ShaderMaterial).set_shader_parameter("outline_size", 1.0)



func place_herb(c):
	if color == "":
		color = c
	else:
		color = mix_colors(color, c)

	$Bubble.play()
	full = true
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.modulate = get_tree().current_scene.color_lookup[color]
	$Symbols.visible = true
	$Symbols.modulate = get_tree().current_scene.color_lookup[color]
	$Symbols.frame = color_symbol[color]

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
	$Pour.play()
	full = false
	$AnimatedSprite2D.visible = false
	$Symbols.visible = false
