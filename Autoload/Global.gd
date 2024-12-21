extends Node

const MAIN_MENU = "res://Scenes/Menus/Main Menu/MainMenu.tscn"
const TEST_ROOM = "res://Scenes/Rooms/TestRoom/TestRoom.tscn"
const HUD = "res://Scenes/HUD/Hud.tscn"

var game_controller : GameController
var player_has_control : bool
var mouse = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Select"):
			SignalBus.get_mouse_world_pos.emit(mouse)
