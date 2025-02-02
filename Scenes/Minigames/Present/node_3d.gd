extends Node3D

const DIST = 1000
@onready var minigame_present = $"../.."

func _ready() -> void:
	SignalBus.get_mouse_world_pos.connect(get_mouse_world_pos)

func get_mouse_world_pos(mouse:Vector2):
	if Global.player_has_control:
		if minigame_present.name.to_int() == minigame_present._id:
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
			#print(result)
			if result.is_empty():
				SignalBus.present_close.emit()
