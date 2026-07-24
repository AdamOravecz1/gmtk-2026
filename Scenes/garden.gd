extends Node2D

@export var level := 0

@onready var arrow_scene := preload("res://Scenes/arrow.tscn")
var arrow: Node2D = null

@onready var herb_selector: Sprite2D = $HerbSelector
@onready var herb: Sprite2D = $Herb
@onready var timer: Timer = $Timer
@onready var time: Label = $Time
@onready var symbols: Sprite2D = $Symbols

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

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and !event.pressed:
		if arrow:
			arrow.queue_free()
			arrow = null
			await get_tree().process_frame
			get_tree().current_scene.garden = null

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if full and arrow == null:
			arrow = arrow_scene.instantiate()
			add_child(arrow)
			arrow.z_index = 100
			arrow.start_location = global_position
			get_tree().current_scene.garden = self

		else:

			$Area2D/CollisionShape2D.disabled = true
			herb_selector.visible = true
			var tween = get_tree().create_tween()
			tween.tween_property(herb_selector, "scale", Vector2.ONE, 0.2)
			


func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	get_tree().current_scene.hover_count += 1


func _on_area_2d_mouse_exited() -> void:
	get_tree().current_scene.hover_count -= 1
	if get_tree().current_scene.hover_count <= 0:
		get_tree().current_scene.hover_count = 0
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
			symbols.visible = true
			symbols.frame = 1
			herb.modulate = get_tree().current_scene.color_lookup["red"]
			symbols.modulate = get_tree().current_scene.color_lookup["red"]
			timer.start()
			start_timer()
			close_selector()
			

func _on_blue_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			color = "blue"
			herb.visible = true
			symbols.visible = true
			symbols.frame = 0
			herb.modulate = get_tree().current_scene.color_lookup["blue"]
			symbols.modulate = get_tree().current_scene.color_lookup["blue"]
			timer.start()
			start_timer()
			close_selector()

func _on_yellow_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			color = "yellow"
			herb.visible = true
			symbols.visible = true
			symbols.frame = 2
			herb.modulate = get_tree().current_scene.color_lookup["yellow"]
			symbols.modulate = get_tree().current_scene.color_lookup["yellow"]
			timer.start()
			start_timer()
			close_selector()
			
func _on_bg_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	await get_tree().process_frame
	if event is InputEventMouseButton and not herb.visible:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			close_selector()
			$Area2D/CollisionShape2D.disabled = false

func start_timer():
	time.visible = true
	start_time = Time.get_ticks_msec()
	running = true


func _on_timer_timeout() -> void:
	if herb.frame < 3:
		herb.frame += 1
	if herb.frame == 3:
		full = true
		time.visible = false
		running = false
		$Area2D/CollisionShape2D.disabled = false
	else:
		timer.start()
		
		
	
func harvest():
	herb.frame = 0
	herb.visible = false
	symbols.visible = false
	color = ""
