extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.pop_open.connect(_popOp)
	SignalBus.pop_close.connect(_popCl)

func _popOp():
	set_process(false)

func _popCl():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.player_has_control && position.x > -320 && position.x < 320:
		position.x += Global.cameraPan
	elif position.x <= -320 && Global.cameraPan > 0:
		position.x += Global.cameraPan
	elif position.x >= 320 && Global.cameraPan < 0:
		position.x += Global.cameraPan
