extends Node2D

@onready var herb_selector: Sprite2D = $HerbSelector
@onready var herb: Sprite2D = $Herb
@onready var timer: Timer = $Timer
@onready var time: Label = $Time

var full := false
var color := ""

var countdown_time := 12.0 # seconds
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

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			$Area2D/CollisionShape2D.disabled = true
			print("garden")
			herb_selector.visible = true
			var tween = get_tree().create_tween()
			tween.tween_property(herb_selector, "scale", Vector2(1, 1), 0.2)
			


func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func close_selector():
	herb_selector.scale = Vector2(0, 0)
	herb_selector.visible = false
	


func _on_red_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_red_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_blue_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_blue_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_yellow_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_yellow_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_red_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			color = "red"
			herb.visible = true
			herb.modulate = Color(0.631, 0.137, 0.137, 1.0)
			timer.start()
			start_timer()
			close_selector()
			

func _on_blue_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			color = "blue"
			herb.visible = true
			herb.modulate = Color(0.341, 0.341, 0.71, 1.0)
			timer.start()
			start_timer()
			close_selector()

func _on_yellow_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			color = "yellow"
			herb.visible = true
			herb.modulate = Color(0.831, 0.831, 0.349, 1.0)
			timer.start()
			start_timer()
			close_selector()
			
func _on_bg_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	await get_tree().process_frame
	if event is InputEventMouseButton and not herb.visible:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("huh")
			close_selector()
			$Area2D/CollisionShape2D.disabled = false

func start_timer():
	time.visible = true
	start_time = Time.get_ticks_msec()
	running = true


func _on_timer_timeout() -> void:
	if herb.frame < 3:
		herb.frame += 1
		timer.start()
	else:
		full = true
		time.visible = false
		running = false
		
