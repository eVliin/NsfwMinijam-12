# Global game state management and scene references
extends Node

### Scene Path Constants ###
## Path to main menu scene
const MAIN_MENU = "res://Scenes/Menus/Main Menu/MainMenu.tscn"
## Path to test room scene for development
const TEST_ROOM = "res://Scenes/Rooms/TestRoom/TestRoom.tscn"
## Path to HUD interface scene
const HUD = "res://Scenes/HUD/Hud.tscn"

### Game State Variables ###
## Tracks number of active pop-up windows/overlays
var popUpTrack: int
## Tracks attack sequence/state
var AttackTrack = 0
## Camera pan direction/state (0 = none)
var cameraPan = 0
## Reference to game controller instance
var game_controller: GameController
## Player input control toggle
var player_has_control: bool
## Stores mouse position (needs update in _input)
var mouse = Vector2()
## Queue of attack orders for battle system
var AttackOrder: Array
## Drag-and-drop state flag
var is_dragging: bool = false

### ID Generation System ###
var _id_counter: int = 0  # Backing field for puzzleid

## Auto-incrementing puzzle ID generator
var puzzleid:
	get:
		var current_id = _id_counter
		_id_counter += 1
		print("Generated new puzzle ID: ", current_id)
		return current_id
	set(value):
		# Prevent direct modification of puzzle IDs
		push_error("puzzleid is read-only! Use generate new IDs through getter")
