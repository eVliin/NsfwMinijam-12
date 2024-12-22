extends Area2D

@export var SPEED_CHANGE : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(mouseEntered)
	mouse_exited.connect(mouseExited)


func mouseEntered() -> void:
	Global.cameraPan += SPEED_CHANGE

func mouseExited() -> void:
	Global.cameraPan -= SPEED_CHANGE
