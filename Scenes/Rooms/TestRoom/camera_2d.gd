extends Camera2D

@onready var Room: Node2D = $".."
@onready var fnaf_ass_camera: Node2D = $"Fnaf ass camera"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.pop_open.connect(_popOp)
	SignalBus.pop_close.connect(_popCl)

func _popOp():
	fnaf_ass_camera.set_process(false)
	Global.cameraPan = 0

func _popCl():
	if Room.popUpTrack == 0:
		fnaf_ass_camera.set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_has_control && position.x > -320 && position.x < 320:
		position.x += Global.cameraPan
	elif position.x <= -320 && Global.cameraPan > 0:
		position.x += Global.cameraPan
	elif position.x >= 320 && Global.cameraPan < 0:
		position.x += Global.cameraPan
