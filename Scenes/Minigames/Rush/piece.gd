extends RigidBody2D

signal clicked

var held = false

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_just_pressed("Select"):
			print("clicked")
			clicked.emit(self)

func _physics_process(delta):
	if held:
		linear_velocity = get_global_mouse_position()


func pickup():
	if held:
		return
	freeze = true
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		freeze = false
		apply_central_impulse(impulse)
		held = false
