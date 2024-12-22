#extends StaticBody3D
#
#@export var puzzles: Dictionary
#
#@export var red: Material
#@export var blue: Material
#@export var white: Material
#
#@onready var color: String = "white"
#
#var input = false
#var rotating = false
#var prev_mouse_position: Vector2 = Vector2()
#var next_mouse_position: Vector2 = Vector2()
#
#func _ready() -> void:
	## Assign puzzles to random children
	#SignalBus.define_puzzles.connect(_define)
#
#func _define(_puzzles):
	#print("welp")
	#puzzles = _puzzles
	#var target_nodes = []
	#for node in get_tree().get_nodes_in_group("Targets"):  # Group: "Targets"
		#target_nodes.append(node)
#
	#target_nodes.shuffle()
#
	#var active_puzzles = []
	#for puzzle in puzzles:
		#if puzzles[puzzle]:  # Filter active puzzles
			#active_puzzles.append(puzzle)
#
	#for i in range(active_puzzles.size()):
		#if i < target_nodes.size():
			#var target = target_nodes[i]
			#target.visible = true  # Make the node visible
			#target.set("puzzle_name", active_puzzles[i])  # Assign puzzle (custom property)
			#print(target.name + " assigned puzzle: " + active_puzzles[i])  # Debug
		#else:
			#break
#
	#for i in range(active_puzzles.size(), target_nodes.size()):
		#target_nodes[i].visible = false  # Hide unused targets
		#print(target_nodes[i].name + " is hidden.")  # Debug
#
	## Set colors for children based on the current color
	#_on_color_set()
#
#
#func _on_color_set() -> void:
	## Iterate over the children of StaticBody3D
	#for i in range(get_child_count()):
		#var child = get_child(i)
#
		## Check if the child has a valid subnode
		#if child and child.get_child_count() > 0:
			#var sub_child = child.get_child(0)
#
			## Ensure the sub_child is a MeshInstance3D
			#if sub_child is MeshInstance3D:
				#match color:
					#"blue":
						#if child.name == "Box" or child.name == "Lid":
							#sub_child.material_override = blue
						#else:
							#sub_child.material_override = white
					#"red":
						#if child.name == "Box" or child.name == "Lid":
							#sub_child.material_override = red
						#else:
							#sub_child.material_override = white
					#"white":
						#if child.name == "Box" or child.name == "Lid":
							#sub_child.material_override = white
						#else:
							#sub_child.material_override = red
#
#func _process(delta: float) -> void:
	## Zoom in and out
	#if Input.is_action_just_pressed("Zoom_in") and global_position.z <= 4:
		#global_position.z += 1
	#if Input.is_action_just_pressed("Zoom_out") and global_position.z >= -10.4:
		#global_position.z -= 1
#
	## Handle rotation logic
	#if input:
		#if Input.is_action_just_pressed("Select"):
			#rotating = true
			#prev_mouse_position = get_viewport().get_mouse_position()
	#if Input.is_action_just_released("Select"):
		#rotating = false
#
	#if rotating:
		#next_mouse_position = get_viewport().get_mouse_position()
		#var delta_mouse = next_mouse_position - prev_mouse_position
		#rotate_y(delta_mouse.x * 0.003)  # Adjust sensitivity
		#rotate_x(delta_mouse.y * 0.003)
		#prev_mouse_position = next_mouse_position
extends StaticBody3D

@export var puzzles: Dictionary
@export var red: Material
@export var blue: Material
@export var white: Material

@onready var color: String = "white"

var input = false
var rotating = false
var prev_mouse_position: Vector2 = Vector2()
var next_mouse_position: Vector2 = Vector2()

func _define():
	print("defining")
	# Get all target nodes in a single call, shuffle them
	var target_nodes = []
	for child in get_children():
		if child.is_in_group("Targets"):
			target_nodes.append(child)
	target_nodes.shuffle()
	
	# Get active puzzles in a list
	var active_puzzles = []
	for puzzle in puzzles:
		if puzzles[puzzle]:  # Check if the puzzle is active
			active_puzzles.append(puzzle)

	# Iterate over both active puzzles and target nodes and assign puzzles
	var max_puzzles = min(active_puzzles.size(), target_nodes.size())
	
	# Assign puzzles to target nodes
	for i in range(max_puzzles):
		target_nodes[i].visible = true
		target_nodes[i].set("type", active_puzzles[i])
		target_nodes[i]._match()
		print(target_nodes[i].name + " assigned puzzle: " + active_puzzles[i])

	# Hide any remaining target nodes
	for i in range(max_puzzles, target_nodes.size()):
		target_nodes[i].visible = false
		print(target_nodes[i].name + " is hidden.")

	# Apply colors after assigning puzzles
	_on_color_set()

func _on_color_set() -> void:
	print("color set")
	# Iterate over the StaticBody3D's children, setting materials
	for child in get_children():
		if child.get_child_count() > 0:
			var sub_child = child.get_child(0)
			if sub_child is MeshInstance3D:
				_apply_material(sub_child, child.name)

func _apply_material(sub_child: MeshInstance3D, node_name: String) -> void:
	# Apply material based on the current color state
	print(sub_child)
	match color:
		"blue":
			sub_child.material_override = blue if node_name in ["Box", "Lid"] else white
		"red":
			sub_child.material_override = red if node_name in ["Box", "Lid"] else white
		"white":
			sub_child.material_override = white if node_name in ["Box", "Lid"] else red

func _process(delta: float) -> void:
	# Handle zooming in and out
	if Input.is_action_just_pressed("Zoom_in") and global_transform.origin.z <= 4:
		global_transform.origin.z += 1
	elif Input.is_action_just_pressed("Zoom_out") and global_transform.origin.z >= -10.4:
		global_transform.origin.z -= 1

	# Handle rotation
	if input and Input.is_action_just_pressed("Select"):
		rotating = true
		prev_mouse_position = get_viewport().get_mouse_position()

	if Input.is_action_just_released("Select"):
		rotating = false

	if rotating:
		next_mouse_position = get_viewport().get_mouse_position()
		var delta_mouse = next_mouse_position - prev_mouse_position
		rotate_y(delta_mouse.x * 0.003)  # Adjust sensitivity
		rotate_x(delta_mouse.y * 0.003)
		prev_mouse_position = next_mouse_position
