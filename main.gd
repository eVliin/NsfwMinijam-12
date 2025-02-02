# Main game controller handling scene transitions, GUI management, and pause functionality
class_name GameController extends Node

## Emitted when screen transition-in animation completes
signal transitioned_in()
## Emitted when screen transition-out animation completes
signal transitioned_out()

@export var world_2d : Node2D  ## Container node for 2D game scenes
@export var gui : CanvasLayer  ## Container for GUI layers

var current_2d_scene  ## Currently loaded game world scene
var current_gui_scene  ## Currently active GUI scene

## Pause state with automatic process mode handling
var game_paused : bool = false:
	get: return game_paused
	set(value):
		if game_paused == value: return
		game_paused = value
		# Update process mode using enum values for clarity
		$Node2D.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
		SignalBus.pause.emit(game_paused)

const MOUSESELECT = preload("res://Assets/UI/mouseselect.png")  ## Custom cursor texture

func _ready() -> void:
	Global.game_controller = self  # Register with global access
	current_gui_scene = $GUI/SplashScreenManager  # Initial GUI scene
	Input.set_custom_mouse_cursor(MOUSESELECT, Input.CURSOR_POINTING_HAND)

func _input(event: InputEvent) -> void:
	# Handle pause input only when player has control
	if event.is_action_pressed("ui_cancel") && Global.player_has_control:
		game_paused = !game_paused

## Changes the current GUI scene with optional transition effects
## @param new_scene: Path to new scene resource
## @param transition: Whether to play transition animations
## @param delete: Whether to delete old scene (false to keep in memory)
## @param keep_running: Keep old scene running but hidden
func change_gui_scene(new_scene: String, transition: bool = false, delete: bool = true, keep_running: bool = false) -> void:
	if transition:
		$LoadManager.transition_to()
		await transitioned_in
	
	# Handle previous scene removal
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	
	# Load and display new scene
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	
	if transition:
		$LoadManager.transition_out()

## Changes the game world scene with transition effects
func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	$LoadManager.transition_to()
	await transitioned_in
	
	# Handle previous scene removal
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free()
		elif keep_running:
			current_2d_scene.visible = false
		else:
			world_2d.remove_child(current_2d_scene)
	
	# Load and display new scene
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
	
	$LoadManager.transition_out()

# Animation callback handling transition signals
func _on_animation_player_animation_finished(anim_name: String) -> void:
	match anim_name:
		"in": transitioned_in.emit()
		"out": transitioned_out.emit()
