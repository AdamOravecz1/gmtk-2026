extends Control

@onready var dr = get_tree().get_first_node_in_group("LevelChangers")

func _ready() -> void:
	print(dr)
