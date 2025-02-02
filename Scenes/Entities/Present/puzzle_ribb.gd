# PuzzleTargetController.gd
# Handles puzzle type visualization and minigame activation

extends Node3D

### Puzzle Type Configuration ###
const MATERIALS = {
	"lock": preload("res://Assets/Placeholder/present/Materials/lock.tres"),
	"picross": preload("res://Assets/Placeholder/present/Materials/picross.tres"),
	"rush": preload("res://Assets/Placeholder/present/Materials/rush.tres"),
	"slide": preload("res://Assets/Placeholder/present/Materials/slide.tres")
}

@export var type: String = "lock"  # (enum: lock, picross, rush, slide)

### Runtime Properties ###
var id: int = -1  # Unique puzzle instance ID

func _configure_puzzle_visual() -> void:
	"""Applies visual representation based on puzzle type"""
	# Get reference to the mesh component
	var lock_mesh = $Lock/Lock
	
	# Verify valid puzzle type
	if MATERIALS.has(type):
		# Apply material to second surface (index 1)
		lock_mesh.set_surface_override_material(1, MATERIALS[type])
	else:
		push_error("Invalid puzzle type: ", type)
	
	# Generate unique ID for this puzzle instance
	id = Global.puzzleid
	print("Configured puzzle ID: ", id)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	"""Handles player interaction with the puzzle target"""
	if event.is_action_pressed("Select"):
		SignalBus.minigame_show.emit(id, type)
