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

#
func _ready() -> void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	
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
	if Global.player_has_control:
		if (Input.is_action_just_pressed("Zoom_in")) \
		&& global_position.z <= 4:
			global_position.z += 1
		if (Input.is_action_just_pressed("Zoom_out")) \
		&& global_position.z >= -10.4:
			global_position.z -= 1
		if input:
			if (Input.is_action_just_pressed("Select")):
				rotating = true
				prev_mouse_position = get_viewport().get_mouse_position()
		if (Input.is_action_just_released("Select")):
			rotating = false
		
		if (rotating):
			next_mouse_position = get_viewport().get_mouse_position()
			rotate_y((next_mouse_position.x - prev_mouse_position.x) * .3 * delta)
			rotate_x((next_mouse_position.y - prev_mouse_position.y) * .3 * delta)
			prev_mouse_position = next_mouse_position


func _on_mouse_entered() -> void:
	input = true


func _on_mouse_exited() -> void:
	input = false
