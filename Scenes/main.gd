extends Control

var hover_count := 0

var mouse_on_dr := false
var dragging_dr := false

var chosen_houses: Array = []

const color_lookup := {
	"red": Color(0.631, 0.137, 0.137, 1.0),
	"yellow": Color(0.831, 0.831, 0.349, 1.0),
	"blue": Color(0.169, 0.169, 0.71, 1.0),
	"green": Color(0.37, 0.544, 0.124, 1.0),
	"orange": Color(0.804, 0.412, 0.008, 1.0),
	"purple": Color(0.271, 0.055, 0.471, 1.0),
	"white": Color(1.0, 1.0, 1.0, 1.0)
}

@onready var houses: Control = $Houses
const colors := [
	"red", "red", "red", "red",
	"yellow", "yellow", "yellow", "yellow",
	"blue", "blue", "blue", "blue",
	"green", "green",
	"orange", "orange",
	"purple", "purple",
	"white"
]



var garden = null

func find_closest_dr(garden, house):
	var drs = get_tree().get_nodes_in_group("DR")
	var closest = null
	var closest_distance = INF

	# First pass: same level
	for dr in drs:
		if dr.going:
			continue

		if dr.level != garden.level:
			continue

		var distance = garden.global_position.distance_to(dr.global_position)

		if distance < closest_distance:
			closest_distance = distance
			closest = dr

	# Second pass: any level
	if closest == null:
		closest_distance = INF

		for dr in drs:
			if dr.going:
				continue

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

	# More infected houses = longer until the next infection
	var infected := chosen_houses.size()

	var min_time := 10.0 + infected * 1.5
	var max_time := 15.0 + infected * 3.0

	$Timer.wait_time = randf_range(min_time, max_time)
	$Timer.start()
