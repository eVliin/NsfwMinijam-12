extends Node2D

@onready var presents: Node = get_parent().get_parent().get_node('Presents')
@onready var present: StaticBody3D = $SubViewportContainer/SubViewport/Node3D/Present

signal color_set

var id : int
var _id = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = presents.get_child(id).name.to_int()
	present.color = presents.get_child(id).color
	color_set.emit()
	$SubViewportContainer/SubViewport.handle_input_locally = true
	SignalBus.present_open.connect(_opened)
	SignalBus.present_close.connect(_closed)
	set_process_input(false)

func _opened(ID):
	if ID.to_int() == id:
		_id = ID.to_int()
		visible = not visible
		set_process_input(true)

func _closed():
	if _id == id:
		visible = not visible
		SignalBus.pop_close.emit()
		_id = -1
		set_process_input(false)
		print(is_processing_input())
