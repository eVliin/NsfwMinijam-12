# Character Animation Controller
# Handles puppet animations, attack responses, and state management
# Coordinates with global signals and game state
extends Node2D

### Node References ###
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var chris_base: AnimatedSprite2D = $SubViewport/Chris_base
@onready var frontshot_puppet_hand: AnimatedSprite2D = $SubViewport/Frontshot_Puppet_Hand

### Animation State Properties ###
@export var elbow: bool:
	get: return _elbow
	set(value):
		_set_elbow(value)  # Update elbow state and animations

signal free  # Emitted when animation resources become available

### State Tracking ###
var sceneready = false  # Scene initialization flag
var busy: bool = false  # Animation in progress flag
var _elbow: bool  # Internal elbow state storage

#region Initialization
func _ready() -> void:
	# Connect global and local signals
	SignalBus.attacking.connect(_on_pop)
	animation_player.animation_started.connect(_on_animation_started)
	animation_player.animation_finished.connect(_on_animation_finished)
	sceneready = true
#endregion

#region Animation Control
func _set_elbow(value: bool) -> void:
	"""Update elbow animations while preserving frame progress"""
	if sceneready:
		# Preserve current animation state
		var current_frame = chris_base.get_frame()
		var start_time = chris_base.get_frame_progress()
		
		_elbow = value
		chris_base.play("elbow" if _elbow else "noelbow")
		
		# Synchronize animation states
		frontshot_puppet_hand.play("default")
		frontshot_puppet_hand.set_frame_and_progress(current_frame, start_time)
		chris_base.set_frame_and_progress(current_frame, start_time)

func _on_animation_started(_animation_name: String) -> void:
	"""Handle animation start events"""
	busy = true

func _on_animation_finished(_animation_name: String) -> void:
	"""Handle animation completion events"""
	busy = false
	emit_signal("free")
#endregion

#region Combat Handling
func _on_pop() -> void:
	"""Respond to global attack signal"""
	if !busy:
		handle_attack_response()
	else:
		await free  # Wait for current animation to finish
		_on_pop()

func handle_attack_response():
	"""Execute appropriate attack response based on global state"""
	match Global.AttackTrack:
		1:
			show()
			Global.player_has_control = false
		2, 3:
			animation_player.play(str(Global.AttackTrack - 1))

func cummed() -> void:
	"""Handle attack resolution and state cleanup"""
	if !busy:
		execute_cummed_actions()
	elif Global.popUpTrack > 0:
		await free
		cummed()

func execute_cummed_actions():
	"""Perform actual state reversal and cleanup"""
	match Global.AttackTrack:
		1:
			hide()
			Global.player_has_control = true
		2, 3:
			animation_player.play_backwards(str(Global.AttackTrack - 1))
	
	Global.AttackTrack = max(0, Global.AttackTrack - 1)
	SignalBus.emit_signal("puppet_cummed")
	Global.AttackOrder.pop_front()
#endregion

#region Input Handling
func _input(event: InputEvent) -> void:
	"""Handle player input for attack resolution"""
	if visible and Input.is_action_just_pressed("dialogic_default_action"):
		print("Triggering attack resolution")
		cummed()
#endregion
