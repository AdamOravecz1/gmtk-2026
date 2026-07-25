
extends Node2D

@onready var label: RichTextLabel = $RichTextLabel
@onready var talk_sound: AudioStreamPlayer = $Talk


var dialogue := [
	"Hello Sir! We have a plague situation on our hands, and we need your help to manage this crisis.",
	"Here is the first infected house. It looks like this is the [color=#ef5350]red[/color] plague.",
	"To cure the [color=#ef5350]red[/color] infection, we need to grow [color=#ef5350]red[/color] herbs. Click on a garden and select the [color=#ef5350]red[/color] plant.",
	"We need to wait a few seconds for them to grow. When they are ready, drag them from the garden to the infected house.",
	"The closest not walking doctor will pick it up and deliver the cure.",
	"Very good. The next sickness looks a bit more complicated.",
	"To cure the [color=#ff9800]orange[/color] plague, we will need both [color=#ef5350]red[/color] and [color=#fdd835]yellow[/color] herbs. Click on the gardens and plant them.",
	"When they are ready, drag both herbs to a doctor's house to mix them.",
	"After they are mixed at the doctor's house, you can drag the cure to the infected house.",
	"Now you know everything you need. I will leave the rest to you. Cure as many people as you can, and don't let their counters reach zero.",
	"You can also drag the doctors to be closer where you need them to be.",
	"Be careful, if all doctors are already busy, there will be no one left to respond to new commands.",
	"If you need help, you can check the recipes in the pause menu.",
	"Good luck. You will need it..."
]
var line_index := 0

var typing := false
var full_text := ""

var speed := 0.03


func _ready() -> void:

	show_line()


func show_line():
	get_tree().current_scene.delete_arrows()
	if line_index >= dialogue.size():
		get_tree().current_scene.finish_tutorial()
		queue_free()
		return

	label.text = dialogue[line_index]
	label.visible_characters = 0
	typing = true

	type_text()


func type_text():
	talk_sound.play()

	while label.visible_characters < label.get_total_character_count():
		if !typing:
			label.visible_characters = label.get_total_character_count()
			break

		label.visible_characters += 1
		await get_tree().create_timer(speed).timeout

	talk_sound.stop()
	typing = false

func next_line():
	print(line_index)
	if typing:
		typing = false
		talk_sound.stop()
		return
	if line_index in [0,1,5,9,10,11,12,13]:
		line_index += 1
		show_line()
	if line_index == 1:
		get_tree().current_scene.tutorial1()
	if line_index == 2:
		get_tree().current_scene.tutorial2()
	if line_index == 6:
		get_tree().current_scene.tutorial4()



func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		next_line()

func _on_button_pressed() -> void:
	next_line()


func _on_button_2_pressed() -> void:
	$CanvasLayer.queue_free()
	
func next():
	line_index += 1
	show_line()
	if line_index == 3:
		get_tree().current_scene.tutorial3()
	if line_index == 7:
		get_tree().current_scene.tutorial5()
	if line_index == 8:
		get_tree().current_scene.tutorial6()
