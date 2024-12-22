class_name GameController extends Node

signal transitioned_in()
signal transitioned_out()

@export var world_2d : Node2D
@export var gui : CanvasLayer

var current_2d_scene
var current_gui_scene
var game_paused : bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		if game_paused:
			$Node2D.process_mode = 4
		else:
			$Node2D.process_mode = 0
		SignalBus.pause.emit(game_paused)


const MOUSESELECT = preload("res://Assets/UI/mouseselect.png")

func _ready() -> void:
	Global.game_controller = self
	current_gui_scene = $GUI/SplashScreenManager
	Input.set_custom_mouse_cursor(MOUSESELECT, Input.CURSOR_POINTING_HAND)

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_cancel")) && Global.player_has_control:
		game_paused = !game_paused

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
