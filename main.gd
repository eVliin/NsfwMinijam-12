class_name GameController extends Node

signal transitioned_in()
signal transitioned_out()

@export var world_2d : Node2D
@export var gui : Control

var current_2d_scene
var current_gui_scene

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = $GUI/SplashScreenManager

func change_gui_scene(new_scene: String, transition: bool = false, delete:bool = true, keep_running: bool = false) -> void:
	if transition:
		$LoadManager.transition_to()
		await transitioned_in
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	if transition:
		$LoadManager.transition_out()

func change_2d_scene(new_scene: String, delete:bool = true, keep_running: bool = false) -> void:
	$LoadManager.transition_to()
	await transitioned_in
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			world_2d.remove_child(current_2d_scene)
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
	$LoadManager.transition_out()

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "in":
		transitioned_in.emit()
	elif anim_name == "out":
		transitioned_out.emit()
