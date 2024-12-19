extends Node

const MAIN_MENU = preload("res://Scenes/Menus/Main Menu/MainMenu.tscn")
const TEST_ROOM = preload("res://Scenes/Rooms/TestRoom/TestRoom.tscn")

func _ready() -> void:
	var main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
