extends Control

var in_tutorial = true

var score := 0

var hover_count := 0

var mouse_on_dr := false
var dragging_dr := false

var chosen_houses: Array = []

var planted_tutorial = ""

var paused := false

@onready var music_slider: HSlider = $CanvasLayer/ColorRect/MusicSlider
@onready var sfx_slider: HSlider = $CanvasLayer/ColorRect/SFXSlider


@onready var arrow_scene := preload("res://Scenes/pointing_arrow.tscn")

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

func _ready() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))

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

	var min_time := 10.0 + infected * 1.5 - (score / 4)
	var max_time := 15.0 + infected * 3.0 - (score / 2)

	$Timer.wait_time = randf_range(min_time, max_time)
	$Timer.start()

func add_point(n):
	score += n
	$CanvasLayer/Score.text = str(score)


func _on_button_pressed() -> void:
	paused = !paused
	if paused:
		get_tree().paused = true
		$CanvasLayer/ColorRect.visible = true
	else:
		get_tree().paused = false
		$CanvasLayer/ColorRect.visible = false


		
func _on_music_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func _on_full_screen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func end():
	$Death.play()
	get_tree().paused = true
	
	$CanvasLayer/ColorRect2.process_mode = Node.PROCESS_MODE_ALWAYS
	
	$CanvasLayer/ColorRect2/FinalScore.text = "Final score: " + str(score)
	$CanvasLayer/ColorRect2.visible = true
	
	var tween = $CanvasLayer/ColorRect2.create_tween()
	tween.tween_property($CanvasLayer/ColorRect2, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)

func _on_replay_pressed() -> void:
	for i in get_children():
		i.queue_free()
		
	get_tree().paused = false

	get_tree().reload_current_scene()
	
func delete_arrows():
	for i in $Arrows.get_children():
		i.queue_free()

func tutorial1():
	var arrow = arrow_scene.instantiate()
	$Arrows.add_child(arrow)
	arrow.global_position = $Houses/House2.global_position - Vector2(0, 80)
	$Houses/House2.infect("red")
	
	
func tutorial2():
	var arrow = arrow_scene.instantiate()
	$Arrows.add_child(arrow)
	arrow.global_position = $Garden3.global_position - Vector2(0, 80)
	$Garden3.clickable = true

func tutorial3():
	var arrow = arrow_scene.instantiate()
	$Arrows.add_child(arrow)
	arrow.global_position = $Garden3.global_position - Vector2(0, 80)
	var arrow2 = arrow_scene.instantiate()
	$Arrows.add_child(arrow2)
	arrow2.global_position = $Houses/House2.global_position - Vector2(0, 80)

func tutorial4():
	$Houses/House2.clickable = false
	$Houses/House6.clickable = true
	$Garden2.clickable = true
	$Garden3.clickable = true
	var arrow = arrow_scene.instantiate()
	$Arrows.add_child(arrow)
	arrow.global_position = $Garden3.global_position - Vector2(0, 80)
	var arrow2 = arrow_scene.instantiate()
	$Arrows.add_child(arrow2)
	arrow2.global_position = $Garden2.global_position - Vector2(0, 80)
	var arrow3 = arrow_scene.instantiate()
	$Arrows.add_child(arrow3)
	arrow3.global_position = $Houses/House6.global_position - Vector2(0, 80)
	if $Houses/House6.color == "":
		$Houses/House6.infect("orange")
		
func tutorial5():
	$DoctorHouse2.clickable = true
	var arrow = arrow_scene.instantiate()
	$Arrows.add_child(arrow)
	arrow.global_position = $Garden3.global_position - Vector2(0, 80)
	var arrow2 = arrow_scene.instantiate()
	$Arrows.add_child(arrow2)
	arrow2.global_position = $Garden2.global_position - Vector2(0, 80)
	var arrow3 = arrow_scene.instantiate()
	$Arrows.add_child(arrow3)
	arrow3.global_position = $DoctorHouse2.global_position - Vector2(0, 80)

func tutorial6():
	$Garden3.clickable = false
	$Garden2.clickable = false
	var arrow2 = arrow_scene.instantiate()
	$Arrows.add_child(arrow2)
	arrow2.global_position = $Houses/House6.global_position - Vector2(0, 80)
	var arrow3 = arrow_scene.instantiate()
	$Arrows.add_child(arrow3)
	arrow3.global_position = $DoctorHouse2.global_position - Vector2(0, 80)
	
func finish_tutorial():
	
	$Timer.start()
	for i in $Houses.get_children():
		i.tutorial_cure()
		i.clickable = true
		
	
		
	$DoctorHouse.clickable = true
	$DoctorHouse2.clickable = true
	$DoctorHouse3.clickable = true
	$DoctorHouse.tutorial_harvest()
	$DoctorHouse2.tutorial_harvest()
	$DoctorHouse3.tutorial_harvest()
	
	$Garden.clickable = true
	$Garden2.clickable = true
	$Garden3.clickable = true
	$Garden.tutorial_harvest()
	$Garden2.tutorial_harvest()
	$Garden3.tutorial_harvest()

	for i in get_tree().get_nodes_in_group("DR"):
		i.clickable = true
		
	delete_arrows()
	
	in_tutorial = false


func _on_settings_pressed() -> void:
	_on_button_pressed()


func _on_resume_pressed() -> void:
	_on_button_pressed()


func _on_start_pressed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Camera2D, "global_position", Vector2($Camera2D.global_position.x, 322), 3.0)
	await tween.finished
	$CanvasLayer/Button.visible = true
	$CanvasLayer/Score.visible = true
	$TalkingDr.start()
