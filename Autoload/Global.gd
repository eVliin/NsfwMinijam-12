extends Node

const MAIN_MENU = "res://Scenes/Menus/Main Menu/MainMenu.tscn"
const TEST_ROOM = "res://Scenes/Rooms/TestRoom/TestRoom.tscn"
const HUD = "res://Scenes/HUD/Hud.tscn"


var AttackTrack = 0
var cameraPan = 0
var game_controller : GameController
var player_has_control : bool
var mouse = Vector2()
var AttackOrder :Array
var is_dragging :bool = false




func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Select"):
			SignalBus.get_mouse_world_pos.emit(mouse)
