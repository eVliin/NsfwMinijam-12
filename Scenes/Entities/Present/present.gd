# Present object that triggers minigames when interacted with
extends Node2D

## Color variant of the present (affects visual appearance)
@export_enum("red", "blue", "white") var color: String

## Dictionary of available minigames for this present
@export var puzzles: Dictionary = {
	"lock": true,    # Lockpicking minigame
	"picross": false, # Grid-based puzzle
	"rush": true,    # Rush Hour-style puzzle
	"tiles": false   # Sliding tile puzzle
}

# Present texture constants
const PRESENTBLUE = preload("res://Assets/Sprites/Presents/presentblue.png")
const PRESENTRED = preload("res://Assets/Sprites/Presents/presentred.png")
const PRESENTWHITE = preload("res://Assets/Sprites/Presents/presentwhite.png")

func _ready() -> void:
	# Set initial present texture based on selected color
	get_viewport().set_input_as_handled()
	match color:
		"blue":
			$Sprite2D.texture = PRESENTBLUE
		"red":
			$Sprite2D.texture = PRESENTRED
		"white":
			$Sprite2D.texture = PRESENTWHITE

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Handle player interaction
	if Global.player_has_control and event.is_action_pressed("Select"):
		# Signal sequence when present is opened:
		SignalBus.present_open.emit(name)       # Identify which present was opened
		SignalBus.pop_open.emit()               # Show UI overlay
		SignalBus.define_puzzles.emit(name, puzzles)  # Activate specific minigames
