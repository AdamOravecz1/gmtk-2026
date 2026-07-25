extends Sprite2D

@onready var rectangle: Sprite2D = $Rectangle
@onready var click_sound: AudioStreamPlayer = $Click

var start_location: Vector2
var chain: Array[Sprite2D] = []

var spacing := 16.0
var last_count := 0


func _process(delta):
	global_position = get_global_mouse_position()
	rotation = (start_location - global_position).angle() - deg_to_rad(90)

	create_chain()


func create_chain():
	var distance = global_position.distance_to(start_location)
	var direction = global_position.direction_to(start_location)

	var count = int(distance / spacing)

	# Play sounds depending on change
	if count > last_count:
		for i in range(count - last_count):
			play_click(count)

	elif count < last_count:
		for i in range(last_count - count):
			play_click(count)

	# remove old chain
	for part in chain:
		part.queue_free()
	chain.clear()

	# create new chain
	for i in range(count):
		var part = rectangle.duplicate()
		add_child(part)

		part.global_position = global_position + direction * spacing * (i + 1)
		chain.append(part)

	last_count = count


func play_click(index: int):
	var sound = click_sound.duplicate()
	add_child(sound)

	sound.pitch_scale = 1.0 + (index * 0.03)
	sound.play()

	sound.finished.connect(func():
		sound.queue_free()
	)
