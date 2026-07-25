extends Node2D

@onready var pointing_arrow: Sprite2D = $PointingArrow

var start_y: float
var speed := 2.0      # Higher = faster
var amplitude := 5.0  # Pixels up/down

func _ready():
	start_y = pointing_arrow.position.y

func _process(delta):
	pointing_arrow.position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
