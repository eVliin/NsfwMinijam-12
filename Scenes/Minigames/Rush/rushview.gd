extends SubViewportContainer
#
func _ready():
	$SubViewport/Rush.close.connect(_on_close)
	show()

func _on_close():
	if visible:
		hide()
		SignalBus.minigame_hide.emit()
