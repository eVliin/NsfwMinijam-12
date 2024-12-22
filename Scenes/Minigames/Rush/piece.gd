extends RigidBody2D

var dragging = false
var offset = Vector2.ZERO
var drag_speed = 1000.0  # Adjust this value as needed

func _ready():
	set_gravity_scale(0)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("Select"):
			if event.pressed:
				offset = global_position - get_global_mouse_position()
				dragging = true
			else:
				dragging = false

func _process(delta):
	if dragging:
		var target_position = get_global_mouse_position() + offset
		var direction = (target_position - global_position).normalized()
		var impulse = direction * drag_speed
		apply_impulse(Vector2.ZERO, impulse)
