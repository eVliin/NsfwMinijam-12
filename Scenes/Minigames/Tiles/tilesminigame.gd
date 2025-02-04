extends SubViewportContainer
#
func _ready():
	$SubViewport/Tiles.close.connect(_on_close)
	show()

func _on_close():
	if visible:
		hide()
		SignalBus.minigame_hide.emit()
