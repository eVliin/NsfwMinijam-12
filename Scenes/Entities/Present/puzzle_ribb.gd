extends Node3D

const LOCK = preload("res://Assets/PLaceholder/present/Materials/lock.tres")
const PICROSS = preload("res://Assets/PLaceholder/present/Materials/picross.tres")
const RUSH = preload("res://Assets/PLaceholder/present/Materials/rush.tres")
const SLIDE = preload("res://Assets/PLaceholder/present/Materials/slide.tres")

@export var type : String

var id

# Called when the node enters the scene tree for the first time.
func _match() -> void:
	id = Global.puzzleid
	print(id)
	match type:
		"lock":
			$Lock/Lock.set_surface_override_material(1, LOCK)
		"picross":
			$Lock/Lock.set_surface_override_material(1, PICROSS)
		"rush":
			$Lock/Lock.set_surface_override_material(1, RUSH)
		"slide":
			$Lock/Lock.set_surface_override_material(1, SLIDE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if Input.is_action_just_pressed("Select"):
		SignalBus.minigame_show.emit(id, type)
