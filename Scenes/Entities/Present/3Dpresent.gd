# 3D Interactive Present Controller
# Handles puzzle assignment, visual appearance, and player interaction

extends StaticBody3D

### Configuration ###
@export var puzzles: Dictionary  # Dictionary of available puzzle types and their activation states
@export var red: Material        # Red color material 
@export var blue: Material       # Blue color material
@export var white: Material      # White color material

### State ###
@onready var color: String = "white"  # Current present color
var input = false          # Mouse hover state
var rotating = false       # Rotation interaction flag
var prev_mouse_position: Vector2 = Vector2()
var next_mouse_position: Vector2 = Vector2()

### Initialization ###
func _ready() -> void:
	# Connect mouse interaction signals
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

### Puzzle Configuration ###
func _define():
	"""Assign active puzzles to target positions randomly"""
	# Get and shuffle target nodes
	var target_nodes = get_children().filter(func(child): return child.is_in_group("Targets"))
	target_nodes.shuffle()
	
	# Get active puzzle types
	var active_puzzles = puzzles.keys().filter(func(puzzle): return puzzles[puzzle])
	
	# Assign puzzles to targets
	var max_puzzles = min(active_puzzles.size(), target_nodes.size())
	for i in max_puzzles:
		var target = target_nodes[i]
		target.visible = true
		target.type = active_puzzles[i]  # Requires 'type' property on target nodes
		target._configure_puzzle_visual()            # Requires '_match' method on target nodes
	
	# Hide unused targets
	for i in range(max_puzzles, target_nodes.size()):
		target_nodes[i].visible = false
	
	_on_color_set()

### Visual Appearance ###
func _on_color_set() -> void:
	"""Apply color materials to present components"""
	for child in get_children():
		if child.get_child_count() > 0:
			var mesh = child.get_child(0)
			if mesh is MeshInstance3D:
				_apply_material(mesh, child.name)

func _apply_material(mesh: MeshInstance3D, node_name: String) -> void:
	"""Set materials based on current color and part name"""
	match color:
		"blue":
			mesh.material_override = blue if node_name in ["Box", "Lid"] else white
		"red":
			mesh.material_override = red if node_name in ["Box", "Lid"] else white
		"white":
			mesh.material_override = white if node_name in ["Box", "Lid"] else red

### Interaction System ###
func _process(delta: float) -> void:
	"""Handle zoom controls and rotation interaction"""
	if Global.player_has_control:
		# Zoom controls
		if Input.is_action_just_pressed("Zoom_in") and global_position.z <= 4:
			global_position.z += 1
		if Input.is_action_just_pressed("Zoom_out") and global_position.z >= -10.4:
			global_position.z -= 1
		
		# Rotation controls
		if input and Input.is_action_just_pressed("Select"):
			rotating = true
			prev_mouse_position = get_viewport().get_mouse_position()
		
		if Input.is_action_just_released("Select"):
			rotating = false
		
		if rotating:
			next_mouse_position = get_viewport().get_mouse_position()
			rotate_y((next_mouse_position.x - prev_mouse_position.x) * 0.3 * delta)
			rotate_x((next_mouse_position.y - prev_mouse_position.y) * 0.3 * delta)
			prev_mouse_position = next_mouse_position

### Mouse Signal Handlers ###
func _on_mouse_entered() -> void:
	input = true

func _on_mouse_exited() -> void:
	input = false
