extends Node3D

var mouse = Vector2()
const DIST = 1000

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("dialogic_default_action"):
			get_mouse_world_pos(mouse)

func get_mouse_world_pos(mouse:Vector2):
	#The physics state of the world
	var space = get_world_3d().direct_space_state
	#start and end world positions for the ray
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse,DIST)
	#Params for 3D raycast
	#Alt var params = PhysicsRayQueryParameters3D.create(start,end)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	#cast the ray using the space and return the results as a Dictionary
	var result = space.intersect_ray(params)
	if result.is_empty():
		print(result)
		SignalBus.present_close.emit()
