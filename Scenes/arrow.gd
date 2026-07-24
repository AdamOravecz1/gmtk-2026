extends Sprite2D

@onready var rectangle: Sprite2D = $Rectangle

var start_location: Vector2
var chain: Array[Sprite2D] = []

var spacing := 16.0 # distance between rectangles

func _process(delta):
	global_position = get_global_mouse_position()
	rotation = (start_location - global_position).angle() - deg_to_rad(90)

	create_chain()


func create_chain():
	# remove old chain
	for part in chain:
		part.queue_free()
	chain.clear()

	var distance = global_position.distance_to(start_location)
	var direction = global_position.direction_to(start_location)

	var count = int(distance / spacing)

	for i in range(count):
		var part = rectangle.duplicate()
		add_child(part)

		part.global_position = global_position + direction * spacing * (i + 1)

		chain.append(part)
