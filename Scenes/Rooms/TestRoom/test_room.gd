extends Node2D

const MINIGAME_PRESENT = preload("res://Scenes/Minigames/Present/MinigamePresent.tscn")

var popUpTrack :int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	popUpTrack = 0
	for i in $Presents.get_child_count():
		
		var instance = MINIGAME_PRESENT.instantiate()
		instance.id = i
		$MinigameLayer.add_child(instance)


func _pop_up():
	popUpTrack += 1
	set_process_input(false)

func _pop_close():
	popUpTrack -= 1
	if popUpTrack <= 0:
		set_process_input(true)
