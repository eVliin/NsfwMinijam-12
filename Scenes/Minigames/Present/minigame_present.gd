extends Node2D

@onready var presents: Node = get_parent().get_parent().get_parent().get_node('Presents')
@onready var present: StaticBody3D = $SubViewportContainer/SubViewport/Minigame/Present

signal color_set

var _id = -1
var defined: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	present.color = presents.get_child(name.to_int()).color
	color_set.emit()
	$SubViewportContainer/SubViewport.handle_input_locally = true
	SignalBus.define_puzzles.connect(_define_puzzles)
	SignalBus.present_open.connect(_opened)
	SignalBus.present_close.connect(_closed)
	set_process_input(false)

func _opened(ID):
	if ID == name:
		_id = ID.to_int()
		visible = true
		set_process_input(true)

func _define_puzzles(_name, puzzles):
	if _name == name && !defined:
		print("defining")
		present.puzzles = puzzles
		present._define()
		defined = true

func _closed():
	if _id == name.to_int():
		_id = -1
		visible = false
		SignalBus.pop_close.emit()
		set_process_input(false)
