extends StaticBody3D

var input = false
var rotating = false
var prev_mouse_position
var next_mouse_position

func _process(delta: float) -> void:
	
	if (Input.is_action_just_pressed("Zoom_in")) \
	&& global_position.z <= 4:
		global_position.z += 1
	if (Input.is_action_just_pressed("Zoom_out")) \
	&& global_position.z >= -10.4:
		global_position.z -= 1
	if input:
		if (Input.is_action_just_pressed("Rotate")):
			rotating = true
			prev_mouse_position = get_viewport().get_mouse_position()
	if (Input.is_action_just_released("Rotate")):
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
