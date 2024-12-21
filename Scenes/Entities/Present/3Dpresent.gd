extends StaticBody3D

@export var red: Material
@export var blue: Material
@export var white: Material

@onready var color: String = "white"

var input = false
var rotating = false
var prev_mouse_position: Vector2 = Vector2()
var next_mouse_position: Vector2 = Vector2()

func _on_color_set() -> void:
	# Iterar sobre os filhos do StaticBody3D
	for i in range(get_child_count()):
		var child = get_child(i)
		
		# Verificar se o filho tem um subnó válido
		if child and child.get_child_count() > 0:
			var sub_child = child.get_child(0)
			
			# Certificar-se de que o sub_child é um MeshInstance3D
			if sub_child is MeshInstance3D:
				match color:
					"blue":
						if child.name == "Box" or child.name == "Lid":
							sub_child.material_override = blue
						else:
							sub_child.material_override = white
					"red":
						if child.name == "Box" or child.name == "Lid":
							sub_child.material_override = red
						else:
							sub_child.material_override = white
					"white":
						if child.name == "Box" or child.name == "Lid":
							sub_child.material_override = white
						else:
							sub_child.material_override = red

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Zoom_in") and global_position.z <= 4:
		global_position.z += 1
	if Input.is_action_just_pressed("Zoom_out") and global_position.z >= -10.4:
		global_position.z -= 1
	if input:
		if Input.is_action_just_pressed("Select"):
			rotating = true
			prev_mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("Select"):
		rotating = false
	
	if rotating:
		next_mouse_position = get_viewport().get_mouse_position()
		var delta_mouse = next_mouse_position - prev_mouse_position
		rotate_y(delta_mouse.x * 0.003)  # Ajuste de sensibilidade
		rotate_x(delta_mouse.y * 0.003)
		prev_mouse_position = next_mouse_position
