# Main game manager handling minigames, puppets, UI, and debug controls
extends Node2D

## Debug label showing current aggro level. {0} will be replaced with aggro value
@export var debug_label_text: String = "Aggro level: {0},\npress up or down to change it (yes you are helping me debug this)"

## Current aggro point value with setter for label updates
@export var point: int:
	set(value):
		_point = value
		# Update debug label text when value changes
		$Camera2D/MinigameLayer/Label.text = debug_label_text.format([value])

# Minigame scene constants
const MINIGAME_PRESENT = preload("res://Scenes/Minigames/Present/MinigamePresent.tscn")
const RUSH = preload("res://Scenes/Minigames/Rush/rushminigame.tscn")
const TILES = preload("res://Scenes/Minigames/Tiles/tilesminigame.tscn")

# Node references
@onready var presents_node: Node = $Presents
@onready var camera_node: Node = $"Camera2D/Fnaf ass camera"  # TODO: Rename to more descriptive name
@onready var presents: Control = $Camera2D/MinigameLayer/presents
@onready var minigames_node: Node = $Camera2D/MinigameLayer/minigames


var _point: int = 0  # Backing field for point property
var on := true

func _ready() -> void:
	# Signal connections for game events
	SignalBus.pop_open.connect(_pop_up)
	SignalBus.minigame_show.connect(_minigame)
	SignalBus.minigame_hide.connect(_minigame_close)
	SignalBus.pop_close.connect(_pop_close)
	SignalBus.attacking.connect(_pop_up)
	SignalBus.puppet_cummed.connect(_pop_close)  # TODO: Consider renaming signal to something more professional
	Dialogic.timeline_started.connect(_label)
	Dialogic.timeline_ended.connect(_label)
	
	# Initialize global game state
	Global.AttackTrack = 0
	Global.popUpTrack = 0
	
	# Start dialogue system
	Dialogic.start('TestDialogue')
	
	# Create present minigame instances
	for i in presents_node.get_child_count():
		var instance = MINIGAME_PRESENT.instantiate()
		instance.name = str(i)
		presents.add_child(instance)

func _label():
	on = !on
	if on:
		$Camera2D/MinigameLayer/Label2.show()
		$Camera2D/MinigameLayer/Label.show()
	else:
		$Camera2D/MinigameLayer/Label2.hide()
		$Camera2D/MinigameLayer/Label.hide()

## Handles showing minigames based on type
func _minigame(id, type):
	print("Opening minigame: ", id, " ", type)
	presents.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Determine which minigame scene to load
	var target_scene = type
	
	match target_scene:
		"rush":
			target_scene = RUSH
		"tiles":
			target_scene = TILES
	
	if not target_scene:
		push_error("Invalid minigame type: ", type)
		return
	
	var existing_node = minigames_node.get_node_or_null(str(id))
	_pop_up()  # Show pop-up overlay
	
	# Reuse existing instance or create new one
	if existing_node:
		existing_node.visible = true
	else:
		var new_instance = target_scene.instantiate()
		new_instance.name = str(id)
		minigames_node.add_child(new_instance)
		new_instance.visible = true

## Handles closing minigames and restoring UI
func _minigame_close():
	_pop_close()
	update_presents_processing()

## Updates present button availability based on active minigames
func update_presents_processing():
	var all_hidden = true
	for child in minigames_node.get_children():
		if child.visible:
			all_hidden = false
			break
	
	# TODO: Fix this assignment - currently does nothing (bug)
	if all_hidden:
		presents.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		presents.process_mode = Node.PROCESS_MODE_DISABLED

## Track pop-up overlay state
func _pop_up():
	Global.popUpTrack += 1
	print("Pop-up count: ", Global.popUpTrack)

func _pop_close():
	Global.popUpTrack = max(0, Global.popUpTrack - 1)
	print("Pop-up count: ", Global.popUpTrack)

func _process(delta: float) -> void:
	# Handle UI visibility based on pop-up state
	if Global.popUpTrack <= 0:
		presents_node.process_mode = Node.PROCESS_MODE_INHERIT
		camera_node.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		Global.cameraPan = 0
		presents_node.process_mode = Node.PROCESS_MODE_DISABLED
		camera_node.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Debug controls for aggro system
	if Input.is_action_just_pressed("ui_up") && $"Puppets/0".aggro < 5:
		adjust_aggro(1)
	
	if Input.is_action_just_pressed("ui_down") && $"Puppets/0".aggro > 1:
		adjust_aggro(-1)

## Adjust aggro for all puppets and update debug display
func adjust_aggro(amount: int):
	for i in 3:  # Hardcoded puppet count - consider dynamic lookup
		var puppet = get_node("Puppets/%s" % i)
		puppet.aggro = clamp(puppet.aggro + amount, 1, 5)
	point = $"Puppets/0".aggro
