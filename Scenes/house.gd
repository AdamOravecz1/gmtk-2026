extends Node2D

@onready var time: Label = $Time

@export var color := ""
@export var level := 0

var countdown_time := 30.0 # seconds
var start_time: int
var running := false


func _process(delta):
	if running:
		var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
		var remaining = countdown_time - elapsed
		
		if remaining <= 0:
			remaining = 0
			running = false
		
		var seconds = int(remaining)
		var milliseconds = int((remaining - seconds) * 10)
		
		time.text = "%02d.%d" % [seconds, milliseconds]

func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			
			if not event.pressed and color and get_tree().current_scene.garden:
				if color == get_tree().current_scene.garden.color:
					get_tree().current_scene.find_closest_dr(self)

func infect(c):
	color = c
	$AnimatedSprite2D.modulate = get_tree().current_scene.color_lookup[color]
	time.visible = true
	start_time = Time.get_ticks_msec()
	running = true
	
func cure():
	color = ""
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	get_tree().current_scene.chosen_houses.erase(self)
	time.visible = false
	running = false
