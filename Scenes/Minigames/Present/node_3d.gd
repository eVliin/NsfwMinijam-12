extends Node3D

### Configuration ###
const MAX_RAY_DISTANCE = 1000  # Units in 3D space
const INTERACTION_LAYER = 1     # Collision layer for interactables

### Node References ###
@onready var minigame_present = $"../.." as SubViewportContainer
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	# Validate critical nodes exist
	assert(minigame_present != null, "Minigame present container not found!")
	assert(camera != null, "3D camera not found in viewport!")
	
	SignalBus.get_mouse_world_pos.connect(get_mouse_world_pos)

func get_mouse_world_pos(mouse_pos: Vector2):
	if !Global.player_has_control:
		return
		
	if !is_instance_valid(minigame_present) || !validate_minigame_instance():
		return

	var result = perform_raycast(mouse_pos)
	handle_interaction_result(result)

func validate_minigame_instance() -> bool:
	# Consider using proper instance tracking instead of name parsing
	return minigame_present.name.to_int() == minigame_present._id

func perform_raycast(mouse_pos: Vector2) -> Dictionary:
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_end = camera.project_position(mouse_pos, MAX_RAY_DISTANCE)
	
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_start
	params.to = ray_end
	params.collision_mask = INTERACTION_LAYER
	
	return get_world_3d().direct_space_state.intersect_ray(params)

func handle_interaction_result(result: Dictionary):
	if result.is_empty():
		SignalBus.present_close.emit()
	else:
		handle_valid_collision(result)

func handle_valid_collision(result: Dictionary):
	var collider = result.collider
	print("Interacted with: ", collider.name)
	
	# Example interaction handling
	if collider.is_in_group("PuzzleTargets"):
		SignalBus.puzzle_selected.emit(collider.puzzle_id)
