extends Control

var chosen_houses: Array = []

const color_lookup := {
	"red": Color(0.631, 0.137, 0.137, 1.0),
	"yellow": Color(0.831, 0.831, 0.349, 1.0),
	"blue": Color(0.341, 0.341, 0.71, 1.0),
	"green": Color(0.318, 2.358, 0.666, 1.0),
	"orange": Color(0.804, 0.412, 0.008, 1.0),
	"purple": Color(0.271, 0.055, 0.471, 1.0),
	"white": Color(1.0, 1.0, 1.0, 1.0)
}

@onready var houses: Control = $Houses
const colors := ["red", "yellow", "blue"]

var garden = null

func find_closest_dr(house):
	# Mouse pressed
	var drs = get_tree().get_nodes_in_group("DR")
	var closest = null
	var closest_distance = INF

	for dr in drs:
		if not dr.going:
			print(dr.going)

		
			var distance = global_position.distance_to(dr.global_position)
			
			if distance < closest_distance:
				closest_distance = distance
				closest = dr
	
	if closest:
		closest.move_here(garden.global_position, garden.level, garden, house)


func _on_timer_timeout() -> void:
	var available_houses = []

	for house in houses.get_children():
		if not house in chosen_houses:
			available_houses.append(house)

	# Stop if every house was already chosen
	if available_houses.is_empty():
		return

	var random_color = colors.pick_random()
	var random_house = available_houses.pick_random()

	chosen_houses.append(random_house)

	random_house.infect(random_color)

	$Timer.wait_time = randi_range(5, 20)
	$Timer.start()
