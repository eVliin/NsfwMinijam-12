extends Node

const MAIN_MENU = "res://Scenes/Menus/Main Menu/MainMenu.tscn"
const TEST_ROOM = "res://Scenes/Rooms/TestRoom/TestRoom.tscn"
const HUD = "res://Scenes/HUD/Hud.tscn"


var popUpTrack :int
var AttackTrack = 0
var cameraPan = 0
var game_controller : GameController
var player_has_control : bool
var mouse = Vector2()
var AttackOrder :Array
var is_dragging :bool = false
var _id_counter: int = 0
var puzzleid:
	get():
		var current_id = _id_counter
		_id_counter += 1
		print("puzzleid accessed, new value: ", current_id)
		return current_id
	set(value):
		push_error("puzzleid é somente leitura!")
