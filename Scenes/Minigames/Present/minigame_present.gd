# Minigame Present Container Controller
# Handles present visibility, puzzle configuration, and input processing
extends SubViewportContainer

### Node References ###
# WARNING: Fragile parent hierarchy dependency
@onready var presents: Node = get_parent().get_parent().get_parent().get_parent().get_node('Presents')
@onready var present: StaticBody3D = $SubViewport/Minigame/Present

### Signals ###
signal color_set  # Emitted when present color is configured

### State Properties ###
var _id = -1       # Current instance ID (-1 = inactive)
var defined: bool = false  # Puzzle configuration flag

func _ready() -> void:
	# Initial setup
	hide()  # Start hidden
	# Configure color from parent presents system
	present.color = presents.get_child(name.to_int()).color
	color_set.emit()
	
	# Signal connections
	SignalBus.define_puzzles.connect(_define_puzzles)
	SignalBus.present_open.connect(_opened)
	SignalBus.present_close.connect(_closed)
	
	set_process_input(false)  # Disable input initially

### Signal Handlers ###
func _opened(ID):
	"""Handle present opening event"""
	if ID == name:
		_id = ID.to_int()
		visible = true
		set_process_input(true)  # Enable interaction

func _define_puzzles(_name, puzzles):
	"""Configure minigame puzzles when first opened"""
	if _name == name && !defined:
		present.puzzles = puzzles  # Requires 'puzzles' property on Present node
		present._define()          # Requires '_define()' method on Present node
		defined = true

### Input Handling ###
func _input(event: InputEvent) -> void:
	# Track mouse position globally
	if event is InputEventMouseMotion:
		Global.mouse = event.position
	
	# Handle click interactions
	elif event is InputEventMouseButton and Input.is_action_just_pressed("Select"):
		SignalBus.get_mouse_world_pos.emit(Global.mouse)

func _closed():
	"""Cleanup when present is closed"""
	if _id == name.to_int():
		_id = -1
		visible = false
		SignalBus.pop_close.emit()
		set_process_input(false)  # Disable interaction
