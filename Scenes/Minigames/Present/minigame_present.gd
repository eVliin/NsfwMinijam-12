extends Node2D

@onready var presents: Node = get_parent().get_parent().get_node('Presents')

var id : int
var _id = -1
var paused = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = presents.get_child(id).name.to_int()
	$SubViewportContainer/SubViewport.handle_input_locally = true
	SignalBus.present_open.connect(_opened)
	SignalBus.present_close.connect(_closed)
	set_process_input(false)

func _opened(ID):
	if ID.to_int() == id:
		print(ID)
		_id = ID.to_int()
		visible = not visible
		#paused = not paused
		set_process_input(true)

func _closed():
	if _id == id:
		visible = not visible
		#paused = not paused
		SignalBus.pop_close.emit()
		_id = -1
		set_process_input(false)
		print(is_processing_input())
